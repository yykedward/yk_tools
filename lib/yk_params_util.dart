import 'package:flutter/material.dart';

/// 参数工具类，用于管理全局参数和环境配置
class YkParamsUtil {
  // 单例实现
  static final YkParamsUtil instance = YkParamsUtil._();

  YkParamsUtil._();

  // 私有变量
  final Map<String, dynamic> _params = {};
  bool _isProduct = true;

  /// 配置参数和环境
  static void config({
    required Map<String, dynamic> params,
    required bool isProduct,
  }) {
    instance._params.clear();
    instance._params.addAll(params);
    instance._isProduct = isProduct;
  }

  /// 获取参数或执行回调
  /// [key] - 参数键值
  /// [debugCallBack] - 开发环境回调
  /// [productCallBack] - 生产环境回调
  static Future<T?> get<T>({
    String? key,
    Future<T> Function()? debugCallBack,
    Future<T> Function()? productCallBack,
  }) async {
    try {
      // 如果指定了 key，优先从参数表中获取
      if (key != null && instance._params.containsKey(key)) {
        final value = instance._params[key];
        if (value is T) {
          return value;
        }
        // 类型不匹配时执行环境对应的回调
        return await _executeCallback<T>(debugCallBack, productCallBack);
      }

      return await _executeCallback<T>(debugCallBack, productCallBack);
    } catch (e) {
      debugPrint('YkParamsUtil get error: $e');
      return null;
    }
  }

  // 根据环境执行对应回调
  static Future<T?> _executeCallback<T>(
    Future<T> Function()? debugCallBack,
    Future<T> Function()? productCallBack,
  ) async {
    if (instance._isProduct) {
      return await productCallBack?.call();
    } else {
      return await debugCallBack?.call();
    }
  }

  /// 获取当前环境
  static bool get isProduct => instance._isProduct;

  /// 获取所有参数
  static Map<String, dynamic> get params => Map.unmodifiable(instance._params);

  /// 清除所有参数
  static void clear() {
    instance._params.clear();
  }

  /// 更新单个参数
  static void updateParam(String key, dynamic value) {
    instance._params[key] = value;
  }

  /// 批量更新参数
  static void updateParams(Map<String, dynamic> newParams) {
    instance._params.addAll(newParams);
  }

  /// 移除参数
  static void removeParam(String key) {
    instance._params.remove(key);
  }
}
