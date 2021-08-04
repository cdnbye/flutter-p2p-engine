import 'package:flutter/cupertino.dart';

class CdnByeListener {
  // 工厂模式
  factory CdnByeListener() => _getInstance()!;
  static CdnByeListener? get instance => _getInstance();
  static CdnByeListener? _instance;
  CdnByeListener._internal() {
    // 初始化
    videoInfo = ValueNotifier({});
  }
  static CdnByeListener? _getInstance() {
    if (_instance == null) {
      _instance = CdnByeListener._internal();
    }
    return _instance;
  }

  late ValueNotifier<Map> videoInfo;
}
