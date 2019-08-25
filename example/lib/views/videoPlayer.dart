import 'package:cdnbye_example/views/tapped.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VideoPlayerWidget extends StatelessWidget {
  final Widget video;
  final double aspectRatio;
  final int videoDuration;
  final int videoPositon;
  final bool showToolLayer;
  final bool isPlaying;
  final bool loading;
  // 事件
  final Function onTap;
  final Function onTapPlay;
  final Function onTapFullScreen;
  final Function(double) onSlideStart;
  final Function(double) onSlideChange;
  final Function(double) onSlideEnd;

  String get positionStr {
    var sec = (videoDuration ~/ 1000) % 60;
    var min = (videoDuration ~/ 1000) ~/ 60;
    var nowSec = (videoPositon ~/ 1000) % 60;
    var nowMin = (videoPositon ~/ 1000) ~/ 60;
    return '${f2(nowMin)}:${f2(nowSec)}/${f2(min)}:${f2(sec)}';
  }

  static String f2(int a) {
    if (a < 10) {
      return '0$a';
    } else {
      return '$a';
    }
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
    this.loading,
    this.onSlideEnd,
    this.onSlideStart,
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
    Widget bottom = Row(
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
              onChangeStart: onSlideStart,
              onChanged: onSlideChange,
              onChangeEnd: onSlideEnd,
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
          // TODO: 实现全屏功能
        ),
      ],
    );
    bottom = Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 36,
        color: Colors.black.withOpacity(0.5),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: bottom,
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

    Widget loadingWidget = Container(
      color: Colors.black.withOpacity(0.1),
      alignment: Alignment.center,
      child: SpinKitFadingCircle(
        color: Colors.white,
      ),
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
        loading ? loadingWidget : Container(),
        eventGesture,
        Container(
          height: double.infinity,
          width: double.infinity,
          child: toolLayer,
        ),
      ],
    );
  }
}
