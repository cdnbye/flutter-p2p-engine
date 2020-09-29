package com.cdnbye.cdnbye;


import android.app.Activity;

import androidx.annotation.Nullable;

import com.cdnbye.sdk.LogLevel;
import com.cdnbye.sdk.P2pConfig;
import com.cdnbye.sdk.P2pEngine;
import com.cdnbye.sdk.P2pStatisticsListener;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CdnbyeMethodHandler implements MethodChannel.MethodCallHandler {

    private Activity activity;

    private volatile String channelId;

    private static CdnbyeMethodHandler instance;

    private MethodChannel channel;

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public void setChannel(MethodChannel channel) {
        this.channel = channel;
    }
    private CdnbyeMethodHandler() {

    }

    public void onMethodCall(final MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("getPlatformVersion")) {
            // result.success("Android " + android.os.Build.VERSION.RELEASE);
            result.success(P2pEngine.Version);
        } else if (call.method.equals("init")) {
            Map arguments = (Map) call.arguments;
            String token = (String) arguments.get("token");
            Map configMap = (Map) arguments.get("config");
            LogLevel level;
            switch ((int) configMap.get("logLevel")) {
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
            boolean logEnabled = (int) configMap.get("logLevel") != 0;

            P2pConfig config = new P2pConfig.Builder()
                    .logEnabled(logEnabled).logLevel(level)
                    .wsSignalerAddr((String) configMap.get("wsSignalerAddr"))
                    .announce((String) configMap.get("announce"))
                    .diskCacheLimit((int) configMap.get("diskCacheLimit"))
                    .memoryCacheCountLimit((int) configMap.get("memoryCacheCountLimit"))
                    .p2pEnabled((boolean) configMap.get("p2pEnabled"))
                    .downloadTimeout((int) configMap.get("downloadTimeout"), TimeUnit.SECONDS)
                    .dcDownloadTimeout((int) configMap.get("dcDownloadTimeout"), TimeUnit.SECONDS)
                    .withTag((String) configMap.get("tag")).localPort((int) configMap.get("localPort"))
                    .maxPeerConnections((int) configMap.get("maxPeerConnections"))
                    .useHttpRange((boolean) configMap.get("useHttpRange"))
                    .wifiOnly((boolean) configMap.get("wifiOnly"))
                    .isSetTopBox((boolean) configMap.get("isSetTopBox"))
                    .channelIdPrefix((String) configMap.get("channelIdPrefix"))
                    .setHttpHeaders((Map<String, String>) configMap.get("httpHeaders"))
                    .build();
            P2pEngine.initEngine(activity.getApplication().getApplicationContext(), token, config);

            result.success(1);
        } else if (call.method.equals("parseStreamURL")) {
            Map configMap = (Map) call.arguments;
            String url = (String) configMap.get("url");
            String videoId = (String) configMap.get("videoId");
            String parsedUrl = P2pEngine.getInstance().parseStreamUrl(url, videoId);
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

                @Override
                public void onServerConnected(boolean connected) {
                   
                }
            });
            result.success(1);
        } else if (call.method.equals("isConnected")) {
            result.success(P2pEngine.getInstance().isConnected());
        } else if (call.method.equals("restartP2p")) {
            P2pEngine.getInstance().restartP2p();
            result.success(1);
        } else if (call.method.equals("stopP2p")) {
            P2pEngine.getInstance().stopP2p();
            result.success(1);
        } else if (call.method.equals("getPeerId")) {
            result.success(P2pEngine.getInstance().getPeerId());
        }

        else {
            System.out.println("notImplemented");
            result.notImplemented();
        }
    }

    public static CdnbyeMethodHandler getInstance() {

        if (instance == null) {
            instance = new CdnbyeMethodHandler();
        }

        return instance;
    }
}
