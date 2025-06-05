import 'dart:async';

import 'package:flutter/foundation.dart';

mixin YkRecorderDelegate {
  Future init();

  Future dispose();

  Future<bool> start(
      {required String toFilePath,
        required void Function(Duration duration) progressCallBack,
        required Future Function() endCallBack,
        int maxSeconds = 0});

  Future end();

  Future<bool> checkGrant();

  error(String msg);
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

class YkRecorder {

  YkRecorderDelegate? _delegate;
  bool _isRecording = false;
  void Function(String? path, Duration? duration)? _onCompleteCallBack;
  String? _currentFilePath;
  Duration? _duration;


  final _durationStreamController = StreamController<Duration?>.broadcast();

  Stream<Duration?> get durationStream => _durationStreamController.stream;

  Future setup({required YkRecorderDelegate delegate}) {
    _delegate = delegate;
    return delegate.init();
  }

  Future<void> start({required String toFilePath, required void Function(String? path, Duration? duration) onCompleteCallBack, int maxSeconds = 0}) async {
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
      final didRecord = await _delegate!.start(
          toFilePath: toFilePath,
          progressCallBack: (duration) {
            _duration = duration;
            _durationStreamController.add(duration);
          },
          endCallBack: () {
            return end();
          },
          maxSeconds: maxSeconds);
      _isRecording = didRecord;
      YkRecorderConfig.instance._changeRecord(recording: didRecord);
    } catch (e) {
      _delegate?.error("_start ${e.toString()}");
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
      _isRecording = false;
      YkRecorderConfig.instance._changeRecord(recording: false);
      _onCompleteCallBack?.call(_currentFilePath, _duration);
      _duration = null;
      _durationStreamController.add(null);
    } catch (e) {
      _delegate?.error("_end ${e.toString()}");
    }
    return Future.value("");
  }

  dispose() async {
    if (_delegate != null) {
      await _delegate!.dispose();
      _delegate = null;
    }
  }
}
