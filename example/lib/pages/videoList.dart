import 'package:cdnbye_example/model/videoResource.dart';
import 'package:cdnbye_example/pages/videoPage.dart';
import 'package:cdnbye_example/views/tapped.dart';
import 'package:flutter/material.dart';

class VideoList extends StatefulWidget {
  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<VideoResource> get _list => [
        VideoResource(
          title: 'VOD Test',
          image: 'https://geo-media.beatport.com/image/bcca19bb-9857-4b58-8ffe-7b6eab8bb92f.jpg',
          description:
              'VOD Test',
          url:
              'https://demo-vod.streamroot.io/index.m3u8',
        ),
        VideoResource(
          title: 'Live Test',
          image: 'https://p.kindpng.com/picc/s/207-2078945_live-icon-png-transparent-png.png',
          description:
              'Live Test',
          url:
              'https://wowza.peer5.com/live/smil:bbb_abr.smil/playlist.m3u8',
        ),
        VideoResource(
          title: '鹤峰综合',
          image:
              'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3005597700,3138816002&fm=26&gp=0.jpg',
          description: '新闻直播',
          url: 'http://hefeng.live.tempsource.cjyun.org/videotmp/s10100-hftv.m3u8',
        ),
      ];

  _toCustomVideoPage() async {
    String url = await showDialog(
      context: context,
      builder: (context) => _InputDialog(),
    );
    if (url == null) {
      return;
    }
    if (!url.endsWith('.m3u8')) {
      var res = await showDialog(
        context: context,
        builder: (context) => _AlertUrlErrorDialog(url: url),
      );
      if (res != true) {
        return;
      }
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VideoPage(
        resource: VideoResource(
          title: url.split('/').last,
          image: '',
          description: '自定视频',
          url: url,
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    var customUrlButton = Tapped(
      child: Container(
        height: 44,
        color: Color(0xfff5f5f4),
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.video_library,
              size: 16,
            ),
            Container(width: 4),
            Expanded(child: Text('Play with custom address')),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
            ),
          ],
        ),
      ),
      onTap: _toCustomVideoPage,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('List'),
      ),
      body: Column(
        children: <Widget>[
          customUrlButton,
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (BuildContext context, int index) {
                return VideoResourceRow(resource: _list[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertUrlErrorDialog extends StatelessWidget {
  const _AlertUrlErrorDialog({
    Key key,
    @required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('地址$url 可能不能使用p2p加速'),
      actions: <Widget>[
        Tapped(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '取消',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          onTap: () {
            Navigator.of(context).pop(false);
          },
        ),
        Tapped(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '仍然继续',
              style: TextStyle(color: Colors.red),
            ),
          ),
          onTap: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

class _InputDialog extends StatefulWidget {
  const _InputDialog({
    Key key,
  }) : super(key: key);

  @override
  __InputDialogState createState() => __InputDialogState();
}

class __InputDialogState extends State<_InputDialog> {
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Enter custom address'),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        TextField(
          controller: _controller,
          onSubmitted: (text) {
            Navigator.of(context).pop(_controller.text);
          },
        ),
        Container(
          alignment: Alignment.centerRight,
          child: Tapped(
            child: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(_controller.text);
            },
          ),
        )
      ],
    );
  }
}

class VideoResourceRow extends StatelessWidget {
  final VideoResource resource;
  const VideoResourceRow({
    Key key,
    this.resource,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // 标题与梗概
    Widget info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          resource.title,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xff4a4a4a),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            resource.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff9b9b9b),
            ),
          ),
        ),
      ],
    );
    return Tapped(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12),
        width: double.infinity,
        child: Row(
          children: <Widget>[
            Container(
              width: 66,
              constraints: BoxConstraints(
                minWidth: 66,
                minHeight: 88,
              ),
              margin: EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Image.network(resource.image),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xfff5f5f4))),
                ),
                child: info,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return VideoPage(
            resource: resource,
          );
        }));
      },
    );
  }
}
