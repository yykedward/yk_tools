import 'dart:async';
import 'package:flutter/material.dart';

/// 相机拍照代理接口
mixin YKCameraPhotoDelegate {
  /// 初始化设置
  Future<void> setup();

  /// 检查权限
  Future<bool> checkAuth();

  /// 拍照
  Future<dynamic> pickPhoto(Map<String, dynamic>? params);
}

/// 相机拍照工具类
class YKCameraPhoto {
  // 单例实现
  static final YKCameraPhoto instance = YKCameraPhoto._();
  YKCameraPhoto._();

  // 私有变量
  YKCameraPhotoDelegate? _delegate;
  bool _isGranted = false;

  /// 获取权限状态
  bool get isGranted => _isGranted;

  /// 初始化设置
  static Future<void> setup({
    required YKCameraPhotoDelegate delegate,
  }) async {
    instance._delegate = delegate;
    try {
      await delegate.setup();
      instance._isGranted = await delegate.checkAuth();
    } catch (e) {
      instance._isGranted = false;
      rethrow;
    }
  }

  /// 拍照
  static Future<T?> pick<T>({Map<String, dynamic>? params}) async {
    if (instance._delegate == null) {
      throw StateError('Camera delegate not set. Call setup() first.');
    }

    // 检查权限
    instance._isGranted = await instance._delegate!.checkAuth();
    if (!instance._isGranted) {
      throw StateError('Camera permission not granted');
    }

    try {
      final result = await instance._delegate!.pickPhoto(params);
      return result is T ? result : null;
    } catch (e) {
      rethrow;
    }
  }

  /// 检查权限
  static Future<bool> checkPermission() async {
    if (instance._delegate == null) {
      return false;
    }
    
    instance._isGranted = await instance._delegate!.checkAuth();
    return instance._isGranted;
  }

  /// 重置状态
  static void reset() {
    instance._delegate = null;
    instance._isGranted = false;
  }
}
