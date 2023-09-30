
import 'flutter_p2p_engine_platform_interface.dart';

class FlutterP2pEngine {
  static FlutterP2pEnginePlatform get _platform => FlutterP2pEnginePlatform.instance;

  /// Create a new instance with token and the specified config.
  static Future<int> init(
      token, {
        required P2pConfig config,
        void Function(Map<String, dynamic>)? infoListener,
        bufferedDurationGeneratorEnable = false,
      }) =>
      _platform.init(
        token,
        config: config,
        infoListener: infoListener,
        bufferedDurationGeneratorEnable: bufferedDurationGeneratorEnable
      );

  /// Get parsed local stream url by passing the original stream url(m3u8) to CBP2pEngine instance.
  static Future<String?> parseStreamURL(
      String sourceUrl, {
        String? videoId,
        Duration Function()? bufferedDurationGenerator,
      }) =>
      _platform.parseStreamURL(
        sourceUrl,
        videoId: videoId,
        bufferedDurationGenerator: bufferedDurationGenerator,
      );

  /// Get the connection state of p2p engine. 获取P2P Engine的连接状态
  static Future<bool> isConnected() => _platform.isConnected();

  /// Restart p2p engine.
  static Future<void> restartP2p() => _platform.restartP2p();

  /// Stop p2p and free used resources.
  static Future<void> stopP2p() => _platform.stopP2p();

  /// Get the peer ID of p2p engine. 获取P2P Engine的peer ID
  static Future<String> getPeerId() => _platform.getPeerId();

  static Future<String> getSDKVersion() => _platform.getSDKVersion();

  static Future<void> notifyPlaybackStalled() => _platform.notifyPlaybackStalled();
}
