import Flutter
import UIKit
import SwarmCloudKit

public class FlutterP2pEnginePlugin: NSObject, FlutterPlugin {

    public init(_ channel: FlutterMethodChannel) {
        super.init()
        self.channel = channel
    }

    var sink: FlutterEventSink?
    var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "p2p_engine", binaryMessenger: registrar.messenger())
    let instance = FlutterP2pEnginePlugin(channel)
    FlutterEventChannel(name: "p2p_engine_stats", binaryMessenger: registrar.messenger()).setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    print(call.method)
    switch call.method {
    case "getSDKVersion":
        result(P2pEngine.VERSION)
    case "init": do {
        guard let arguments = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError(code: "argument_error",
                                message: "arguments must be dictionary",
                                details: nil))
            return
        }
        guard let token = arguments["token"] as? String else {
            result(FlutterError(code: "token_error",
                                message: "token not found",
                                details: nil))
            return
        }
        guard let configMap = arguments["config"] as? Dictionary<String, Any> else {
            result(FlutterError(code: "config_error",
                                message: "config must be dictionary",
                                details: nil))
            return
        }
        var logEnabled = configMap["logEnabled"] as? Bool ?? false
        var level: LogLevel
        switch configMap["logLevel"] as? Int {
        case 0: do {
            logEnabled = false
            level = .ERROR
        }
        case 1:
            level = .DEBUG
        case 2:
            level = .INFO
        case 3:
            level = .WARN
        case 4:
            level = .ERROR
        default:
            level = .ERROR
        }
        var zone: TrackerZone = .Europe
        switch configMap["trackerZone"] as? Int {
        case 1:
            zone = .HongKong
        case 2:
            zone = .USA
        default:
            zone = .Europe
        }
        let config = P2pConfig(
            trackerZone: zone
        )
        if let p2pEnabled = configMap["p2pEnabled"] as? Bool {
            config.p2pEnabled = p2pEnabled
        }
        config.debug = logEnabled
        config.logLevel = level
        if let wifiOnly = configMap["wifiOnly"] as? Bool {
            config.wifiOnly = wifiOnly
        }
        if let useHttpRange = configMap["useHttpRange"] as? Bool {
            config.useHttpRange = useHttpRange
        }
        if let localPortHls = configMap["localPortHls"] as? UInt {
            config.localPortHls = localPortHls
        }
        if let maxPeerConnections = configMap["maxPeerConnections"] as? Int {
            config.maxPeerConnections = maxPeerConnections
        }
        if let dcDownloadTimeout = configMap["dcDownloadTimeout"] as? TimeInterval {
            config.dcDownloadTimeout = dcDownloadTimeout
        }
        if let diskCacheLimit = configMap["diskCacheLimit"] as? UInt {
            config.diskCacheLimit = diskCacheLimit
        }
        if let memoryCacheCountLimit = configMap["memoryCacheCountLimit"] as? UInt {
            config.memoryCacheCountLimit = memoryCacheCountLimit
        }
        if let diskCacheLimit = configMap["diskCacheLimit"] as? UInt {
            config.diskCacheLimit = diskCacheLimit
        }
        if let signalConfig = configMap["signalConfig"] as? String {
            config.signalConfig = SignalConfig(mainAddr: signalConfig)
        }
        if let announce = configMap["announce"] as? String {
            config.announce = announce
        }
        if let tag = configMap["tag"] as? String {
            config.customLabel = tag
        }
        if let httpHeadersForHls = configMap["httpHeadersForHls"] as? Dictionary<String, String> {
            config.httpHeadersHls = httpHeadersForHls
        }
        if let httpLoadTime = configMap["httpLoadTime"] as? TimeInterval {
            config.httpLoadTime = httpLoadTime
        }
        if let logPersistent = configMap["logPersistent"] as? Bool {
            config.logPersistent = logPersistent
        }
        if let sharePlaylist = configMap["sharePlaylist"] as? Bool {
            config.sharePlaylist = sharePlaylist
        }
        if let hlsMediaFiles = configMap["hlsMediaFiles"] as? Array<String> {
            config.hlsMediaFiles = hlsMediaFiles
        }
        if let mediaFileSeparator = configMap["mediaFileSeparator"] as? String {
            config.mediaFileSeparator = mediaFileSeparator
        }
        if let maxMediaFilesInPlaylist = configMap["maxMediaFilesInPlaylist"] as? Int {
            config.maxMediaFilesInPlaylist = maxMediaFilesInPlaylist
        }
        if let fastStartup = configMap["fastStartup"] as? Bool {
            config.fastStartup = fastStartup
        }
        if let geoIpPreflight = configMap["geoIpPreflight"] as? Bool {
            config.geoIpPreflight = geoIpPreflight
        }
        if let useStrictHlsSegmentId = configMap["useStrictHlsSegmentId"] as? Bool {
            config.useStrictHlsSegmentId = useStrictHlsSegmentId
        }

        P2pEngine.setup(token: token, config: config)

        if arguments["enableBufferedDurationGenerator"] is Bool {
            P2pEngine.shared.playerInteractor = self
        }

        startMonitoring()

        result(1)
    }
    case "parseStreamURL": do {
        guard let arguments = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError(code: "argument_error",
                                message: "arguments must be dictionary",
                                details: nil))
            return
        }
        guard let url = arguments["url"] as? String else {
            result(FlutterError(code: "url_error",
                                message: "url not found",
                                details: nil))
            return
        }
        let videoId = arguments["videoId"] as? String
        var parsedUrl: String
        if videoId == nil {
            parsedUrl = P2pEngine.shared.parseStreamUrl(url)
        } else {
            parsedUrl = P2pEngine.shared.parseStreamUrl(url, videoId: videoId)
        }
        result(parsedUrl)
    }
    case "notifyPlaybackStalled": do {
        P2pEngine.shared.notifyPlaybackStalled()
        result(1)
    }
    case "isConnected": do {
        result(P2pEngine.shared.isConnected)
    }
    case "getPeerId": do {
        result(P2pEngine.shared.peerId)
    }
    case "restartP2p": do {
        P2pEngine.shared.restartP2p()
        result(1)
    }
    case "disableP2p": do {
        P2pEngine.shared.disableP2p()
        result(1)
    }
    case "stopP2p": do {
        P2pEngine.shared.stopP2p()
        result(1)
    }
    case "enableP2p": do {
        P2pEngine.shared.enableP2p()
        result(1)
    }
    case "shutdown": do {
        P2pEngine.shared.shutdown()
        result(1)
    }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

    func startMonitoring() {
        let monitor = P2pStatisticsMonitor()
        monitor.onPeers = { peers in
            let info = ["peers": peers]
            self.sink?(info)
        }
        monitor.onP2pUploaded = { value in
            let info = ["p2pUploaded": value]
            self.sink?(info)
        }
        monitor.onP2pDownloaded = { value, speed in
            let info = ["p2pDownloaded": value, "p2pDownloadSpeed": speed]
            self.sink?(info)
        }
        monitor.onHttpDownloaded = { value in
            let info = ["httpDownloaded": value]
            self.sink?(info)
        }
        monitor.onServerConnected = { connected in
            let info = ["serverConnected": connected]
            self.sink?(info)
        }
        P2pEngine.shared.p2pStatisticsMonitor = monitor
    }

}

extension FlutterP2pEnginePlugin : FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.sink = nil
        return nil
    }
}

extension FlutterP2pEnginePlugin : PlayerInteractor {
    public func onBufferedDuration() -> TimeInterval {
        let sema = DispatchSemaphore(value: 0)
        var bufferedDuration: TimeInterval = -1
        self.channel?.invokeMethod("bufferedDuration", arguments: nil, result: { arg in
            guard let map = arg as? Dictionary<String, Any> else {
                return
            }
            bufferedDuration = map["result"] as? TimeInterval ?? -1
            sema.signal()
        })
        _ = sema.wait(timeout: DispatchTime.now() + 0.1)
        return bufferedDuration;
    }
}
