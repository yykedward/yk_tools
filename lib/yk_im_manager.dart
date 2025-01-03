import 'dart:async';
import 'package:flutter/material.dart';

// 定义消息回调类型
typedef MessageCallback = void Function(dynamic message);
typedef KickedOfflineCallback = void Function();

// 定义 IM 状态枚举
enum ImConnectionState {
  disconnected,
  connecting,
  connected,
  error
}

// 优化 delegate 接口
mixin YkImManagerDelegate {
  Future<void> init(
    MessageCallback onMessageReceived,
    KickedOfflineCallback onKickedOffline,
    Map<String, dynamic>? params,
  );

  Future<void> dispose();

  Future<void> login(Map<String, dynamic>? params);

  Future<void> logout(Map<String, dynamic>? params);

  Future<void> joinGroup(
    String groupId,
    Map<String, dynamic>? params,
  );

  Future<void> quitGroup(
    String? groupId,
    Map<String, dynamic>? params,
  );

  Future<dynamic> sendMessage(
    String? groupId,
    String? content,
    String? imagePath,
    String? customData,
    Map<String, dynamic>? params,
  );
}

class YkImManager {
  // 单例实现
  static final YkImManager instance = YkImManager._();
  YkImManager._();

  // 私有变量
  YkImManagerDelegate? _delegate;
  final _messageController = StreamController<dynamic>.broadcast();
  final _stateController = StreamController<ImConnectionState>.broadcast();
  KickedOfflineCallback? _onKickedOffline;
  ImConnectionState _currentState = ImConnectionState.disconnected;

  // 公开访问器
  Stream<dynamic> get messageStream => _messageController.stream;
  Stream<ImConnectionState> get connectionState => _stateController.stream;
  bool get isConnected => _currentState == ImConnectionState.connected;

  // 配置方法
  Future<void> config({required YkImManagerDelegate delegate}) async {
    _delegate = delegate;
    _updateState(ImConnectionState.disconnected);
  }

  // 初始化方法
  Future<void> init({
    Map<String, dynamic>? params,
    KickedOfflineCallback? onKickedOffline,
  }) async {
    try {
      _updateState(ImConnectionState.connecting);
      _onKickedOffline = onKickedOffline;
      
      await _delegate?.init(
        _handleMessage,
        _handleKickedOffline,
        params,
      );
      
      _updateState(ImConnectionState.connected);
    } catch (e) {
      _updateState(ImConnectionState.error);
      rethrow;
    }
  }

  // 释放资源
  Future<void> dispose() async {
    await _delegate?.dispose();
    _delegate = null;
    await _messageController.close();
    await _stateController.close();
    _updateState(ImConnectionState.disconnected);
  }

  // 登录方法
  Future<void> login({
    Map<String, dynamic>? params,
  }) async {
    await _delegate?.login(params);
  }

  // 登出方法
  Future<void> logout({Map<String, dynamic>? params}) async {
    await _delegate?.logout(params);
    _updateState(ImConnectionState.disconnected);
  }

  // 加入群组
  Future<void> joinGroup({
    required String groupId,
    Map<String, dynamic>? params,
  }) async {
    await _delegate?.joinGroup(
      groupId,
      params,
    );
  }

  // 退出群组
  Future<void> quitGroup({
    String? groupId,
    Map<String, dynamic>? params,
  }) async {
    await _delegate?.quitGroup(
      groupId,
      params,
    );
  }

  // 发送消息
  Future<dynamic> sendMessage({
    String? groupId,
    String? content,
    String? imagePath,
    String? customData,
    Map<String, dynamic>? params,
  }) async {
    if (!isConnected) {
      throw StateError('IM not connected');
    }
    
    return await _delegate?.sendMessage(
      groupId,
      content,
      imagePath,
      customData,
      params,
    ) ?? {};
  }

  // 私有方法
  void _handleMessage(dynamic message) {
    _messageController.add(message);
  }

  void _handleKickedOffline() {
    _updateState(ImConnectionState.disconnected);
    _onKickedOffline?.call();
  }

  void _updateState(ImConnectionState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }
}