import 'dart:async';
import 'package:flutter/material.dart';

/// 图片选择器代理接口
mixin YKImagePickerDelegate {
  /// 初始化设置
  Future<void> setup();

  /// 检查权限
  Future<bool> checkAuth();

  /// 选择图片
  Future<dynamic> pickImage(Map<String, dynamic>? params, int maxCount);
}

/// 图片选择器工具类
class YKImagePicker {
  // 单例实现
  static final YKImagePicker instance = YKImagePicker._();
  YKImagePicker._();

  // 私有变量
  YKImagePickerDelegate? _delegate;
  bool _isGranted = false;

  /// 获取权限状态
  bool get isGranted => _isGranted;

  /// 初始化设置
  static Future<void> setup({
    required YKImagePickerDelegate delegate,
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

  /// 选择图片
  static Future<T?> pick<T>({
    required Map<String, dynamic>? params,
    int maxCount = 9,
  }) async {
    if (instance._delegate == null) {
      throw StateError('Image picker delegate not set. Call setup() first.');
    }

    // 检查权限
    final hasPermission = await instance._delegate!.checkAuth();
    if (!hasPermission) {
      throw StateError('Image picker permission not granted');
    }

    try {
      final result = await instance._delegate!.pickImage(params, maxCount);
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
    
    try {
      final hasPermission = await instance._delegate!.checkAuth();
      instance._isGranted = hasPermission;
      return hasPermission;
    } catch (e) {
      debugPrint('Permission check error: $e');
      instance._isGranted = false;
      return false;
    }
  }

  /// 重置状态
  static void reset() {
    instance._delegate = null;
    instance._isGranted = false;
  }
}
