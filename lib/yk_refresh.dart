

import 'package:flutter/material.dart';

class YKRefreshConfigDelegate {

  Future<void> Function()? beginRefresh;

  Future<void> Function()? beginLoad;

  Future<void> Function()? endRefresh;

  Future<void> Function(bool isNoMoreData)? endLoad;

  YKRefreshConfigDelegate({this.beginRefresh, this.beginLoad, this.endRefresh, this.endLoad});
}

class YKRefreshConfig {

  static YKRefreshConfig? _instance;
  static YKRefreshConfig get instance {
    _instance ??= YKRefreshConfig._();
    return _instance!;
  }

  Widget Function(Widget widget, YKRefreshController? controller)? handleCallBack;

  YKRefreshConfig._();
}

class YKRefreshController {

  YKRefreshWidget? _widget;

  YKRefreshConfigDelegate? delegate;

  void Function()? headerCallBack;
  void Function()? footerCallBack;

  YKRefreshController({this.headerCallBack, this.footerCallBack});

  void _setup({YKRefreshWidget? widget}) {
    _widget = widget;
  }

  Future<void> beginRefresh() async {
    return delegate?.beginRefresh?.call();
  }

  Future<void> beginLoad() async {
    return delegate?.beginLoad?.call();
  }

  Future<void> endRefresh() async {
    return delegate?.endRefresh?.call();
  }

  Future<void> endLoad(bool isNoMoreData) async {
    return delegate?.endLoad?.call(isNoMoreData);
  }
}

class YKRefreshWidget extends StatelessWidget {

  final Widget child;

  YKRefreshController? _controller;

  Widget? _refreshHandleWidget;

  YKRefreshWidget({super.key, required this.child, YKRefreshController? controller}) {
    _controller = controller;
    _controller?._setup(widget: this);
    _refreshHandleWidget = YKRefreshConfig.instance.handleCallBack?.call(child, _controller);
  }

  @override
  Widget build(BuildContext context) {

    final widget = _refreshHandleWidget ?? child;

    return widget;
  }
}