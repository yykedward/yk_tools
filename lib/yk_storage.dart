/// 存储代理接口
mixin YkStorageDelegate {
  Future<void> init();
  Future<void> save({required String key, required dynamic data});
  Future<dynamic> get({required String key});
}

/// 存储工具类
class YkStorage {
  // 常量定义
  static const String _storageOnceKey = 'YK_STORAGE_ONCE_KEY';
  static const String _storageCacheKey = 'YK_STORAGE_CACHE_KEY';

  // 单例实现
  static final YkStorage instance = YkStorage._();
  YkStorage._();

  // 私有变量
  YkStorageDelegate? _delegate;
  final List<String> _onceKeys = [];
  final List<String> _cacheKeys = [];

  /// 初始化存储
  static Future<void> init({required YkStorageDelegate delegate}) async {
    instance._delegate = delegate;
    await instance._delegate?.init();
    await instance._loadKeys();
  }

  /// 获取存储数据
  static Future<T?> get<T>({required String key}) async {
    try {
      final value = await instance._delegate?.get(key: key);
      if (value != null && value is T) {
        return value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 保存数据
  static Future<void> save({
    required String key,
    required dynamic data,
    bool isOnce = true,
  }) async {
    if (isOnce) {
      return _saveOnce(key: key, data: data);
    } else {
      return _saveCache(key: key, data: data);
    }
  }

  /// 清除数据
  static Future<void> clear({bool isOnce = true}) async {
    final keys = isOnce ? instance._onceKeys : instance._cacheKeys;
    for (final key in keys) {
      await instance._delegate?.save(key: key, data: null);
    }
    
    if (isOnce) {
      instance._onceKeys.clear();
      await instance._saveKeyList(_storageOnceKey, instance._onceKeys);
    } else {
      instance._cacheKeys.clear();
      await instance._saveKeyList(_storageCacheKey, instance._cacheKeys);
    }
  }

  /// 加载存储的键列表
  Future<void> _loadKeys() async {
    // 加载一次性存储键
    final onceKeys = await _delegate?.get(key: _storageOnceKey);
    if (onceKeys is List) {
      _onceKeys.addAll(onceKeys.map((e) => e.toString()));
    } else {
      await _saveKeyList(_storageOnceKey, _onceKeys);
    }

    // 加载缓存存储键
    final cacheKeys = await _delegate?.get(key: _storageCacheKey);
    if (cacheKeys is List) {
      _cacheKeys.addAll(cacheKeys.map((e) => e.toString()));
    } else {
      await _saveKeyList(_storageCacheKey, _cacheKeys);
    }
  }

  /// 保存一次性数据
  static Future<void> _saveOnce({
    required String key,
    required dynamic data,
  }) async {
    if (!instance._onceKeys.contains(key)) {
      instance._onceKeys.add(key);
      await instance._saveKeyList(_storageOnceKey, instance._onceKeys);
    }
    await instance._saveData(key: key, data: data);
  }

  /// 保存缓存数据
  static Future<void> _saveCache({
    required String key,
    required dynamic data,
  }) async {
    if (!instance._cacheKeys.contains(key)) {
      instance._cacheKeys.add(key);
      await instance._saveKeyList(_storageCacheKey, instance._cacheKeys);
    }
    await instance._saveData(key: key, data: data);
  }

  /// 保存键列表
  Future<void> _saveKeyList(String key, List<String> list) async {
    await _delegate?.save(key: key, data: list);
  }

  /// 保存数据（改为实例方法）
  Future<void> _saveData({
    required String key,
    required dynamic data,
  }) async {
    await _delegate?.save(key: key, data: data);
  }
}
