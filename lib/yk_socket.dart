import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Socket 连接状态
enum SocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Socket 代理回调
class YKSocketDelegate {
  final void Function()? onConnectFail;
  final void Function()? onConnectSuccess;
  final void Function(String message)? onError;
  final void Function(String message)? onLog;
  final void Function()? onClose;
  final void Function()? onReconnecting;

  const YKSocketDelegate({
    this.onConnectFail,
    this.onConnectSuccess,
    this.onError,
    this.onLog,
    this.onClose,
    this.onReconnecting,
  });
}

/// Socket 控制器回调
class YKSocketControllerCallback {
  final Future<void> Function(String url) connect;
  final Future<void> Function() close;
  final Future<void> Function(dynamic message) send;
  final Future<void> Function() dispose;
  final SocketState Function() getState;

  const YKSocketControllerCallback({
    required this.connect,
    required this.close,
    required this.send,
    required this.dispose,
    required this.getState,
  });
}

/// Socket 控制器
class YKSocketController {
  YKSocketControllerCallback? _callback;
  YKSocket? _socket;

  /// 获取连接状态
  bool get isConnected => state == SocketState.connected;

  /// 获取当前状态
  SocketState get state => _callback?.getState() ?? SocketState.disconnected;

  /// 连接
  Future<void> connect(String url) => _callback?.connect(url) ?? Future.value();

  /// 关闭连接
  Future<void> close() => _callback?.close() ?? Future.value();

  /// 发送消息
  Future<void> send(dynamic message) => _callback?.send(message) ?? Future.value();

  /// 释放资源
  Future<void> dispose() async {
    await _callback?.dispose();
    _callback = null;
    _socket = null;
  }
}

/// WebSocket 实现
class YKSocket {
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  String? _url;

  final _messageController = StreamController<dynamic>.broadcast();
  final _stateController = StreamController<SocketState>.broadcast();

  YKSocket({
    this.reconnectDelay = const Duration(seconds: 2),
    this.maxReconnectAttempts = 3,
  });

  WebSocket? _webSocket;
  StreamSubscription? _messageSubscription;
  YKSocketController? _controller;
  YKSocketDelegate? _delegate;
  SocketState _state = SocketState.disconnected;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

  /// 获取当前状态
  SocketState get state => _state;

  /// 获取消息流
  Stream<dynamic> get messageStream => _messageController.stream;

  /// 获取状态流
  Stream<SocketState> get stateStream => _stateController.stream;

  /// 初始化
  void initialize({
    required YKSocketController controller,
    YKSocketDelegate? delegate,
  }) {
    _controller = controller;
    _delegate = delegate;
    controller._socket = this;
    
    // 设置控制器回调
    controller._callback = YKSocketControllerCallback(
      connect: _connect,
      close: _close,
      send: _send,
      dispose: _dispose,
      getState: () => state,
    );
  }

  /// 处理消息
  void _handleMessage(dynamic message) {
    try {
      _messageController.add(message);
    } catch (e) {
      _delegate?.onError?.call('Message handling failed: $e');
    }
  }

  /// 更新状态
  void _updateState(SocketState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// 释放资源
  Future<void> _dispose() async {
    await _close();
    _url = null;
    await _messageController.close();
    await _stateController.close();
    _controller = null;
    _delegate = null;
  }

  /// 连接
  Future<void> _connect(String url) async {
    if (_state == SocketState.connected || _state == SocketState.connecting) {
      return;
    }

    _url = url;
    _updateState(SocketState.connecting);

    try {
      _webSocket = await WebSocket.connect(url);
      _setupWebSocket(_webSocket!);
      _reconnectAttempts = 0;
      _delegate?.onConnectSuccess?.call();
    } catch (e) {
      _delegate?.onConnectFail?.call();
      _delegate?.onError?.call('Connection failed: $e');
      _handleConnectionError();
    }
  }

  /// 发送消息
  Future<void> _send(dynamic message) async {
    if (_state != SocketState.connected) {
      throw StateError('Socket is not connected');
    }

    try {
      _webSocket?.add(message);
    } catch (e) {
      _delegate?.onError?.call('Send failed: $e');
      if (_webSocket?.closeCode != 1000) {
        await _reconnect();
      }
    }
  }

  /// 关闭连接
  Future<void> _close() async {
    _reconnectAttempts = maxReconnectAttempts; // 防止自动重连
    await _cleanUp();
    _delegate?.onClose?.call();
  }

  /// 重连
  Future<void> _reconnect() async {
    if (_state == SocketState.reconnecting || 
        _reconnectAttempts >= maxReconnectAttempts ||
        _url == null) {
      return;
    }

    _updateState(SocketState.reconnecting);
    _delegate?.onReconnecting?.call();
    _delegate?.onLog?.call('Attempting to reconnect...');

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      _connect(_url!);
    });
  }

  /// 设置 WebSocket
  void _setupWebSocket(WebSocket socket) {
    _messageSubscription?.cancel();
    _messageSubscription = socket.listen(
      _handleMessage,
      onDone: _handleDisconnect,
      onError: _handleError,
      cancelOnError: false,
    );
    
    _updateState(SocketState.connected);
  }

  /// 处理断开连接
  void _handleDisconnect() {
    final closeCode = _webSocket?.closeCode ?? 0;
    if (closeCode != 1000 && closeCode != 0) {
      _delegate?.onLog?.call('Socket disconnected with code: $closeCode');
      _reconnect();
    } else {
      _updateState(SocketState.disconnected);
    }
  }

  /// 处理错误
  void _handleError(dynamic error) {
    _delegate?.onError?.call('Socket error: $error');
    _handleConnectionError();
  }

  /// 处理连接错误
  void _handleConnectionError() {
    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnect();
    } else {
      _updateState(SocketState.disconnected);
    }
  }

  /// 清理资源
  Future<void> _cleanUp() async {
    _reconnectTimer?.cancel();
    await _messageSubscription?.cancel();
    await _webSocket?.close();
    _webSocket = null;
    _updateState(SocketState.disconnected);
  }
}