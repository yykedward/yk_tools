mixin YkInAppPushUtilDelegate {
  String targetId();

  Future show(Future Function() onNext);

  Future end();
}

class YkInAppPushUtil {
  // 单例实现
  static final instance = YkInAppPushUtil._();

  YkInAppPushUtil._();

  YkInAppPushUtilDelegate? _currentDelegate;

  List<YkInAppPushUtilDelegate> _delegates = [];

  List<YkInAppPushUtilDelegate> get delegates => _delegates;

  bool Function()? canNext;

  void add({required YkInAppPushUtilDelegate delegate, bool endLastPush = false}) async {
    if (_currentDelegate == null) {
      _delegates.add(delegate);
      _next();
    } else {
      List<YkInAppPushUtilDelegate> newList = [];
      for (final model in _delegates) {
        if (model.targetId() != delegate.targetId()) {
          newList.add(model);
        }
      }
      newList.add(delegate);
      _delegates = newList;
      if (endLastPush) {
        if (_currentDelegate?.targetId() == delegate.targetId()) {
          end();
        }
      }
    }
  }

  void _next() {
    if (_delegates.isNotEmpty) {
      final delegate = _delegates.removeAt(0);
      _currentDelegate = delegate;
      _currentDelegate?.show(() async {
        await end();
        _next();
      });
    }
  }

  Future end() async {
    await _currentDelegate?.end().then((value) {
      _currentDelegate = null;
      return;
    });
    return;
  }
}
