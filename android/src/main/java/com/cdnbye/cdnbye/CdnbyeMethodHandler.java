package com.cdnbye.cdnbye;


import android.app.Activity;
import android.util.Log;

import androidx.annotation.Nullable;

import com.cdnbye.core.p2p.P2pConfig;
import com.cdnbye.core.p2p.P2pStatisticsListener;
import com.cdnbye.core.segment.HlsSegmentIdGenerator;
import com.cdnbye.core.utils.LogLevel;
import com.cdnbye.sdk.P2pEngine;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CdnbyeMethodHandler implements MethodChannel.MethodCallHandler {

    private Activity activity;

    private volatile String segmentId;

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

            P2pConfig.Builder builder = new P2pConfig.Builder()
                    .logEnabled(logEnabled).logLevel(level)
                    .diskCacheLimit((int) configMap.get("diskCacheLimit"))
                    .memoryCacheCountLimit((int) configMap.get("memoryCacheCountLimit"))
                    .p2pEnabled((boolean) configMap.get("p2pEnabled"))
                    .downloadTimeout((int) configMap.get("downloadTimeout"), TimeUnit.SECONDS)
                    .dcDownloadTimeout((int) configMap.get("dcDownloadTimeout"), TimeUnit.SECONDS)
                    .withTag((String) configMap.get("tag")).localPortHls((int) configMap.get("localPort"))
                    .maxPeerConnections((int) configMap.get("maxPeerConnections"))
                    .useHttpRange((boolean) configMap.get("useHttpRange"))
                    .wifiOnly((boolean) configMap.get("wifiOnly"))
                    .isSetTopBox((boolean) configMap.get("isSetTopBox"))
                    .channelIdPrefix((String) configMap.get("channelIdPrefix"))
                    .httpHeadersForHls((Map<String, String>) configMap.get("httpHeaders"));
            if(configMap.get("wsSignalerAddr") != null){
                builder= builder.wsSignalerAddr((String) configMap.get("wsSignalerAddr"));
            }
            if(configMap.get("announce") != null) {
                builder = builder.announce((String) configMap.get("announce"));
            }
            P2pConfig config = builder.build();
            P2pEngine.init(activity.getApplication().getApplicationContext(), token, config);

            P2pEngine.getInstance().setHlsSegmentIdGenerator(new HlsSegmentIdGenerator() {
                @Override
//                public String onSegmentId(int level, long sn, String urlString) {
                public String onSegmentId(String streamId, long sn, String segmentUrl, String range) {
                    segmentId = segmentUrl;
                    Map<String, Object> args = new HashMap<>();
                    args.put("sn", sn);
                    args.put("segmentUrl", segmentUrl);
                    args.put("streamId", streamId);
                    args.put("range", range);

                    CountDownLatch latch = new CountDownLatch(1);
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            channel.invokeMethod("segmentId", args, new MethodChannel.Result() {
                                @Override
                                public void success(@Nullable Object result) {
//                                    System.out.println("native result: " + result);
                                    if (result != null) {
                                        Map map = (Map<String, String>) result;
                                        segmentId = (String) map.get("result");
                                       System.out.println(segmentId);
                                    }
                                    latch.countDown();
                                }

                                @Override
                                public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                                    latch.countDown();
                                }

                                @Override
                                public void notImplemented() {
                                    latch.countDown();
                                }
                            });
                        }
                    });
                    try {
                        latch.await(100, TimeUnit.MILLISECONDS);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
//                    System.out.println("native segmentId: " + segmentId);
                    return segmentId;
                }
            });

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
                public void onP2pDownloaded(final long value, final int value2) {
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
            try {
                Map arguments = (Map) call.arguments;
                String url = (String) arguments.get("url");
                if (url == null) {
                    result.error("No Url","Fail to restart p2p without url.",null);
                    return;
                }
                P2pEngine.getInstance().restartP2p(this.activity.getApplicationContext(),new URL(url));
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
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
