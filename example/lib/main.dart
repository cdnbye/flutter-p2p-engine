import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cdnbye/cdnbye.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VideoPlayerWidget();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController _controller;
  bool _isPlaying = false;
  String url = 'http://www.w3school.com.cn/example/html5/mov_bbb.mp4';

  ChewieController chewieController;
  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(url);
    chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 4.0 / 3.0,
      autoPlay: false,
      looping: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget video = Container(
      height: 300,
      child: Center(
        child: Chewie(
          controller: chewieController,
        ),
      ),
    );
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('视频播放'),
        ),
        body: ListView(
          children: <Widget>[
            video,
            Container(
              height: 200,
              child: Center(
                child: RaisedButton(
                  child: Text('init'),
                  onPressed: () async {
                    await Cdnbye.init('free');
                  },
                ),
              ),
            ),
            Container(
              height: 200,
              child: Center(
                child: RaisedButton(
                  child: Text('free'),
                  onPressed: () async {
                    var newUrl = await Cdnbye.parseStreamURL('url://asdfghjk');
                    print('转换后的URL:$newUrl');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
