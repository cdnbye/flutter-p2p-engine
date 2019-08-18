package com.cdnbye.cdnbye;

import android.app.Activity;
import android.app.Application;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.cdnbye.sdk.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** CdnbyePlugin */
public class CdnbyePlugin implements MethodCallHandler {

  private MethodChannel channel;
  private Activity activity;
  private CdnbyePlugin(Activity activity, MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "cdnbye");
    channel.setMethodCallHandler(new CdnbyePlugin(registrar.activity(), channel));
  }

  @Override
  public void onMethodCall(final MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("init")) {
      Map arguments = (Map)call.arguments;
      String token = (String) arguments.get("token");

      /*
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
       */
      Map configMap = (Map)arguments.get("config");
      LogLevel level;
      switch ((int)configMap.get("logLevel")) {
        case 2:
          level = LogLevel.INFO;
          break;
        case 3:
          level = LogLevel.WARN;
          break;
        case 4:
          level = LogLevel.ERROR;
          break;
        default:
          level = LogLevel.DEBUG;
      }
      boolean logEnabled = (int)configMap.get("logLevel") != 0;
      P2pConfig config = new P2pConfig.Builder()
              .logEnabled(logEnabled)
              .logLevel(level)
              .wsSignalerAddr((String)configMap.get("wsSignalerAddr"))
              .announce((String)configMap.get("announce"))
              .diskCacheLimit((int)configMap.get("diskCacheLimit"))
              .memoryCacheLimit((int)configMap.get("memoryCacheLimit"))
              .p2pEnabled((boolean)configMap.get("p2pEnabled"))
              .packetSize((int)configMap.get("packetSize"))
              .downloadTimeout((int)configMap.get("downloadTimeout"), TimeUnit.SECONDS)
              .dcDownloadTimeout((int)configMap.get("dcDownloadTimeout"), TimeUnit.SECONDS)
              .withTag((String)configMap.get("tag"))
              .localPort((int)configMap.get("localPort"))
              .maxPeerConnections((int)configMap.get("maxPeerConnections"))
              .build();
      P2pEngine.initEngine(activity.getApplication().getApplicationContext(), token, config);
      result.success(1);
    } else if (call.method.equals("parseStreamURL")) {
      Map configMap = (Map)call.arguments;
      String url = (String) configMap.get("url");
      String parsedUrl = P2pEngine.getInstance().parseStreamUrl(url);
      result.success(parsedUrl);
    } else if (call.method.equals("startListen")) {
      P2pEngine.getInstance().addP2pStatisticsListener(new P2pStatisticsListener() {
        @Override
        public void onHttpDownloaded(final long value) {
          final Map info = new HashMap();
          info.put("httpDownloaded", value);
          activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
              channel.invokeMethod("info", info);
            }
          });
        }

        @Override
        public void onP2pDownloaded(final long value) {
          final Map info = new HashMap();
          info.put("p2pDownloaded", value);
          activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
              channel.invokeMethod("info", info);
            }
          });
        }

        @Override
        public void onP2pUploaded(final long value) {
          final Map info = new HashMap();
          info.put("p2pUploaded", value);
          activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
              channel.invokeMethod("info", info);
            }
          });
        }

        @Override
        public void onPeers(List<String> peers) {
          final Map info = new HashMap();
          info.put("peers", peers);
          activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
              channel.invokeMethod("info", info);
            }
          });

        }
      });
      result.success(1);
    } else {
      System.out.println("notImplemented");
      result.notImplemented();
    }
  }
}
