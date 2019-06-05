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
  void initState() {
    loadVideo();
    super.initState();
  }

  loadVideo() async {
    var url = 'http://opentracker.cdnbye.com:2100/20190513/Hm8R9WIB/index.m3u8';
    // var url = 'http://222.186.50.155/hls/test2.m3u8';

    await Cdnbye.init('free', infoListener: (Map info) {
      print('收到运行信息:$info');
      _info = '${info.toString()}\n' + _info;
      setState(() {});
    });
    print('转换前的Url$url');
    url = await Cdnbye.parseStreamURL(url);
    print('转换后的Url$url');
    vpController = null;
    vpController = VideoPlayerController.network(url);
    await vpController.initialize();

    vpController.addListener(() {
      position = vpController.value.position.inMilliseconds;
      setState(() {});
    });
    videoDuration = vpController.value.duration?.inMilliseconds;
    setState(() {});
  }

  String _info = '';
  int position = 0;
  int videoDuration = 0;

  bool showUi = true;
  bool isplay = false;
  @override
  Widget build(BuildContext context) {
    Widget video = vpController == null
        ? Container(
            color: Color(0xfff5f5f4),
          )
        : VideoPlayer(vpController);

    return Scaffold(
      appBar: AppBar(
        title: Text('video'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9.0,
              child: VideoPlayerWidget(
                video: video,
                aspectRatio: vpController?.value?.aspectRatio ?? 16 / 9.0,
                videoDuration: videoDuration,
                videoPositon: position,
                isPlaying: isplay,
                showToolLayer: showUi,
                onTap: () async {
                  showUi = !showUi;
                  setState(() {});
                  if (showUi && isplay) {
                    await Future.delayed(Duration(seconds: 6));
                    showUi = false;
                    setState(() {});
                  }
                },
                onTapPlay: () async {
                  if (isplay) {
                    vpController.pause();
                  } else {
                    vpController.play();
                  }
                  isplay = !isplay;
                  setState(() {});
                },
                onSlideChange: (value) {
                  vpController.seekTo(
                    Duration(milliseconds: (value * videoDuration).toInt()),
                  );
                  this.setState(() {});
                },
              ),
            ),
          ),
          Container(
            // color: Colors.red,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Wrap(
              spacing: 40,
              children: <Widget>[
                RaisedButton(
                  child: Text('reload'),
                  onPressed: () {
                    loadVideo();
                    // setState(() {});
                  },
                ),
                RaisedButton(
                  child: Text('replay'),
                  onPressed: () async {
                    position = 0;
                    await vpController.seekTo(Duration(seconds: 0));
                    vpController.play();
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('info:\n$_info'),
          )
        ],
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
    Widget titleBar = Container(
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.topCenter,
      child: Container(
        height: 44,
        color: Colors.black.withOpacity(0.3),
        padding: EdgeInsets.only(left: 12, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Tapped(
            //   child: Icon(
            //     Icons.arrow_back_ios,
            //     color: Colors.white,
            //   ),
            // ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'P2P Engine Demo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Tapped(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.star, color: Colors.white),
              ),
            ),
            Tapped(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.star, color: Colors.white),
              ),
            ),
            Tapped(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.star, color: Colors.white),
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
        titleBar,
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
