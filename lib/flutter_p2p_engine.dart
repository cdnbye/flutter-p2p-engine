
import 'flutter_p2p_engine_platform_interface.dart';

const String version = "1.2.4";

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
  final String? signalConfig;
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
  final bool prefetchOnly;
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
  final List<String>? dashMediaFiles;
  final String? mediaFileSeparator;
  final double? playlistTimeOffset;
  final int? maxMediaFilesInPlaylist;
  final TrackerZone? trackerZone;

  P2pConfig({
    this.logLevel = P2pLogLevel.warn,
    this.signalConfig, //: 'wss://signal.cdnbye.com',
    this.announce, //: 'https://tracker.cdnbye.com/v1',
    this.diskCacheLimit,
    this.memoryCacheCountLimit,
    this.p2pEnabled = true,
    this.downloadTimeout,
    this.dcDownloadTimeout,
    this.tag = "flutter-$version",
    this.localPortHls = 0,
    this.localPortDash = 0,
    this.maxPeerConnections,
    this.useHttpRange = true,
    this.wifiOnly = false,
    this.prefetchOnly = false,
    this.httpHeadersForHls,
    this.httpHeadersForDash,
    this.isSetTopBox = false,
    this.logEnabled = false,
    this.httpLoadTime,
    this.logPersistent = false,
    this.sharePlaylist = false,
    this.hlsMediaFiles,
    this.dashMediaFiles,
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
    'signalConfig': signalConfig,
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
    'prefetchOnly': prefetchOnly,
    'httpHeadersForHls': httpHeadersForHls ?? {},
    'httpHeadersForDash': httpHeadersForDash ?? {},
    'isSetTopBox': isSetTopBox,
    'httpLoadTime': httpLoadTime,
    'sharePlaylist': sharePlaylist,
    'logPersistent': logPersistent,
    'hlsMediaFiles': hlsMediaFiles,
    'dashMediaFiles': dashMediaFiles,
    'trackerZone': trackerZone?.index,
    'mediaFileSeparator': mediaFileSeparator,
    'playlistTimeOffset': playlistTimeOffset,
    'maxMediaFilesInPlaylist': maxMediaFilesInPlaylist,
    'fastStartup': fastStartup,
    'geoIpPreflight': geoIpPreflight,
    'useStrictHlsSegmentId': useStrictHlsSegmentId,
  };
}