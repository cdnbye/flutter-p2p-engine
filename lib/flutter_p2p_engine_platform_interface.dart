import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_p2p_engine.dart';
import 'flutter_p2p_engine_method_channel.dart';

abstract class FlutterP2pEnginePlatform extends PlatformInterface {
  /// Constructs a P2pEnginePlatform.
  FlutterP2pEnginePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterP2pEnginePlatform _instance = MethodChannelFlutterP2pEngine();

  /// The default instance of [P2pEnginePlatform] to use.
  ///
  /// Defaults to [MethodChannelP2pEngine].
  static FlutterP2pEnginePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [P2pEnginePlatform] when
  /// they register themselves.
  static set instance(FlutterP2pEnginePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Create a new instance with token and the specified config.
  Future<int> init(
      token, {
        required P2pConfig config,
        void Function(Map<String, dynamic>)? infoListener,
        bool bufferedDurationGeneratorEnable = false, // 是否可以给SDK提供缓冲前沿到当前播放时间的差值
      }) =>
      _instance.init(
        token,
        config: config,
        infoListener: infoListener,
        bufferedDurationGeneratorEnable: bufferedDurationGeneratorEnable,
      );

  /// Get parsed local stream url by passing the original stream url(m3u8) to CBP2pEngine instance.
  Future<String> parseStreamURL(
      String sourceUrl, {
        String? videoId,
        Duration Function()? bufferedDurationGenerator,
      }) =>
      _instance.parseStreamURL(
        sourceUrl,
        videoId: videoId,
        bufferedDurationGenerator: bufferedDurationGenerator,
      );

  Future<String> getSDKVersion() => _instance.getSDKVersion();

  /// Get the connection state of p2p engine.
  Future<bool> isConnected() => _instance.isConnected();

  /// Restart p2p engine.
  Future<void> restartP2p() => _instance.restartP2p();

  /// Stop p2p and free used resources.
  Future<void> stopP2p() => _instance.stopP2p();

  Future<void> shutdown() => _instance.shutdown();

  Future<void> disableP2p() => _instance.disableP2p();

  Future<void> enableP2p() => _instance.enableP2p();

  Future<void> notifyPlaybackStalled() => _instance.notifyPlaybackStalled();

  Future<void> setHttpHeadersForHls(Map<String, String>? headers) => _instance.setHttpHeadersForHls(headers);

  Future<void> setHttpHeadersForDash(Map<String, String>? headers) => _instance.setHttpHeadersForDash(headers);

  /// Get the peer ID of p2p engine
  Future<String> getPeerId() => _instance.getPeerId();
}
