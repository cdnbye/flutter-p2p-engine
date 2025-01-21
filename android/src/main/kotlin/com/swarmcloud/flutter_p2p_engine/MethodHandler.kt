package com.swarmcloud.flutter_p2p_engine

import android.app.Activity
import android.util.Log
import com.p2pengine.core.p2p.P2pConfig
import com.p2pengine.core.p2p.P2pStatisticsListener
import com.p2pengine.core.p2p.PlayerInteractor
import com.p2pengine.core.tracking.TrackerZone
import com.p2pengine.core.utils.LogLevel
import com.p2pengine.sdk.P2pEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import io.flutter.plugin.common.EventChannel

class MethodHandler : MethodChannel.MethodCallHandler {

    private var activity: Activity? = null

    private var methodChannel: MethodChannel? = null

    private var eventSink: EventChannel.EventSink? = null

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    fun setChannel(methodChannel1: MethodChannel?, eventChannel: EventChannel?) {
        this.methodChannel = methodChannel1
        eventChannel?.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                    Log.d("Android", "EventChannel onListen called")
                }
                override fun onCancel(arguments: Any?) {
                    Log.w("Android", "EventChannel onCancel called")
                    eventSink = null
                }
            })
    }

//    companion object {
//        private var singleton: MethodHandler? = null
//        val instance: MethodHandler
//            get() {
//                if (singleton == null) {
//                    singleton = MethodHandler()
//                }
//                return singleton!!
//            }
//    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "getSDKVersion") {
            // result.success("Android " + android.os.Build.VERSION.RELEASE);
            result.success(P2pEngine.version)
        } else if (call.method == "init") {
            val arguments = call.arguments as? Map<String, *>
            if (arguments == null) {
                result.error("argument_error", "arguments must be map", null)
                return
            }
            val token = arguments["token"] as? String
            if (token == null) {
                result.error("token_error", "token not found", null)
                return
            }
            val configMap = arguments["config"] as? Map<*, *>
            if (configMap == null) {
                result.error("config_error", "config must be map", null)
                return
            }
            var logEnabled = if (configMap["logEnabled"] is Boolean) configMap["logEnabled"] as Boolean else false
            val level: LogLevel = when (configMap["logLevel"] as? Int) {
                0 -> {
                    logEnabled = false
                    LogLevel.ERROR
                }
                1 -> LogLevel.DEBUG
                2 -> LogLevel.INFO
                3 -> LogLevel.WARN
                4 -> LogLevel.ERROR
                else -> LogLevel.ERROR
            }


            var builder = P2pConfig.Builder()
                .logEnabled(logEnabled).logLevel(level)

            val zone: TrackerZone = when (configMap["trackerZone"] as? Int) {
                0 -> TrackerZone.Europe
                1 -> TrackerZone.HongKong
                2 -> TrackerZone.USA
                3 -> TrackerZone.China
                else -> TrackerZone.Europe
            }
            builder = builder.trackerZone(zone)

            configMap["p2pEnabled"]?.let {
                builder = builder.p2pEnabled(it as Boolean)
            }

            configMap["isSetTopBox"]?.let {
                builder = builder.isSetTopBox(it as Boolean)
            }

            configMap["wifiOnly"]?.let {
                builder = builder.wifiOnly(it as Boolean)
            }

            configMap["prefetchOnly"]?.let {
                builder = builder.prefetchOnly(it as Boolean)
            }

            configMap["downloadOnly"]?.let {
                builder = builder.downloadOnly(it as Boolean)
            }

            configMap["useHttpRange"]?.let {
                builder = builder.useHttpRange(it as Boolean)
            }

            configMap["localPortHls"]?.let {
                builder = builder.localPortHls(it as Int)
            }

            configMap["localPortDash"]?.let {
                builder = builder.localPortDash(it as Int)
            }

            configMap["maxPeerConnections"]?.let {
                builder = builder.maxPeerConnections(it as Int)
            }

            configMap["downloadTimeout"]?.let {
                builder = builder.downloadTimeout(it as Int, TimeUnit.SECONDS)
            }

            configMap["dcDownloadTimeout"]?.let {
                builder = builder.dcDownloadTimeout(it as Int, TimeUnit.SECONDS)
            }

            configMap["diskCacheLimit"]?.let {
                builder = builder.diskCacheLimit(it as Long)
            }

            configMap["memoryCacheCountLimit"]?.let {
                builder = builder.memoryCacheCountLimit(it as Int)
            }

            configMap["startFromSegmentOffset"]?.let {
                builder = builder.startFromSegmentOffset(it as Int)
            }

            configMap["signalConfig"]?.let {
                builder = builder.signalConfig(it as String, null)
            }

            configMap["announce"]?.let {
                builder = builder.announce(it as String)
            }

            configMap["tag"]?.let {
                builder = builder.withTag(it as String)
            }

            configMap["httpHeadersForHls"]?.let {
                builder = builder.httpHeadersForHls(it as Map<String, String>)
            }

            configMap["httpHeadersForDash"]?.let {
                builder = builder.httpHeadersForDash(it as Map<String, String>)
            }

//            configMap["httpLoadTime"]?.let {
//                builder = builder.httpLoadTime((it as Long))
//            }

            configMap["logPersistent"]?.let {
                builder = builder.logPersistent((it as Boolean))
            }

            configMap["sharePlaylist"]?.let {
                builder = builder.sharePlaylist((it as Boolean))
            }

            configMap["dashMediaFiles"]?.let {
                builder = builder.dashMediaFiles((it as ArrayList<String>))
            }

            configMap["playlistTimeOffset"]?.let {
                builder = builder.insertTimeOffsetTag(it as Double)
            }

            configMap["maxMediaFilesInPlaylist"]?.let {
                builder = builder.maxMediaFilesInPlaylist(it as Int)
            }

            configMap["fastStartup"]?.let {
                builder = builder.fastStartup(it as Boolean)
            }

            configMap["geoIpPreflight"]?.let {
                builder = builder.geoIpPreflight(it as Boolean)
            }

            configMap["useStrictHlsSegmentId"]?.let {
                builder = builder.useStrictHlsSegmentId(it as Boolean)
            }

            val config: P2pConfig = builder.build()
            P2pEngine.init(activity!!.application.applicationContext, token, config)

            if (arguments["enableBufferedDurationGenerator"] as? Boolean == true) {
                P2pEngine.instance
                    ?.setPlayerInteractor(object : PlayerInteractor() {
                        override fun onBufferedDuration(): Long {
                            var bufferedDuration: Long = -1
                            val latch = CountDownLatch(1)
                            methodChannel!!.invokeMethod(
                                "bufferedDuration",
                                null,
                                object : MethodChannel.Result {
                                    override fun success(result: Any?) {
                                        if (result != null) {
                                            val map: Map<*, *> =
                                                result as Map<String, Any>
                                            val value = map["result"]
                                            bufferedDuration = if (value is Int)
                                                value.toLong() * 1000 else -1
                                        }
                                        latch.countDown()
                                    }

                                    override fun error(
                                        errorCode: String,
                                        errorMessage: String?,
                                        errorDetails: Any?
                                    ) {
                                        latch.countDown()
                                    }

                                    override fun notImplemented() {
                                        latch.countDown()
                                    }
                                })
                            try {
                                latch.await(100, TimeUnit.MILLISECONDS)
                            } catch (e: InterruptedException) {
                                e.printStackTrace()
                            }
                            return bufferedDuration
                        }
                    })
            }

            P2pEngine.instance!!.addP2pStatisticsListener(object : P2pStatisticsListener {
                override fun onHttpDownloaded(value: Int) {
                    val info = HashMap<String, Int>()
                    info["httpDownloaded"] = value
                    eventSink?.success(info)
                }

                override fun onP2pDownloaded(value: Int, speed: Int) {
                    val info = HashMap<String, Int>()
                    info["p2pDownloaded"] = value
                    info["p2pDownloadSpeed"] = speed
                    eventSink?.success(info)
                }

                override fun onP2pUploaded(value: Int, speed: Int) {
                    val info = HashMap<String, Int>()
                    info["p2pUploaded"] = value
                    eventSink?.success(info)
                }

                override fun onPeers(peers: List<String>) {
                    val info = HashMap<String, List<String>>()
                    info["peers"] = peers
                    eventSink?.success(info)
                }

                override fun onServerConnected(connected: Boolean) {
                    val info = HashMap<String, Boolean>()
                    info["serverConnected"] = connected
                    eventSink?.success(info)
                }
            })
            result.success(1)

        } else if (call.method == "parseStreamURL") {
            val arguments = call.arguments as? Map<*, *>
            if (arguments == null) {
                result.error("argument_error", "arguments must be map", null)
                return
            }
            val url = arguments["url"] as? String
            if (url == null) {
                result.error("url_error", "url not found", null)
                return
            }
            val videoId = arguments["videoId"] as? String?
            val parsedUrl = if (videoId == null) {
                P2pEngine.instance!!.parseStreamUrl(url)
            } else {
                P2pEngine.instance!!.parseStreamUrl(url, videoId)
            }
            result.success(parsedUrl)
        } else if (call.method == "notifyPlaybackStalled") {
            P2pEngine.instance?.notifyPlaybackStalled()
            result.success(1)
        } else if (call.method == "isConnected") {
            result.success(P2pEngine.instance?.isConnected ?: false)
        } else if (call.method == "restartP2p") {
            P2pEngine.instance?.restartP2p(null)
            result.success(1)
        } else if (call.method == "disableP2p") {
            P2pEngine.instance?.disableP2p()
            result.success(1)
        } else if (call.method == "stopP2p") {
            P2pEngine.instance?.stopP2p()
            result.success(1)
        } else if (call.method == "enableP2p") {
            P2pEngine.instance?.enableP2p()
            result.success(1)
        } else if (call.method == "shutdown") {
            P2pEngine.instance?.shutdown()
            result.success(1)
        } else if (call.method == "getPeerId") {
            result.success(P2pEngine.instance?.peerId)
        } else if (call.method == "setHttpHeadersForHls") {
            val arguments = call.arguments as? Map<*, *>
            if (arguments != null) {
                val headers = arguments["headers"] as? Map<String, String>
                P2pEngine.instance?.setHttpHeadersForHls(headers)
            }
            result.success(1)
        } else if (call.method == "setHttpHeadersForDash") {
            val arguments = call.arguments as? Map<*, *>
            if (arguments != null) {
                val headers = arguments["headers"] as? Map<String, String>
                P2pEngine.instance?.setHttpHeadersForDash(headers)
            }
            result.success(1)
        } else {
            println("notImplemented")
            result.notImplemented()
        }
    }

}
