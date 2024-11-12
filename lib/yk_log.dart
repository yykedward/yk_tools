
import 'package:flutter/cupertino.dart';

enum YKLogType {
  DEBUG,
  RELEASE
}

class YKLog {

  static log(String msg, {YKLogType type = YKLogType.RELEASE}) {
    if (type == YKLogType.DEBUG) {
      debugPrint("YKLog: $msg");
    }
  }
}