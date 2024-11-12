library ykftools;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

mixin YKImagePickerDelegate {

  Future<void> setup();

  Future<bool> checkAut();

  Future<dynamic> pickImage(dynamic params, int maxCount);
}

class YKImagePicker {
  bool get isGrant => _isGrant;

  static YKImagePicker? _instance;
  bool _isGrant = false;
  YKImagePickerDelegate? delegate;

  factory YKImagePicker._getInstance() {
    _instance ??= YKImagePicker._();
    return _instance!;
  }

  YKImagePicker._();

  static void setup({required YKImagePickerDelegate delegate}) async {
    YKImagePicker._getInstance().delegate = delegate;
    await delegate.setup();
  }

  static Future<bool> _checkAut() async {
    if (YKImagePicker
        ._getInstance()
        .delegate != null) {
      var isGrant = await YKImagePicker._getInstance().delegate!.checkAut();
      return isGrant;
    } else {
      return false;
    }
  }

  static Future<dynamic> picker({required dynamic params, int maxCount = 9}) async {
    final isGrant = await YKImagePicker._checkAut();
    final delegate = YKImagePicker._getInstance().delegate;
    if (delegate != null && isGrant) {
      return await delegate.pickImage(params, maxCount);
    } else {
      print("未设置获取权限");
    }
  }
}
