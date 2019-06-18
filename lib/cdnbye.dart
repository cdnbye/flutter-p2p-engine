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
      {P2pConfig config, CdnByeInfoListener infoListener}) async {
    final int success = await _channel.invokeMethod('init', {
      'token': token,
      'config': config.toMap,
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

enum P2pLogLevel {
  none,
  debug,
  info,
  warn,
  error,
}

class P2pConfig {
  final P2pLogLevel logLevel;
  final Map webRTCConfig;
  final String wsSignalerAddr;
  final String announce;
  final int maxBufferSize;
  final bool p2pEnabled;
  final int packetSize;
  final Duration downloadTimeout;
  final Duration dcDownloadTimeout;
  final Duration dcUploadTimeout;
  final String tag;
  final String agent;

  P2pConfig({
    this.logLevel: P2pLogLevel.none,
    this.webRTCConfig: const {},
    this.wsSignalerAddr: '@"wss://signal.cdnbye.com/wss"',
    this.announce: 'https://tracker.cdnbye.com:8090', // TODO: 默认值缺少
    this.maxBufferSize: 1024 * 1024 * 1024,
    this.p2pEnabled: true,
    this.packetSize: 64 * 1024,
    this.downloadTimeout: const Duration(milliseconds: 10),
    this.dcDownloadTimeout: const Duration(milliseconds: 4),
    this.dcUploadTimeout: const Duration(milliseconds: 6),
    this.tag: "unknown",
    this.agent: '', // TODO: 默认值缺少
  });

  P2pConfig.byDefault() : this();

  Map get toMap => {
        'logLevel': logLevel.index,
        'webRTCConfig': webRTCConfig,
        'wsSignalerAddr': wsSignalerAddr,
        'announce': announce,
        'maxBufferSize': maxBufferSize,
        'p2pEnabled': p2pEnabled,
        'packetSize': packetSize,
        'downloadTimeout': downloadTimeout.inMilliseconds,
        'dcDownloadTimeout': dcDownloadTimeout.inMilliseconds,
        'dcUploadTimeout': dcUploadTimeout.inMilliseconds,
        'tag': tag,
        'agent': agent,
      };
}
