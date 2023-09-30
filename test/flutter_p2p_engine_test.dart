import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_p2p_engine/flutter_p2p_engine.dart';
import 'package:flutter_p2p_engine/flutter_p2p_engine_platform_interface.dart';
import 'package:flutter_p2p_engine/flutter_p2p_engine_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterP2pEnginePlatform
    with MockPlatformInterfaceMixin
    implements FlutterP2pEnginePlatform {

  @override
  Future<void> disableP2p() {
    // TODO: implement disableP2p
    throw UnimplementedError();
  }

  @override
  Future<void> enableP2p() {
    // TODO: implement enableP2p
    throw UnimplementedError();
  }

  @override
  Future<String> getPeerId() {
    // TODO: implement getPeerId
    throw UnimplementedError();
  }

  @override
  Future<String> getSDKVersion() {
    // TODO: implement getSDKVersion
    throw UnimplementedError();
  }

  @override
  Future<int> init(token, {required P2pConfig config, void Function(Map<String, dynamic> p1)? infoListener, bool bufferedDurationGeneratorEnable = false}) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<bool> isConnected() {
    // TODO: implement isConnected
    throw UnimplementedError();
  }

  @override
  Future<void> notifyPlaybackStalled() {
    // TODO: implement notifyPlaybackStalled
    throw UnimplementedError();
  }

  @override
  Future<String> parseStreamURL(String sourceUrl, {String? videoId, Duration Function()? bufferedDurationGenerator}) {
    // TODO: implement parseStreamURL
    throw UnimplementedError();
  }

  @override
  Future<void> restartP2p() {
    // TODO: implement restartP2p
    throw UnimplementedError();
  }

  @override
  Future<void> shutdown() {
    // TODO: implement shutdown
    throw UnimplementedError();
  }

  @override
  Future<void> stopP2p() {
    // TODO: implement stopP2p
    throw UnimplementedError();
  }
}

void main() {
  final FlutterP2pEnginePlatform initialPlatform = FlutterP2pEnginePlatform.instance;

  test('$MethodChannelFlutterP2pEngine is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterP2pEngine>());
  });

  test('getPlatformVersion', () async {
    MockFlutterP2pEnginePlatform fakePlatform = MockFlutterP2pEnginePlatform();
    FlutterP2pEnginePlatform.instance = fakePlatform;

    expect(await FlutterP2pEngine.getSDKVersion(), '3.1.0');
  });
}
