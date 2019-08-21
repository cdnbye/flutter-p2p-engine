import 'package:cdnbye_example/pages/tapped.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:cdnbye/cdnbye.dart';

class CustomVideoPlayerPage extends StatefulWidget {
  @override
  _CustomVideoPlayerPageState createState() => _CustomVideoPlayerPageState();
}

class _CustomVideoPlayerPageState extends State<CustomVideoPlayerPage> {
  VideoPlayerController vpController;

  @override
  void dispose() {
    vpController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initEngine(); // Init p2p engine
    _loadVideo();
    super.initState();
  }

  Map<String, int> map = {};
  _initEngine() async {
    await Cdnbye.init(
      'free',
//      config: P2pConfig.byDefault(),
      config: P2pConfig(
        logLevel: P2pLogLevel.info,
      ),
      infoListener: (Map info) {
        print('Received SDK info: $info');
        String key = info.keys.toList().first;
        dynamic value = info.values.toList().first;
        if (value is int) {
          _addValue(key, value);
        } else if (value is List) {
          _addValue(key, value.length);
        }
        _info = '${map.toString()}\n';
        setState(() {});
      },
    );
  }

  _addValue(key, value) {
    if (map.containsKey(key)) {
      map[key] += value;
    } else {
      map[key] = value;
    }
  }

  _loadVideo() async {
    var url = 'https://iqiyi.com-t-iqiyi.com/20190722/5120_0f9eec31/index.m3u8';
//    var url = 'http://hefeng.live.tempsource.cjyun.org/videotmp/s10100-hftv.m3u8';
    print('Original URL: $url');
    url = await Cdnbye.parseStreamURL(url);
    print('Parsed URL: $url');
    vpController?.pause();
    position = 0;
    videoDuration = 0;
    isplay = true;
    vpController?.dispose();
    setState(() {});
    vpController = VideoPlayerController.network(url);
    try {
      await vpController.initialize();
      vpController.addListener(() {
        position = vpController.value.position.inMilliseconds;
        setState(() {});
      });
      vpController.play();
      videoDuration = vpController.value.duration?.inMilliseconds;
      setState(() {});
    } catch (e) {
      print('$e');
    }
  }

  String _info = '';
  int position = 0;
  int videoDuration = 0;

  bool showUi = true;
  bool isplay = false;
  @override
  Widget build(BuildContext context) {
    bool hasVideo = vpController?.value?.isPlaying ?? false;
    Widget video;
    double aspectRatio = 16 / 9.0;
    if (hasVideo) {
      video = VideoPlayer(vpController);
      aspectRatio = vpController?.value?.aspectRatio ?? 16 / 9.0;
    } else {
      video = Container(
        color: Color(0xff000000),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('CDNBye Demo'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9.0,
              child: VideoPlayerWidget(
                video: video,
                aspectRatio: aspectRatio,
                videoDuration: videoDuration,
                videoPositon: position,
                isPlaying: isplay,
                showToolLayer: showUi,
                onTap: () async {
                  if (!vpController.value.initialized) {
                    return;
                  }
                  showUi = !showUi;
                  setState(() {});
                  if (showUi && isplay) {
                    await Future.delayed(Duration(seconds: 6));
                    showUi = false;
                    setState(() {});
                  }
                },
                onTapPlay: () async {
                  if (!vpController.value.initialized) {
                    return;
                  }
                  if (isplay) {
                    vpController.pause();
                  } else {
                    vpController.play();
                  }
                  isplay = !isplay;
                  setState(() {});
                },
                onSlideChange: (value) async {
                  await vpController.seekTo(
                    Duration(milliseconds: (value * videoDuration).toInt()),
                  );
                  this.setState(() {});
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'Actions:',
                    style: TextStyle(
                      color: Color(0xff9b9b9b),
                      fontSize: 12,
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.red,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.restore,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        child: Text(
                          'Reload',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    _loadVideo();
                    // setState(() {});
                  },
                ),
                Container(width: 24),
                RaisedButton(
                  color: Colors.orange,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.replay,
                        color: Colors.white,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        child: Text(
                          'Replay',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    position = 0;
                    await vpController.seekTo(Duration(seconds: 0));
                    vpController.play();
                  },
                ),
              ],
            ),
          ),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 20),
          //   child: Text('info:\n$_info'),
          // ),
          Container(height: 12),
          InfoRow(
            k1: 'Http Download',
            v1: map['httpDownloaded'],
            k2: 'Peers',
            v2: map['peers'],
          ),
          InfoRow(
            k1: 'P2P Download',
            v1: map['p2pDownloaded'],
            k2: 'P2P Upload',
            v2: map['p2pUploaded'],
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String k1;
  final dynamic v1;
  final String k2;
  final dynamic v2;

  String get v1Str => v1?.toString() ?? '0';
  String get v2Str => v2?.toString() ?? '0';

  const InfoRow({
    Key key,
    this.k1,
    this.v1,
    this.k2,
    this.v2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          OneInfo(
            tag: k1,
            value: v1Str,
          ),
          OneInfo(
            tag: k2,
            value: v2Str,
          ),
        ],
      ),
    );
  }
}

class OneInfo extends StatelessWidget {
  const OneInfo({
    Key key,
    this.tag,
    this.value,
  }) : super(key: key);

