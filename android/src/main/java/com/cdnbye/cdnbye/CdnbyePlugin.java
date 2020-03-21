package com.cdnbye.cdnbye;

import android.app.Activity;
import android.app.Application;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import com.cdnbye.sdk.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** CdnbyePlugin */
public class CdnbyePlugin implements ActivityAware, FlutterPlugin {

  CdnbyeMethodHandler handler = CdnbyeMethodHandler.getInstance();
  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final MethodChannel channel = new MethodChannel(binding.getFlutterEngine().getDartExecutor(), "cdnbye");
    handler.setChannel(channel);
    channel.setMethodCallHandler(handler);
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    handler.setActivity(binding.getActivity());
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    handler.setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onDetachedFromActivity() {

  }


}
