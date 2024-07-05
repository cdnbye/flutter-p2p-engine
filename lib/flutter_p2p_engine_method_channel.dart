import 'package:flutter/services.dart';
import 'flutter_p2p_engine.dart';
import 'flutter_p2p_engine_platform_interface.dart';

/// An implementation of [FlutterP2pEnginePlatform] that uses method channels.
class MethodChannelFlutterP2pEngine extends FlutterP2pEnginePlatform {
  /// The method channel used to interact with the native platform.
  final _channel = const MethodChannel('p2p_engine');

  static Duration Function()? _bufferedDurationGenerator;

  static bool _bufferedDurationGeneratorEnable = false;

  static const EventChannel _eventChannel = EventChannel('p2p_engine_stats');

  /// Create a new instance with token and the specified config.
  @override
  Future<int> init(
      token, {
        required P2pConfig config,
        void Function(Map<String, dynamic>)? infoListener,
        bool bufferedDurationGeneratorEnable = false, // 是否可以给SDK提供缓冲前沿到当前播放时间的差值
      }) async {
    _bufferedDurationGeneratorEnable = bufferedDurationGeneratorEnable;
    final int? success = await _channel.invokeMethod('init', {
      'token': token,
      'config': config.toMap,
      'enableBufferedDurationGenerator': bufferedDurationGeneratorEnable,
    });
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'bufferedDuration') {
        var duration = _bufferedDurationGenerator?.call();
        return {'result': duration?.inSeconds ?? -1};
      }
      return {"success": true};
    });

    if (infoListener != null) {
        _eventChannel.receiveBroadcastStream().listen(
            (dynamic event) {
          var map = Map<String, dynamic>.from(event);
          infoListener.call(map);
        },
        onError: (dynamic error) {
          // print('Received error: ${error.message}');
        },
        cancelOnError: true);
    }

    if (success == null) {
      throw 'Not Avaliable Result: $success. Init fail.';
    }
    return success;
  }

  /// Get parsed local stream url by passing the original stream url(m3u8) to CBP2pEngine instance.
  @override
  Future<String> parseStreamURL(
      String sourceUrl, {
        String? videoId,
        Duration Function()? bufferedDurationGenerator,
      }) async {
    if (_bufferedDurationGeneratorEnable && bufferedDurationGenerator == null) {
      throw 'Must provide bufferedDurationGenerator if bufferedDurationGeneratorEnable was set true';
    }
    if (!_bufferedDurationGeneratorEnable &&
        bufferedDurationGenerator != null) {
      throw 'Must set bufferedDurationGeneratorEnable true before set bufferedDurationGenerator';
    }
    _bufferedDurationGenerator = bufferedDurationGenerator;
    final String url = await _channel.invokeMethod('parseStreamURL', {
      'url': sourceUrl,
      'videoId': videoId ?? sourceUrl,
    });
    // print('mobile parse R:$url S:$sourceUrl ');
    return url;
  }

  /// Get the connection state of p2p engine. 获取P2P Engine的连接状态
  @override
  Future<bool> isConnected() async =>
      (await _channel.invokeMethod('isConnected')) == true;

  /// Restart p2p engine.
  @override
  Future<void> restartP2p() => _channel.invokeMethod('restartP2p');

  @override
  Future<void> disableP2p() => _channel.invokeMethod('disableP2p');

  /// Stop p2p and free used resources.
  @override
  Future<void> stopP2p() => _channel.invokeMethod('stopP2p');

  @override
  Future<void> enableP2p() => _channel.invokeMethod('enableP2p');

  @override
  Future<void> shutdown() => _channel.invokeMethod('shutdown');

  @override
  Future<void> notifyPlaybackStalled() => _channel.invokeMethod('notifyPlaybackStalled');

  /// Get the peer ID of p2p engine. 获取P2P Engine的peer ID
  @override
  Future<String> getPeerId() async =>
      (await _channel.invokeMethod('getPeerId')) ?? '';

  @override
  Future<String> getSDKVersion() async =>
      (await _channel.invokeMethod('getSDKVersion')) ?? '';
}
