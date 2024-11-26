

import 'dart:async';
import 'package:flutter/material.dart';

mixin YkImManagerDelegate {

  Future init(dynamic params);

  Future dispose();

  Future login(dynamic params);

  Future logout(dynamic params);

  Future<dynamic> sendMessage(dynamic);

  /// 加入群组
  @optionalTypeArgs
  Future joinGroup(dynamic params) async {
    return;
  }

  /// 退出群组
  @optionalTypeArgs
  Future quickGroup(dynamic params) async {
    return;
  }
  
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

  Future init(dynamic params) async {
    await _delegate?.init(params);
    return;
  }

  Future dispose() async {
    await _delegate?.dispose();
    _delegate = null;
    return;
  }

  Future login(dynamic params) async {
    await _delegate?.login(params);
    return;
  }

  Future logout(dynamic params) async {
    await _delegate?.logout(params);
    return;
  }

  Future joinGroup(dynamic params) async {
    await _delegate?.joinGroup(params);
    return;
  }

  Future<dynamic> sendMessage(dynamic) async {
    await _delegate?.sendMessage(dynamic);
    return;
  }

  Future quickGroup(dynamic params) async {
    await _delegate?.quickGroup(params);
    return;
  }
}