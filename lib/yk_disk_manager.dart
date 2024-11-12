
import 'dart:core';

mixin YKDiskManagerModuleMixin {

  Future<dynamic> endModule(String module, Map<String,dynamic> params);

  Future<dynamic> executeModule(Map<String,dynamic> params);
}

class YKDiskManager {

  static YKDiskManager? _instance;

  static YKDiskManager get instance {
    _instance ??= YKDiskManager._();
    return _instance!;
  }

  YKDiskManager._();

  final _handlerMap = <String,YKDiskManagerModuleMixin>{};

  static void append(String module, YKDiskManagerModuleMixin mixin) {
    YKDiskManager.instance._handlerMap.addAll({module:mixin});
  }

  static Future<dynamic> openModule(String module, Map<String,dynamic> params, {void Function(Object exception)? errorCallBack}) async {
    bool isTermiated = false;

    for (var element in YKDiskManager.instance._handlerMap.keys) {
      final handler = YKDiskManager.instance._handlerMap[element];
      if (handler != null) {
        try {
          final result = await handler!.endModule(module, params);
        } catch (e) {
          isTermiated = true;
          errorCallBack?.call(e);
        }
      }
    }

    if (!isTermiated) {
      final handler = YKDiskManager.instance._handlerMap[module];
      if (handler != null) {
        return await handler!.executeModule(params);
      } else {
        return null;
      }
    } else {
      return null;
    }

  }
}