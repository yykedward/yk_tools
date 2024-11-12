


mixin YkStorageDelegate {

  Future init();

  Future save({required String key, required dynamic data});

  Future<dynamic> get({required String key});
}

class YkStorage  {

  static String _straget_once_key = "YK_STORAGE_ONCE_KEY";

  static String _straget_cache_key = "YK_STORAGE_CACHE_KEY";

  static YkStorage? _instance;

  List<String> _onceCache = [];

  List<String> _Cache = [];

  factory YkStorage._getInstance() {
    _instance ??= YkStorage._();
    return _instance!;
  }

  YkStorage._();

  YkStorageDelegate? _delegate;

  static Future<void> init({required YkStorageDelegate delegate}) async {

    YkStorage._getInstance()._delegate = delegate;

    await YkStorage._getInstance()._delegate?.init();
    final onceCache = await YkStorage._getInstance()._delegate?.get(key: YkStorage._straget_once_key); //GetStorage().read(YKStorage._straget_once_key);
    if (onceCache != null && onceCache is List<dynamic>) {
      YkStorage._instance?._onceCache = onceCache.map((e) => "$e").toList();
    } else {
      await YkStorage._getInstance()._delegate?.save(key: YkStorage._straget_once_key, data: []);
    }

    final cacheList = await YkStorage._getInstance()._delegate?.get(key: YkStorage._straget_cache_key);
    if (cacheList != null && cacheList is List<dynamic>) {
      YkStorage._instance?._Cache = cacheList.map((e) => "$e").toList();
    } else {
      await YkStorage._getInstance()._delegate?.save(key: YkStorage._straget_cache_key, data: []);
    }
  }

  static Future<dynamic> get({required String key}) async {
    if (YkStorage._getInstance()._delegate != null) {
      return YkStorage._getInstance()._delegate!.get(key: key);
    } else {
      return null;
    }
  }

  static Future<void> save({required String key, required dynamic data, bool isOnce = true}) {
    if (isOnce) {
      return _saveOnce(key: key, data: data);
    } else {
      return _saveCache(key: key, data: data);
    }
  }

  static Future<void> clear({bool isOnce = true}) async {

    if (isOnce) {
      for (final key in YkStorage._getInstance()._onceCache) {
        await YkStorage._getInstance()._delegate?.save(key: key, data: null);
      }
    } else {
      for (final key in YkStorage._getInstance()._Cache) {
        await YkStorage._getInstance()._delegate?.save(key: key, data: null);
      }
    }
    return;
  }



  static Future<void> _saveOnce({required String key, dynamic data}) async {
    if (!YkStorage._getInstance()._onceCache.contains(key)) {
      YkStorage._getInstance()._onceCache.add(key);
      await YkStorage._getInstance()._delegate?.save(key: _straget_once_key, data: YkStorage._getInstance()._onceCache);
    }
    return _saveCache(key: key, data: data);
  }

  static Future<void> _saveCache({required String key, dynamic data}) async {
    if (!YkStorage._getInstance()._Cache.contains(key)) {
      YkStorage._getInstance()._Cache.add(key);
      await YkStorage._getInstance()._delegate?.save(key: _straget_cache_key, data: YkStorage._getInstance()._Cache);
    }
    return _save(key: key, data: data);
  }

  static Future<void> _save({required String key, dynamic data}) async {
    if (YkStorage._getInstance()._delegate != null) {
      return YkStorage._getInstance()._delegate!.save(key: key, data: data);
    } else {
      return null;
    }
  }

}
