import 'dart:async';
import 'package:flutter/material.dart';


mixin YkRtcManagerDelegate {

  Future<void> init();

  Future login(dynamic params);

  Future logout(dynamic params);

  Future<void> enterRoom(String roomId, dynamic params);

  Future<void> exitRoom(dynamic params);

  Future<void> dispose();

  ///打开扬声器
  Future<void> openSpeaker(bool isOpen);

  ///切换角色
  Future<void> switchRole(bool isAnchor);

  ///打开麦克风
  Future<void> openMic(bool isOpen);

  ///开始推流
  Future<void> startStreaming();

  ///停止推流
  Future<void> stopStreaming();

  ///开始本地视频推流
  Future<void> startLocalPreview(bool frontCamera, int? viewId);

  ///开始远端视频拉流
  Future<void> startRemoteView(String userId, int? viewId);

  ///停止远端视频拉流
  Future<void> stopRemoteView(String userId);

  ///停止本地视频推流
  Future<void> stopLocalPreview();

  ///切换摄像头
  Future<int?> changeCamera(bool frontCamera);
}


class YkRtcManager {

  static YkRtcManager? _instance;

  static YkRtcManager get instance {
    _instance ??= YkRtcManager._();
    return _instance!;
  }

  YkRtcManager._();

  YkRtcManagerDelegate? _delegate;

  void config({required YkRtcManagerDelegate delegate}) async {
    _delegate = delegate;
    return;
  }

  Future<void> init() async {
    await _delegate?.init();
    return;
  }

  Future login({dynamic params}) {
    return _delegate?.login(params) ?? Future.value();
  }

  Future logout({dynamic params}) {
    return _delegate?.logout(params) ?? Future.value();
  }

  Future<void> enterRoom({required String roomId, dynamic params}) async {
    await _delegate?.enterRoom(roomId, params);
    return;
  }

  Future<void> exitRoom({required String roomId, dynamic params}) async {
    await _delegate?.exitRoom(params);
    return;
  }

  Future<void> openSpeaker({required bool isOpen}) async {
    await _delegate?.openSpeaker(isOpen);
    return;
  }

  Future<void> switchRole({required bool isAnchor}) async {
    await _delegate?.switchRole(isAnchor);
    return;
  }

  Future<void> openMic({required bool isOpen}) async {
    await _delegate?.openMic(isOpen);
    return;
  }

  Future<void> startStreaming() async {
    await _delegate?.startStreaming();
    return;
  }

  Future<void> stopStreaming() async {
    await _delegate?.stopStreaming();
    return;
  }

  Future<void> startLocalPreview({bool frontCamera = false, int? viewId}) async {
    await _delegate?.startLocalPreview(frontCamera, viewId);
    return;
  }

  Future<void> startRemoteView({required String userId, int? viewId}) async {
    await _delegate?.startRemoteView(userId, viewId);
    return;
  }

  ///停止远端视频拉流
  Future<void> stopRemoteView({required String userId}) async {
    await _delegate?.stopRemoteView(userId);
    return;
  }

  ///停止本地视频推流
  Future<void> stopLocalPreview() async {
    await _delegate?.stopLocalPreview();
    return;
  }

  ///切换摄像头
  Future<int?> changeCamera({required bool frontCamera}) async {
    return await _delegate?.changeCamera(frontCamera);
  }

  Future<void> dispose() async {
    await _delegate?.dispose();
    _delegate = null;
    return;
  }
}