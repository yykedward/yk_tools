import 'dart:async';
import 'dart:io';

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

/// WebSocket 实现
class YkSocket {
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  String? _url;

  final _messageController = StreamController<dynamic>.broadcast();
  final _stateController = StreamController<SocketState>.broadcast();

  YkSocket({
    this.reconnectDelay = const Duration(seconds: 2),
    this.maxReconnectAttempts = 3,
  });

  WebSocket? _webSocket;
  StreamSubscription? _messageSubscription;
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

  /// 重连
  Future<void> _reconnect() async {
    if (_state == SocketState.reconnecting || _reconnectAttempts >= maxReconnectAttempts || _url == null) {
      return;
    }

    _updateState(SocketState.reconnecting);
    _delegate?.onReconnecting?.call();
    _delegate?.onLog?.call('Attempting to reconnect...');

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      connect(url: _url!, delegate: _delegate!);
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
    _messageSubscription?.cancel();
    _webSocket?.close();
    _webSocket = null;
    _updateState(SocketState.disconnected);
  }
}

extension YkSocketPublic on YkSocket {


  /// 连接
  Future<void> connect({required String url, required YKSocketDelegate delegate}) async {
    if (_state == SocketState.connected || _state == SocketState.connecting) {
      return;
    }
    _delegate = delegate;

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
  Future<void> send(dynamic message) async {
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

  /// 释放资源
  Future dispose() async {
    close();
    _messageController.close();
    _stateController.close();
    _delegate = null;
  }

  /// 关闭连接
  Future<void> close() async {
    _reconnectAttempts = maxReconnectAttempts; // 防止自动重连
    _cleanUp();
    _delegate?.onClose?.call();
  }
}