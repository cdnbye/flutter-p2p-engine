import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  /// Get the peer ID of p2p engine
  Future<String> getPeerId() => _instance.getPeerId();
}

/// Print log level.
enum P2pLogLevel {
  none,
  debug,
  info,
  warn,
  error,
}

/// tracker服务器地址所在国家的枚举
enum TrackerZone {
  Europe,
  HongKong,
  USA,
}

/// The configuration of p2p engine.
class P2pConfig {
  final P2pLogLevel logLevel;
  final bool logEnabled;
  final String? wsSignalerAddr;
  final String? announce;
  final int? diskCacheLimit;
  final int? memoryCacheCountLimit;
  final bool p2pEnabled;
  final Duration? downloadTimeout;
  final Duration? dcDownloadTimeout;
  final String? tag;
  final int localPortHls;
  final int localPortDash;
  final int? maxPeerConnections;
  final bool useHttpRange;
  final bool wifiOnly;
  final Map<String, String>? httpHeadersForHls;
  final Map<String, String>? httpHeadersForDash;
  final bool isSetTopBox;
  final int? httpLoadTime;
  final bool sharePlaylist;
  final bool logPersistent;
  final bool? fastStartup;
  final bool? geoIpPreflight;
  final bool? useStrictHlsSegmentId;
  final List<String>? hlsMediaFiles;
  final String? mediaFileSeparator;
  final double? playlistTimeOffset;
  final int? maxMediaFilesInPlaylist;
  final TrackerZone? trackerZone;

  P2pConfig({
    this.logLevel = P2pLogLevel.warn,
    this.wsSignalerAddr, //: 'wss://signal.cdnbye.com',
    this.announce, //: 'https://tracker.cdnbye.com/v1',
    this.diskCacheLimit,
    this.memoryCacheCountLimit,
    this.p2pEnabled = true,
    this.downloadTimeout,
    this.dcDownloadTimeout,
    this.tag,
    this.localPortHls = 0,
    this.localPortDash = 0,
    this.maxPeerConnections,
    this.useHttpRange = true,
    this.wifiOnly = false,
    this.httpHeadersForHls,
    this.httpHeadersForDash,
    this.isSetTopBox = false,
    this.logEnabled = false,
    this.httpLoadTime,
    this.logPersistent = false,
    this.sharePlaylist = false,
    this.hlsMediaFiles,
    this.mediaFileSeparator,
    this.trackerZone,
    this.playlistTimeOffset,
    this.maxMediaFilesInPlaylist,
    this.fastStartup,
    this.geoIpPreflight,
    this.useStrictHlsSegmentId,
  });

  P2pConfig.byDefault() : this();

  Map<String, dynamic> get toMap => {
    'logEnabled': logEnabled,
    'logLevel': logLevel.index,
    'wsSignalerAddr': wsSignalerAddr,
    'announce': announce,
    'diskCacheLimit': diskCacheLimit,
    'memoryCacheCountLimit': memoryCacheCountLimit,
    'p2pEnabled': p2pEnabled,
    'downloadTimeout': downloadTimeout?.inSeconds,
    'dcDownloadTimeout': dcDownloadTimeout?.inSeconds,
    'tag': tag,
    'localPortHls': localPortHls,
    'localPortDash': localPortDash,
    'maxPeerConnections': maxPeerConnections,
    'useHttpRange': useHttpRange,
    'wifiOnly': wifiOnly,
    'httpHeadersForHls': httpHeadersForHls ?? {},
    'httpHeadersForDash': httpHeadersForDash ?? {},
    'isSetTopBox': isSetTopBox,
    'httpLoadTime': httpLoadTime,
    'sharePlaylist': sharePlaylist,
    'logPersistent': logPersistent,
    'hlsMediaFiles': hlsMediaFiles,
    'trackerZone': trackerZone?.index,
    'mediaFileSeparator': mediaFileSeparator,
    'playlistTimeOffset': playlistTimeOffset,
    'maxMediaFilesInPlaylist': maxMediaFilesInPlaylist,
    'fastStartup': fastStartup,
    'geoIpPreflight': geoIpPreflight,
    'useStrictHlsSegmentId': useStrictHlsSegmentId,
  };
}
