import 'dart:async';

import 'package:flutter/foundation.dart';

mixin YkRecorderDelegate {
  Future init();

  Future dispose();

  Future<bool> start(String toFilePath);

  Future end();

  Future<bool> checkGrant();
}

class YkRecorderConfig with ChangeNotifier {
  static YkRecorderConfig? _instance;

  static YkRecorderConfig get instance {
    _instance ??= YkRecorderConfig._();
    return _instance!;
  }

  YkRecorderConfig._();

  bool isRecording = false;

  void _changeRecord({required bool recording}) {
    isRecording = recording;
    notifyListeners();
  }
}

class YkRecorder with ChangeNotifier {
  YkRecorderDelegate? _delegate;
  bool _isRecording = false;
  void Function(String? path, Duration? duration)? _onCompleteCallBack;
  String? _currentFilePath;
  Timer? _timer;
  int duration = 0;
  bool _didDispose = false;

  Future init({required YkRecorderDelegate delegate}) {
    _delegate = delegate;
    return delegate.init();
  }

  Future<void> start(
      {required String toFilePath, required void Function(String? path, Duration? duration) onCompleteCallBack, int maxSeconds = 0}) async {
    if (_delegate == null) {
      return Future.error('未注册 delegate');
    }
    if (_isRecording) {
      return Future.value();
    }
    try {
      final didGrand = await _delegate!.checkGrant();
      if (!didGrand) {
        throw Exception('未获取录音权限');
      }
      _currentFilePath = toFilePath;
      _onCompleteCallBack = onCompleteCallBack;
      final didRecord = await _delegate!.start(toFilePath);
      _timer?.cancel();
      if (didRecord) {
        duration = 0;

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          duration += 1;
          if (duration >= maxSeconds) {
            await end();
          } else {
            notifyListeners();
          }
        });
      }
      _isRecording = didRecord;
      YkRecorderConfig.instance._changeRecord(recording: didRecord);
    } catch (e) {
      // _delegate?.error("_start ${e.toString()}");
    }
    return Future.value();
  }

  Future end() async {
    if (_delegate == null) {
      return Future.error('未注册 delegate');
    }
    if (!_isRecording) {
      return Future.value();
    }

    //结束录音逻辑
    try {
      await _delegate!.end();
      _timer?.cancel();
      _isRecording = false;
      YkRecorderConfig.instance._changeRecord(recording: false);
      _onCompleteCallBack?.call(_currentFilePath, Duration(seconds: duration));
      duration = 0;
      if (!_didDispose) {
        notifyListeners();
      }
    } catch (e) {
      // _delegate?.error("_end ${e.toString()}");
    }
    return Future.value("");
  }

  @override
  void dispose() {
    _didDispose = true;
    _unInit();
    super.dispose();
  }

  Future _unInit() async {
    if (_delegate != null) {
      await end();
      await _delegate!.dispose();
      _delegate = null;
    }
  }
}
