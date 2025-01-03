import 'dart:core';

/// 模块执行结果
class ModuleResult<T> {
  final bool success;
  final T? data;
  final Object? error;

  const ModuleResult({
    required this.success,
    this.data,
    this.error,
  });

  factory ModuleResult.success(T? data) {
    return ModuleResult(success: true, data: data);
  }

  factory ModuleResult.failure(Object error) {
    return ModuleResult(success: false, error: error);
  }
}

/// 磁盘管理模块接口
mixin YKDiskManagerModule {
  /// 结束模块
  Future<bool> endModule(String targetModule, Map<String, dynamic> params);

  /// 执行模块
  Future<dynamic> executeModule(Map<String, dynamic> params);
}

/// 磁盘管理器
class YKDiskManager {
  // 单例实现
  static final YKDiskManager instance = YKDiskManager._();
  YKDiskManager._();

  // 模块处理器映射表
  final _moduleHandlers = <String, YKDiskManagerModule>{};

  /// 注册模块
  static void registerModule(String module, YKDiskManagerModule handler) {
    if (module.isEmpty) {
      throw ArgumentError('Module name cannot be empty');
    }
    instance._moduleHandlers[module] = handler;
  }

  /// 移除模块
  static void unregisterModule(String module) {
    instance._moduleHandlers.remove(module);
  }

  /// 打开模块
  static Future<ModuleResult<T>> openModule<T>({
    required String module,
    required Map<String, dynamic> params,
    void Function(Object error)? onError,
  }) async {
    try {
      // 结束其他模块
      for (final handler in instance._moduleHandlers.values) {
        try {
          final shouldContinue = await handler.endModule(module, params);
          if (!shouldContinue) {
            return ModuleResult.failure(
              StateError('Module termination requested'),
            );
          }
        } catch (e) {
          onError?.call(e);
          return ModuleResult.failure(e);
        }
      }

      // 执行目标模块
      final handler = instance._moduleHandlers[module];
      if (handler == null) {
        final error = StateError('Module "$module" not found');
        onError?.call(error);
        return ModuleResult.failure(error);
      }

      final result = await handler.executeModule(params);
      return ModuleResult.success(result as T?);
    } catch (e) {
      onError?.call(e);
      return ModuleResult.failure(e);
    }
  }

  /// 获取已注册的模块列表
  static List<String> get registeredModules => 
      List.unmodifiable(instance._moduleHandlers.keys);

  /// 检查模块是否已注册
  static bool hasModule(String module) => 
      instance._moduleHandlers.containsKey(module);

  /// 清除所有模块
  static void clear() => instance._moduleHandlers.clear();
}