  final String tag;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
        margin: EdgeInsets.all(6),
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                '$tag : ',
                style: TextStyle(
                  color: Color(0xff9b9b9b),
                  fontSize: 12,
                ),
              ),
            ),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatelessWidget {
  final Widget video;
  final double aspectRatio;
  final int videoDuration;
  final int videoPositon;
  final bool showToolLayer;
  final bool isPlaying;
  // 事件
  final Function onTap;
  final Function onTapPlay;
  final Function onTapFullScreen;
  final Function(double) onSlideChange;

  String get positionStr {
    var sec = (videoDuration ~/ 1000) % 60;
    var min = (videoDuration ~/ 1000) ~/ 60;
    var nowSec = (videoPositon ~/ 1000) % 60;
    var nowMin = (videoPositon ~/ 1000) ~/ 60;
    return '$nowMin:$nowSec/$min:$sec';
  }

  const VideoPlayerWidget({
    Key key,
    this.video,
    this.aspectRatio,
    this.videoDuration,
    this.videoPositon,
    this.showToolLayer,
    this.isPlaying,
    this.onTap,
    this.onTapPlay,
    this.onTapFullScreen,
    this.onSlideChange,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double sliderValue = 0;
    if (videoDuration != 0) {
      sliderValue = videoPositon / videoDuration;

      if (sliderValue <= 0) {
        sliderValue = 0;
      }
      if (sliderValue >= 1) {
        sliderValue = 1;
      }
    }

    // 底部播放条
    Widget bottom = Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 36,
        color: Colors.black.withOpacity(0.5),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: <Widget>[
            Tapped(
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onTap: onTapPlay,
            ),
            Expanded(
              child: Container(
                child: Slider(
                  inactiveColor: Colors.white.withOpacity(0.3),
                  activeColor: Colors.white,
                  value: sliderValue,
                  onChanged: onSlideChange,
                ),
              ),
            ),
            Container(
              child: Text(
                positionStr,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Tapped(
                child: Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Widget eventGesture = Container(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onTap: onTap,
      ),
    );

    Widget toolLayer = Stack(
      children: <Widget>[
        bottom,
      ],
    );
    toolLayer = AnimatedOpacity(
      opacity: showToolLayer ? 1 : 0,
      duration: Duration(milliseconds: 200),
      curve: Curves.bounceInOut,
      child: toolLayer,
    );

    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              child: video,
            ),
          ),
        ),
        eventGesture,
        Container(
          // color: Colors.yellow,
          height: double.infinity,
          width: double.infinity,
          child: toolLayer,
        ),
      ],
    );
  }
}
