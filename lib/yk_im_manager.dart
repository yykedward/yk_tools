import 'dart:async';
import 'package:flutter/material.dart';


mixin YkImManagerDelegate {

  Future init(Function(dynamic message)? receiveMessageCallBack, Function()? kickedOffline, dynamic params);

  Future dispose();

  Future login(dynamic params);

  Future logout(dynamic params);

  Future joinGroup(String groupId, dynamic params);

  Future quickGroup(String? groupId, dynamic params);

  Future<dynamic> sendMessage(String? groupId, String? content, String? imagePath, String? customerData, dynamic params);
}

class YkImManager {

  static YkImManager? _instance;

  static YkImManager get instance {
    _instance ??= YkImManager._();
    return _instance!;
  }

  YkImManager._();

  YkImManagerDelegate? _delegate;

  StreamController<dynamic> _streamController = StreamController.broadcast();

  Stream<dynamic> get stream => _streamController.stream;

  Function()? onKickedOfflineCallBack;

  Future config({required YkImManagerDelegate delegate}) async {
    _delegate = delegate;
    return;
  }

  Future init({dynamic params}) async {
    return _delegate?.init((data) {
      _streamController.sink.add(data);
    }, () {
      onKickedOfflineCallBack?.call();
    }, params) ?? Future.value();
  }

  Future dispose() async {
    await _delegate?.dispose();
    _delegate = null;
    return;
  }

  Future login({dynamic params}) {
    return _delegate?.login(params) ?? Future.value();
  }

  Future logout({dynamic params}) {
    return _delegate?.logout(params) ?? Future.value();
  }

  Future joinGroup({required String groupId, dynamic params}) {
    return _delegate?.joinGroup(groupId, params) ?? Future.value();
  }

  Future quickGroup(String? groupId, dynamic params) {
    return _delegate?.quickGroup(groupId, params) ?? Future.value();
  }

  Future<dynamic> sendMessage({String? groupId, String? content, String? imagePath, String? customerData, dynamic params}) {
    return _delegate?.sendMessage(groupId, content, imagePath, customerData, params) ?? Future.value();
  }

}