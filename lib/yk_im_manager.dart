

import 'dart:async';
import 'package:flutter/material.dart';

mixin YkImManagerDelegate {

  Future init(dynamic params);

  Future dispose();

  Future login(dynamic params);

  Future logout(dynamic params);

  Future<dynamic> sendMessage(dynamic);
}

class YkImManager {

  static YkImManager? _instance;

  static YkImManager get instance {
    _instance ??= YkImManager._();
    return _instance!;
  }

  YkImManager._();

  YkImManagerDelegate? _delegate;

  Future config({required YkImManagerDelegate delegate}) async {
    _delegate = delegate;
    return;
  }

  Future init(dynamic params) {
    return _delegate?.init(params) ?? Future.value();
  }

  Future dispose() async {
    await _delegate?.dispose();
    _delegate = null;
    return;
  }

  Future login(dynamic params) {
    return _delegate?.login(params) ?? Future.value();
  }

  Future logout(dynamic params) {
    return _delegate?.logout(params) ?? Future.value();
  }
  
  Future<dynamic> sendMessage(dynamic) {
    return _delegate?.sendMessage(dynamic) ?? Future.value();
  }

}