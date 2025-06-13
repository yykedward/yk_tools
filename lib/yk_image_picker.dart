import 'dart:async';
import 'package:flutter/material.dart';

/// 图片选择器代理接口
mixin YKImagePickerDelegate {
  /// 初始化设置
  Future<void> init();

  /// 检查权限
  Future<bool> checkAuth();

  /// 选择图片
  Future<dynamic> pickImage(dynamic params, int maxCount);

  /// 释放资源
  Future<void> unInit();
}

/// 图片选择器工具类
class YKImagePicker {
  // 单例实现
  static final YKImagePicker instance = YKImagePicker._();

  YKImagePicker._();

  // 私有变量
  YKImagePickerDelegate? _delegate;

  /// 初始化设置
  static Future<void> setup({required YKImagePickerDelegate delegate}) async {
    instance._delegate = delegate;
    await instance._delegate?.init();
  }

  /// 选择图片
  static Future<T?> pick<T>({dynamic params, int maxCount = 9}) async {
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

  /// 重置状态
  static void reset() {
    instance._delegate?.unInit().then((value) {
      instance._delegate = null;
    });
  }
}
