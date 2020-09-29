import 'package:cdnbye_example/global/cdnByeListener.dart';
import 'package:cdnbye_example/model/videoResource.dart';
import 'package:cdnbye_example/views/tapped.dart';
import 'package:cdnbye_example/views/videoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:video_player/video_player.dart';
import 'package:cdnbye/cdnbye.dart';

class VideoPage extends StatefulWidget {
  final VideoResource resource;

  const VideoPage({
    Key key,
    this.resource,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController vpController;

  @override
  void dispose() {
    vpController?.dispose();
    CdnByeListener().videoInfo.removeListener(_updateVideoInfo);
    super.dispose();
  }

  @override
  void initState() {
    _initEngine(); // Init p2p engine
    _loadVideo();
    super.initState();
  }

  _updateVideoInfo() async {
    Map info = CdnByeListener().videoInfo.value;
    print('Received SDK info: $info');
    if (info.isNotEmpty) {
      String key = info.keys.toList().first;
      dynamic value = info.values.toList().first;
      if (value is int) {
        _addValue(key, value);
      } else if (value is List) {
        map[key] = value.length;
      }
    }
    _connected = await Cdnbye.isConnected() ? 'YES' : 'NO';
    _peerId = await Cdnbye.getPeerId();

    setState(() {});
  }

  Map<String, int> map = {};

  _initEngine() async {
    CdnByeListener().videoInfo.addListener(_updateVideoInfo);
    _version = await Cdnbye.platformVersion; // sdk version
  }

  // 累加value到map中，如果没有就新建
  _addValue(key, value) {
    if (map.containsKey(key)) {
      map[key] += value;
    } else {
      map[key] = value;
    }
  }

  _loadVideo() async {
    var url = widget.resource?.url ??
        'https://iqiyi.com-t-iqiyi.com/20190722/5120_0f9eec31/index.m3u8';
    // var url =
    //     'http://hefeng.live.tempsource.cjyun.org/videotmp/s10100-hftv.m3u8';
    print('Original URL: $url');
    url = await Cdnbye.parseStreamURL(url);
    print('Parsed URL: $url');
    vpController?.pause();
    position = 0;
    videoDuration = 0;
    map = {};
    isplay = true;
    vpController?.dispose();
    setState(() {});
    vpController = VideoPlayerController.network(url);
    try {
      await vpController.initialize();
      vpController.addListener(_onplay);
      vpController.play();
      videoDuration = vpController.value.duration?.inMilliseconds;
      setState(() {});
    } catch (e) {
      print('catch:$e');
    }
  }

  bool _isLoading = true;

  // 监听：播放进度
  _onplay() {
    // if (isplay) {
    _isLoading = false;
    position = vpController.value.position.inMilliseconds;
    setState(() {});
    // }
  }

  // 拖动进度条
  _seekVideoTo(double value) async {
    await vpController.seekTo(
      Duration(milliseconds: (value * videoDuration).toInt()),
    );
    position = (value * videoDuration).toInt();
  }

  _seekVideoEnd(double value) async {
    // await vpController.seekTo(
    //   Duration(milliseconds: (value * videoDuration).toInt()),
    // );
    // await vpController.play();
    // // _isLoading = false;
    // isplay = true;
    // setState(() {});
  }

  _seekVideoStart(double value) async {
    // isplay = false;
    // _isLoading = true;
    // vpController.pause();
    // setState(() {});
  }

  String _version = '';
  String _peerId = '';
  String _connected = '';
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
    // 顶部播放器
    Widget topVideo = Container(
      color: Colors.black,
      width: double.infinity,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 16 / 9.0,
        child: VideoPlayerWidget(
          video: video,
          loading: _isLoading,
          aspectRatio: aspectRatio,
          videoDuration: videoDuration,
          videoPositon: position,
          isPlaying: isplay,
          showToolLayer: showUi,
          onTap: () async {
            // 隐藏或显示UI
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
            // 点击播放
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
          onSlideStart: _seekVideoStart,
          onSlideChange: _seekVideoTo,
          onSlideEnd: _seekVideoEnd,
        ),
      ),
    );

    // 视频操作
    Widget actions = Row(
      children: <Widget>[
        ActionButton(
          color: Colors.blueAccent,
          icon: Icons.pan_tool,
          title: 'Stop P2P',
          onTap: () async {
            await Cdnbye.restartP2p();
          },
        ),
        ActionButton(
          color: Colors.blueAccent,
          icon: Icons.cast_connected,
          title: 'Restart P2P',
          onTap: () async {
            await Cdnbye.restartP2p();
          },
        ),
        ActionButton(
          color: Colors.orangeAccent,
          icon: Icons.replay,
          title: 'Replay',
          onTap: () async {
            position = 0;
            await vpController.seekTo(Duration(seconds: 0));
            vpController.play();
          },
        ),
        ActionButton(
          color: Colors.redAccent,
          icon: Icons.settings_power,
          title: 'Reload',
          onTap: () async {
            _loadVideo();
          },
        ),
      ],
    );

    actions = Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          actions,
          Container(height: 4),
          Container(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              'Peer ID: $_peerId',
              style: TextStyle(
                color: Color(0xff9b9b9b),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );

    return OrientationBuilder(
      builder: (ctx, ori) {
        switch (ori) {
          case Orientation.portrait:
            Widget body = ListView(
              children: <Widget>[
                topVideo,
                actions,
                Container(height: 8),
                InfoRow(
                  k1: 'Http Download',
                  v1: ((map['httpDownloaded'] ?? 0) / 1024).toStringAsFixed(0) +
                      " MB",
                  k2: 'Peers',
                  v2: map['peers'],
                ),
                InfoRow(
                  k1: 'P2P Download',
                  v1: ((map['p2pDownloaded'] ?? 0) / 1024).toStringAsFixed(0) +
                      " MB",
                  k2: 'P2P Upload',
                  v2: ((map['p2pUploaded'] ?? 0) / 1024).toStringAsFixed(0) +
                      " MB",
                ),
                InfoRow(
                  k1: 'SDK Version',
                  v1: _version,
                  k2: 'P2P Connected',
                  v2: _connected,
                ),
                // Text("Peer ID:" + _peerId),
              ],
            );
            SystemChrome.setEnabledSystemUIOverlays([
              SystemUiOverlay.top,
              SystemUiOverlay.bottom,
            ]);
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.resource?.title ?? 'CDNBye Demo'),
              ),
              body: body,
            );
            break;
          case Orientation.landscape:
            SystemChrome.setEnabledSystemUIOverlays([]);
            return Scaffold(
              body: topVideo,
            );
            break;
        }
        return Container();
      },
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

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;
  final Color color;

  const ActionButton({
    Key key,
    this.icon,
    this.title,
    this.onTap,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color highlight = color;
    Color textColor = Colors.white;
    return Expanded(
      child: Tapped(
        child: Container(
          decoration: BoxDecoration(
            color: highlight,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          width: 80,
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: textColor,
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
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
