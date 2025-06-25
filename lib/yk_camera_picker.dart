import 'dart:async';

/// 相机拍照代理接口
mixin YKCameraPhotoDelegate {
  /// 初始化设置
  Future<void> init();

  /// 检查权限
  Future<bool> checkAuth();

  /// 拍照
  Future<dynamic> pickPhoto(Map<String, dynamic>? params);

  /// 释放资源
  Future<void> unInit();
}

/// 相机拍照工具类
class YKCameraPhoto {
  // 单例实现
  static final YKCameraPhoto instance = YKCameraPhoto._();
  YKCameraPhoto._();

  // 私有变量
  YKCameraPhotoDelegate? _delegate;

  /// 初始化设置
  static Future<void> setup({
    required YKCameraPhotoDelegate delegate,
  }) async {
    instance._delegate = delegate;
  }

  /// 拍照
  static Future<T?> pick<T>({Map<String, dynamic>? params}) async {
    if (instance._delegate == null) {
      throw StateError('Camera delegate not set. Call setup() first.');
    }

    // 检查权限
    final isGranted = await instance._delegate!.checkAuth();
    if (isGranted) {
      throw StateError('Camera permission not granted');
    }

    try {
      final result = await instance._delegate!.pickPhoto(params);
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
