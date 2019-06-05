import 'dart:async';

import 'package:flutter/services.dart';

typedef CdnByeInfoListener = void Function(Map);

class Cdnbye {
  static const MethodChannel _channel = const MethodChannel('cdnbye');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> init(token,
      {Map config, CdnByeInfoListener infoListener}) async {
    final int success = await _channel.invokeMethod('init', {
      'token': token,
      'config': config,
    });
    if (infoListener != null) {
      await _channel.invokeMethod('startListen');
      _channel.setMethodCallHandler((call) {
        if (call.method == 'info') {
          infoListener(call.arguments);
        }
      });
    }
    return success;
  }

  static Future<String> parseStreamURL(String sourceUrl) async {
    final String url = await _channel.invokeMethod('parseStreamURL', {
      'url': sourceUrl,
    });
    return url;
  }


}
