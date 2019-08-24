import 'package:cdnbye_example/views/tapped.dart';
import 'package:flutter/material.dart';

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
              // TODO: 完成全屏功能
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
