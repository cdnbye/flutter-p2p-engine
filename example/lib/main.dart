import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:safemap/safemap.dart';
import 'package:flutter_p2p_engine/flutter_p2p_engine.dart';
import 'package:flutter_p2p_engine_example/style/color.dart';
import 'package:flutter_p2p_engine_example/views/confirm.dart';
import 'package:tapped/tapped.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

const token = 'ZMuO5qHZg';    // replace with your own token

void main() {
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
  var playerReady = false;
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    init();
  }

  // var url = 'https://test-streams.mux.dev/x36xhzz/url_0/193039199_mp4_h264_aac_hd_7.m3u8';
  var url = 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/level_0.m3u8';

  var totalHTTPDn = 0;
  var totalP2PDn = 0;
  var totalP2PUp = 0;
  var connected = false;
  var sdkVersion = '';

  init() async {
    try {
      // Do not init FlutterP2pEngine more than once! 请不要多次init FlutterP2pEngine！
      await FlutterP2pEngine.init(
        token,
        // bufferedDurationGeneratorEnable: true,
        config: P2pConfig(
          trackerZone: TrackerZone.Europe,
          playlistTimeOffset: 0.0,
          logEnabled: true,
          logLevel: P2pLogLevel.debug,
          // useStrictHlsSegmentId: true,
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
      );

      setState(() {});
      setUpVideo(url);

      sdkVersion = await FlutterP2pEngine.getSDKVersion();
    } catch (e) {
      // print('Init Error $e');
    }
  }

  bool showDetail = false;

  setUpVideo(String url) async {
    _controller?.dispose();
    var res = await FlutterP2pEngine.parseStreamURL(url,
    //     bufferedDurationGenerator: () {
    //   return _controller!.value.buffered.last.end - _controller!.value.position;
    // }
    );
    print('urlResult $res');

    _controller = VideoPlayerController.networkUrl(Uri.parse(res ?? url))..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {
        playerReady = true;
      });
      _controller?.play();
    });

  }

  @override
  void dispose() {
    // player.dispose();
    _controller?.dispose();
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
                child: playerReady
                    ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      VideoPlayer(_controller!),
                      VideoProgressIndicator(_controller!, allowScrubbing: true),
                      GestureDetector(
                        onTap: () {
                          _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                        },
                      ),
                    ],
                  ),
                )
                    : Container(),
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
                                      'SDK Version: $sdkVersion',
                                      'Connected: $connected',
                                      'TotalHTTPDownloaded: $totalHTTPDn',
                                      'TotalP2PDownloaded: $totalP2PDn',
                                      'TotalP2PUploaded: $totalP2PUp',
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
                                var res = await editUrl(
                                  context,
                                  url: url,
                                );
                                var _url = res?.asMap()[0];
                                if (_url != null) {
                                  setState(() {});
                                  setUpVideo(_url);
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       if (playerReady) {
      //         _controller!.value.isPlaying ? _controller!.pause(): _controller!.play();
      //       }
      //     });
      //   },
      //   child: Icon(
      //     playerReady && _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}

/// 输入文本，可以通过onWillConfirm方法检查
Future<List<String>?> editUrl(
    BuildContext context, {
      ConfirmType? type,
      String? url,
    }) async {
  InputHelper urlInput = InputHelper(defaultText: url);
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
      urlInput.text,
    ];
  }
  return null;
}
