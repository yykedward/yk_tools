

import 'package:flutter/material.dart';

class YkParamsUtil {

  static YkParamsUtil? _instance;

  static YkParamsUtil get instance {
    _instance ??= YkParamsUtil._();
    return _instance!;
  }

  YkParamsUtil._();

  Map<String,dynamic> _params = Map();

  bool _isProduct = true;

  static void config({required Map<String,dynamic> params, required bool isProduct}) {

    YkParamsUtil.instance._params = params;
    YkParamsUtil.instance._isProduct = isProduct;
  }

  static Future<dynamic> get({String? key = null, Future<dynamic> Function()? debugCallBack = null, Future<dynamic> Function()? productCallBack = null}) async {

    if (key != null) {
      if (YkParamsUtil.instance._params.keys.contains(key)) {
        return YkParamsUtil.instance._params[key];
      } else {
        if (YkParamsUtil.instance._isProduct) {
          final result = await productCallBack?.call();
          return result;
        } else {
          final result = await debugCallBack?.call();
          return result;
        }
      }
    } else if (YkParamsUtil.instance._isProduct) {
      final result = await productCallBack?.call();
      return result;
    } else {
      final result = await debugCallBack?.call();
      return result;
    }
  }
}
