import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_p2p_engine/flutter_p2p_engine_platform_interface.dart';
import 'package:safemap/safemap.dart';
import 'package:flutter_p2p_engine/flutter_p2p_engine.dart';
import 'package:flutter_p2p_engine_example/style/color.dart';
import 'package:flutter_p2p_engine_example/views/confirm.dart';
import 'package:tapped/tapped.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const VideoApp());

  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class VideoApp extends StatelessWidget {
  const VideoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final player = Player();
  late final controller = VideoController(player);
  @override
  void initState() {
    super.initState();
    init();
  }

  var url =
      'https://video.cdnbye.com/0cf6732evodtransgzp1257070836/e0d4b12e5285890803440736872/v.f100220.m3u8';
  var urlResult = "";
  var token = 'ZMuO5qHZg';    // replace with your own token

  var totalHTTPDn = 0;
  var totalP2PDn = 0;
  var totalP2PUp = 0;
  var connected = false;

  init() async {
    try {
      await FlutterP2pEngine.init(
        token,
        config: P2pConfig(
          trackerZone: TrackerZone.Europe,
          logEnabled: true,
          logLevel: P2pLogLevel.debug,
        ),
        infoListener: (info) {
          // print('p2p listen: $info');
          if (SafeMap(info)["serverConnected"].hasValue) {
            setState(() {
              connected = SafeMap(info)["serverConnected"].boolean;
            });
          } else {
            setState(() {
              totalHTTPDn += SafeMap(info)["httpDownloaded"].intOrZero;
              totalP2PDn += SafeMap(info)["p2pDownloaded"].intOrZero;
              totalP2PUp += SafeMap(info)["p2pUploaded"].intOrZero;
            });
          }
        },
        bufferedDurationGeneratorEnable: true
      );
      var res = await FlutterP2pEngine.parseStreamURL(url, bufferedDurationGenerator: () {
        // print("bufferedDurationGenerator ${player.state.buffer}");
        return player.state.buffer;
      });
      urlResult = res ?? url;
      // print('urlResult $urlResult $res');
      setState(() {});
      player.open(Media(urlResult));
      // controller.player.setVolume(0.0);
    } catch (e) {
      // print('Init Error $e');
    }
  }

  bool showDetail = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPlate.lightGray,
      body: Center(
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                // Use [Video] widget to display video output.
                child: Video(controller: controller),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showDetail)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text('Token:$token'),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text('Url:$url'),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    [
                                      'Connected:$connected',
                                      'TotalHTTPDownloaded:$totalHTTPDn',
                                      'TotalP2PDownloaded:$totalP2PDn',
                                      'TotalP2PUploaded:$totalP2PUp',
                                    ].join('\n'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Column(
                        children: [
                          Tapped(
                            onTap: () {
                              setState(() {
                                showDetail = !showDetail;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 12,
                              ),
                              child: Icon(
                                showDetail ? Icons.clear : Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          if (showDetail)
                            Tapped(
                              onTap: () async {
                                var res = await editUrlAndToken(
                                  context,
                                  url: url,
                                  token: token,
                                );
                                var _token = res?.asMap()[0];
                                var _url = res?.asMap()[0];
                                if (_token != null && _url != null) {
                                  token = _token;
                                  url = url;
                                  setState(() {});
                                  init();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 12,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 输入文本，可以通过onWillConfirm方法检查
Future<List<String>?> editUrlAndToken(
    BuildContext context, {
      ConfirmType? type,
      String? url,
      String? token,
    }) async {
  InputHelper urlInput = InputHelper(defaultText: url);
  InputHelper tokenInput = InputHelper(defaultText: token);
  var res = await confirm(
    context,
    type: type,
    title: 'Edit',
    ok: 'Save',
    cancel: 'Cancel',
    onWillConfirm: () async => true,
    contentBuilder: (ctx) => Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: ColorPlate.lightGray,
            borderRadius: BorderRadius.circular(6),
          ),
          child: StInput.helper(
            autofocus: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            maxLength: 120,
            clearable: true,
            helper: tokenInput,
            hintText: 'Input Token',
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: ColorPlate.lightGray,
            borderRadius: BorderRadius.circular(6),
          ),
          child: StTextField(
            autofocus: true,
            margin: EdgeInsets.zero,
            helper: urlInput,
            hintText: 'Input Url',
          ),
        ),
      ],
    ),
  );
  if (res == true) {
    return [
      tokenInput.text,
      urlInput.text,
    ];
  }
  return null;
}
