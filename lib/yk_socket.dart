

import 'dart:async';
import 'dart:io';

class YKSocketDelegate {

  void Function()? connectFailCallBack;

  void Function()? connectSuccessCallBack;

  void Function(String msg)? errorMsgCallBack;

  void Function(String msg)? logMsgCallBack;

  void Function()? closeCallBack;

  void Function()? beginRelink;

  YKSocketDelegate({this.connectFailCallBack, this.connectSuccessCallBack, this.errorMsgCallBack, this.logMsgCallBack, this.closeCallBack, this.beginRelink});
}

class YKSocketController {

  YKSocket? _socket;

  bool get isConnected => _socket?._isConnected ?? false;

  StreamController<dynamic> _messageStreamController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageStreamController.stream;

  StreamController<bool> _connectedStreamController = StreamController<bool>.broadcast();

  Stream<bool> get connectedStream => _connectedStreamController.stream;

  Future<void> connect() async {
    return _socket?._connect();
  }

  Future<void> close() async {
    return _socket?._close();
  }

  Future<void> send(dynamic msg) async {
    return _socket?._send(msg);
  }

  Future<void> dispose() async {
    return _socket?._dispose();
  }
}

class YKSocket {

  final String url;

  YKSocketDelegate? delegate;

  YKSocketController? _controller;

  WebSocket? _webSocket;

  StreamSubscription? _messageStream;

  bool _isConnected = false;

  int _relinkTime = 0;

  YKSocket({required this.url, this.delegate, YKSocketController? controller}) {
    _controller = controller;
    _controller?._socket = this;
  }

  Future<void> _connect() async {

    await WebSocket.connect(url).then((value) {
      _webSocket = value;

      delegate?.connectSuccessCallBack?.call();

      if (_messageStream != null) {
        _messageStream!.cancel();
      }
      _messageStream = value.listen((message) {
        try {
          _controller?._messageStreamController.add(message);
        } catch (e) {
          delegate?.errorMsgCallBack?.call(e.toString());
        }
      });

      _isConnected = true;
      _controller?._connectedStreamController.add(true);

      value.done.then((v) {
        int closeCode = value.closeCode ?? 0;
        if (closeCode != 0) {
          if (closeCode != 1000) {
            delegate?.logMsgCallBack?.call("socket 断开连接 closeCode:$closeCode");
            _relink();
          }
        } else {
          _isConnected = false;
          _controller?._connectedStreamController.add(false);
        }
      });
      

    }).onError((error, stackTrace) {
      delegate?.connectFailCallBack?.call();
    });

  }

  Future<void> _send(dynamic msg) async {
    try {
      return _webSocket?.add(msg);
    } catch (e) {
      if (_webSocket != null && _isConnected) {
        if (_webSocket!.closeCode != 1000) {
           await _relink();
        } else {
          delegate?.errorMsgCallBack?.call(e.toString());
        }
      }
      return;
    }
  }

  Future<void> _relink() async {
    await _webSocket?.close();
    int nowTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((nowTime - _relinkTime) > 2) {
      _relinkTime = nowTime;
      delegate?.beginRelink?.call();
      delegate?.logMsgCallBack?.call("正在尝试重连");
      await _connect();
    }
    return;
  }

  Future<void> _close() async {
    await _webSocket?.close();
    delegate?.closeCallBack?.call();
    _isConnected = false;
    _controller?._connectedStreamController.add(false);
    return;
  }

  Future<void> _dispose() async {
    await _close().then((value) {
      _isConnected = false;
      _controller?._connectedStreamController.add(false);
      _controller?._messageStreamController.close();
    });
  }
}