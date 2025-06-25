import 'dart:async';

class YKNotification {
  final String name;

  final dynamic object;

  final Map<String, dynamic>? userInfo;

  YKNotification(this.name, this.object, this.userInfo);
}

typedef YKNotificationCenterCallBack = void Function(YKNotification notification)?;

class YKNotificationCenter {
  static YKNotificationCenter? _instance;

  static YKNotificationCenter get instance {
    _instance ??= YKNotificationCenter._();
    return _instance!;
  }

  YKNotificationCenter._();

  final StreamController<Map<String, YKNotification>> _observerStream = StreamController<Map<String, YKNotification>>.broadcast();

  void post(String name, {dynamic object, Map<String, dynamic>? userInfo}) {
    final notification = YKNotification(name, object, userInfo);
    _observerStream.sink.add({name: notification});
  }

  StreamSubscription addObserver(String name, YKNotificationCenterCallBack callBack) {
    return _observerStream.stream.listen((event) {
      final notification = event[name];
      if (notification != null) {
        callBack?.call(notification!);
      }
    });
  }
}
