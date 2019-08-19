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
      _channel.setMethodCallHandler((call) async {
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
  final int diskCacheLimit;
  final int memoryCacheLimit;
  final bool p2pEnabled;
  final int packetSize;
  final Duration downloadTimeout;
  final Duration dcDownloadTimeout;
  final String tag;
  final int localPort;
  final int maxPeerConnections;

  P2pConfig({
    this.logLevel: P2pLogLevel.warn,
    this.webRTCConfig: const {}, // TODO: 默认值缺少
    this.wsSignalerAddr: 'wss://signal.cdnbye.com/wss',
    this.announce: 'https://api.cdnbye.com/v1',
    this.diskCacheLimit: 1024 * 1024 * 1024,
    this.memoryCacheLimit: 60 * 1024 * 1024,
    this.p2pEnabled: true,
    this.packetSize: 64 * 1024,
    this.downloadTimeout: const Duration(seconds: 10),
    this.dcDownloadTimeout: const Duration(seconds: 4),
    this.tag: "flutter",
    this.localPort: 52019,
    this.maxPeerConnections: 10,
  });

  P2pConfig.byDefault() : this();

  Map get toMap => {
        'logLevel': logLevel.index,
        'webRTCConfig': webRTCConfig,
        'wsSignalerAddr': wsSignalerAddr,
        'announce': announce,
        'diskCacheLimit': diskCacheLimit,
        'memoryCacheLimit': memoryCacheLimit,
        'p2pEnabled': p2pEnabled,
        'packetSize': packetSize,
        'downloadTimeout': downloadTimeout.inSeconds,
        'dcDownloadTimeout': dcDownloadTimeout.inSeconds,
        'tag': tag,
        'localPort': localPort,
        'maxPeerConnections': maxPeerConnections,
      };
}
