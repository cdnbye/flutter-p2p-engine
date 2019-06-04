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
    var url = 'http://222.186.50.155/hls/test2.m3u8';
    await Cdnbye.init('token');
    print('转换前的Url$url');
    url = await Cdnbye.parseStreamURL(url);
    print('转换后的Url$url');
    await vpController?.dispose();
    vpController = VideoPlayerController.network(url);
    await vpController.initialize();

    // vpController.addListener(() {
    //   position = vpController.value.position.inMilliseconds;
    //   setState(() {});
    // });
    await vpController.setLooping(true);
    // await vpController.play();
    videoDuration = vpController.value.duration.inMilliseconds;
    setState(() {});
  }

  int position = 0;
  int videoDuration = 0;
  double sliderValue = 0;
  @override
  Widget build(BuildContext context) {
    Widget video =
        vpController == null ? Container() : VideoPlayer(vpController);

    return Scaffold(
      appBar: AppBar(
        title: Text('video'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 400,
            child: video,
            color: Color(0xfff5f5f4),
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
                  child: Text('play'),
                  onPressed: () {
                    vpController.play();
                  },
                ),
                RaisedButton(
                  child: Text('pause'),
                  onPressed: () {
                    vpController.pause();
                  },
                ),
                RaisedButton(
                  child: Text('replay'),
                  onPressed: () async {
                    await vpController.seekTo(Duration(seconds: 0));
                    vpController.play();
                  },
                ),
              ],
            ),
          ),
          Slider(
            value: sliderValue,
            onChanged: (value) {
              sliderValue = value;
              vpController.seekTo(
                  Duration(milliseconds: (value * videoDuration).toInt()));
              print('$value ==$position');
              this.setState(() {});
            },
          ),
          Container(
            child: Text('$videoDuration ==$position'),
          )
        ],
      ),
    );
  }
}
