

import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

class YKRefreshController<T> {

  Future Function()? _callRefresh;
  Future Function()? _callLoad;
  Future Function()? _endRefresh;
  Future Function(bool noMoreData)? _endLoad;

  Future callRefresh() {
    return _callRefresh?.call() ?? Future.value();
  }

  Future callLoad() {
    return _callLoad?.call() ?? Future.value();
  }

  Future endRefresh() {
    return _endRefresh?.call() ?? Future.value();
  }

  Future endLoad(bool noMoreData) {
    return _endLoad?.call(noMoreData) ?? Future.value();
  }
}

class YKRefreshWidget<T> extends StatefulWidget {
  final Widget Function(List<T> list) builder;
  final YKRefreshController controller;
  Future<List<T>> Function()? onRefresh;
  Future<List<T>> Function(int page)? onLoad;

  YKRefreshWidget({super.key, required this.builder, required this.controller, this.onRefresh, this.onLoad});

  @override
  State<YKRefreshWidget<T>> createState() => _YKRefreshWidgetState<T>();
}

class _YKRefreshWidgetState<T> extends State<YKRefreshWidget<T>> {

  final List<T> _list = [];
  int _currentPage = 1;
  late EasyRefreshController _controller;
  bool _didDispose = false;

  @override
  void initState() {
    _controller = EasyRefreshController(controlFinishRefresh: widget.onRefresh != null, controlFinishLoad: widget.onLoad != null);

    widget.controller._callRefresh = () async {
      await _controller.callRefresh();
      return;
    };

    widget.controller._callLoad = () async {
      await _controller.callLoad();
      return;
    };

    widget.controller._endRefresh = () async {
      if (!_didDispose) {
        setState(() {

        });
      }
      _controller.finishLoad(IndicatorResult.success);
      return;
    };

    widget.controller._endLoad = (noMoreData) async {
      if (!_didDispose) {
        setState(() {

        });
      }
      if (noMoreData) {
        _controller.finishLoad(IndicatorResult.noMore);
      } else {
        _controller.finishLoad(IndicatorResult.success);
      }
      return;
    };

    _requestHeader();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _didDispose = true;
    super.dispose();
  }

  Future _requestHeader() async {
    final result = await widget.onRefresh?.call();
    if (result != null && result.isNotEmpty) {
      _list.clear();
      _list.addAll(result);
    }
    if (!_didDispose) {
      setState(() {

      });
    }
    _controller.finishRefresh(IndicatorResult.success);
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("暂无数据"),
            SizedBox(height: 10),
            TextButton(onPressed: () {
              _requestHeader();
            }, child: Container(
              constraints: BoxConstraints(maxWidth: 50, minHeight: 30),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Center(
                child: Text("刷新", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ))
          ],
        ),
      );
    }

    return _refreshList();
  }

  Widget _refreshList() {
    return EasyRefresh(
      controller: _controller,
      onRefresh: () async {
        await _requestHeader();
      },
      onLoad: () async {
        final thisPath = _currentPage + 1;
        final result = await widget.onLoad?.call(_currentPage);
        if (result != null) {
          if (result.isNotEmpty) {
            _list.addAll(result);
            _currentPage = thisPath;
            if (!_didDispose) {
              setState(() {

              });
            }
            _controller.finishLoad(IndicatorResult.success);
          } else {
            if (!_didDispose) {
              setState(() {

              });
            }
            _controller.finishLoad(IndicatorResult.noMore);
          }
        } else {
          if (!_didDispose) {
            setState(() {

            });
          }
          _controller.finishLoad(IndicatorResult.success);
        }
      },
      child: widget.builder.call(_list),
    );
  }
}