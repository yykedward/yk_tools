import 'dart:async';
import 'package:flutter/material.dart';


mixin YkRtcManagerAbStract {

  Future<void> init();

  Future<void> enterRoom(String roomId, bool isLive);

  Future<void> exitRoom();

  Future<void> dispose();

  ///打开扬声器
  @optionalTypeArgs
  Future<void> openSpeaker(bool isOpen) async {
    return;
  }

  ///切换角色
  @optionalTypeArgs
  Future<void> switchRole(bool isAnchor) async {
    return;
  }

  ///打开麦克风
  @optionalTypeArgs
  Future<void> openMic(bool isOpen) async {
    return;
  }

  ///开始推流
  @optionalTypeArgs
  Future<void> startStreaming() async {
    return;
  }

  ///停止推流
  @optionalTypeArgs
  Future<void> stopStreaming() async {
    return;
  }

  ///开始本地视频推流
  @optionalTypeArgs
  Future<void> startLocalPreview(bool frontCamera, int? viewId) async {
    return;
  }

  ///开始远端视频拉流
  @optionalTypeArgs
  Future<void> startRemoteView(String userId, int? viewId) async {
    return;
  }

  ///停止远端视频拉流
  @optionalTypeArgs
  Future<void> stopRemoteView(String userId) async {
    return;
  }

  ///停止本地视频推流
  @optionalTypeArgs
  Future<void> stopLocalPreview() async {
    return;
  }

  ///切换摄像头
  @optionalTypeArgs
  Future<int?> changeCamera(bool frontCamera) async {
    return null;
  }
}


class YkRtcManager {

  static YkRtcManager? _instance;

  static YkRtcManager get instance {
    _instance ??= YkRtcManager._();
    return _instance!;
  }

  YkRtcManager._();

  YkRtcManagerAbStract? _baseRTCAbStract;

  void config(YkRtcManagerAbStract stract) async {
    _baseRTCAbStract = stract;
    return;
  }

  Future<void> init() async {
    await _baseRTCAbStract?.init();
    return;
  }

  Future<void> enterRoom(String roomId, bool isLive) async {
    await _baseRTCAbStract?.enterRoom(roomId, isLive);
    return;
  }

  Future<void> exitRoom() async {
    await _baseRTCAbStract?.exitRoom();
    return;
  }

  Future<void> openSpeaker(bool isOpen) async {
    await _baseRTCAbStract?.openSpeaker(isOpen);
    return;
  }

  Future<void> switchRole(bool isAnchor) async {
    await _baseRTCAbStract?.switchRole(isAnchor);
    return;
  }

  Future<void> openMic(bool isOpen) async {
    await _baseRTCAbStract?.openMic(isOpen);
    return;
  }

  Future<void> startStreaming() async {
    await _baseRTCAbStract?.startStreaming();
    return;
  }

  Future<void> stopStreaming() async {
    await _baseRTCAbStract?.stopStreaming();
    return;
  }

  Future<void> startLocalPreview(bool frontCamera, int? viewId) async {
    await _baseRTCAbStract?.startLocalPreview(frontCamera, viewId);
    return;
  }

  Future<void> startRemoteView(String userId, int? viewId) async {
    await _baseRTCAbStract?.startRemoteView(userId, viewId);
    return;
  }

  ///停止远端视频拉流
  Future<void> stopRemoteView(String userId) async {
    await _baseRTCAbStract?.stopRemoteView(userId);
    return;
  }

  ///停止本地视频推流
  Future<void> stopLocalPreview() async {
    await _baseRTCAbStract?.stopLocalPreview();
    return;
  }

  ///切换摄像头
  Future<int?> changeCamera(bool frontCamera) async {
    return await _baseRTCAbStract?.changeCamera(frontCamera);
  }

  Future<void> dispose() async {
    await _baseRTCAbStract?.dispose();
    _baseRTCAbStract = null;
    return;
  }
}