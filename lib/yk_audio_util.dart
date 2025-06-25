import 'dart:async';
import 'package:flutter/foundation.dart';

mixin YkAudioUtilDelegate {
  Future init();

  Future dispose();

  Future regis(String audioID, String audioUrl);

  Future<bool> play(String audioID, void Function(double duration, double position) progressCallBack, void Function() finishCallBack);

  Future<bool> end();

  Future seekTo(double progress);
}

class YkAudioUtil with ChangeNotifier {
  static YkAudioUtil? _instance;

  static YkAudioUtil get instance {
    _instance ??= YkAudioUtil._();
    return _instance!;
  }

  YkAudioUtil._();

  YkAudioUtilDelegate? _delegate;

  bool isPlaying = false;

  double duration = 0.0;

  double position = 0.0;

  String? currentPlayingAudioID;

  Future init({required YkAudioUtilDelegate delegate}) {
    _delegate = delegate;
    isPlaying = false;
    notifyListeners();
    return delegate.init();
  }

  Future regis({required String audioID, required String audioUrl}) async {
    if (_delegate != null) {
      await _delegate!.regis(audioID, audioUrl);
    }
  }

  Future play({required String audioID, void Function(double duration, double position)? progressCallBack, void Function()? finishCallBack}) async {
    if (isPlaying) {
      await end();
    }

    if (_delegate != null) {
      final result = await _delegate!.play(audioID, (duration, position) {
        /// 进度回调
        progressCallBack?.call(duration, position);
        this.duration = duration;
        this.position = position;
        notifyListeners();
      }, () async {
        await end();
        finishCallBack?.call();
      });
      if (result) {
        isPlaying = true;
        currentPlayingAudioID = audioID;
        notifyListeners();
      }
    }
  }

  Future end() async {
    final result = await _delegate?.end() ?? false;
    if (result) {
      isPlaying = false;
      currentPlayingAudioID = null;
      duration = 0;
      position = 0;
      notifyListeners();
    }
    return Future.value();
  }

  Future seekTo({required double progress}) async {
    if (!isPlaying) {
      return;
    }
    await _delegate?.seekTo(progress);
  }

  Future unInit() async {
    await _delegate?.dispose().then((value) {
      _delegate = null;
    });
  }

  @override
  void dispose() {
    unInit();
    super.dispose();
  }
}
