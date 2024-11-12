
import 'dart:async';
import 'package:flutter/material.dart';


mixin YKCameraPhotoDelegate {
  
  Future<void> setup();

  Future<bool> checkAut();

  Future<dynamic> pickPhoto(dynamic params);

}

class YKCameraPhoto {
  bool get isGrant => _isGrant;

  static YKCameraPhoto? _instance;
  bool _isGrant = false;
  YKCameraPhotoDelegate? delegate;

  factory YKCameraPhoto._getInstance() {
    _instance ??= YKCameraPhoto._();
    return _instance!;
  }

  YKCameraPhoto._();

  static void setup({required YKCameraPhotoDelegate delegate}) async {
    YKCameraPhoto._getInstance().delegate = delegate;
    await delegate.setup();
  }

  static Future<bool> _checkAut() async {
    final delegate = YKCameraPhoto._getInstance().delegate;
    if (delegate != null) {
      return await delegate.checkAut();
    } else {
      return false;
    }
  }

  static Future<dynamic> picker({required dynamic params}) async {
    final isGrant = await YKCameraPhoto._checkAut();
    final delegate = YKCameraPhoto._getInstance().delegate;
    if (isGrant && delegate != null) {
      return delegate.pickPhoto(params);
    } else {
      throw Exception(['未获取权限，或未设置代理']);
    }
  }
}
