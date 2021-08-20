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
          title: 'Living Streaming',
          description: 'Living Streaming',
          isLive: true,
          url: 'https://wowza.peer5.com'
              '/live/smil:bbb_abr.smil/chunklist_b591000.m3u8',
        ),
        VideoResource(
          title: 'VOD Streaming',
          description: 'VOD Streaming',
          url: 'https://video.cdnbye.com'
              '/0cf6732evodtransgzp1257070836/e0d4b12e5285890803440736872/v.f100220.m3u8',
        ),
      ];

  _toCustomVideoPage() async {
    String? url = await showDialog(
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
          description: 'Custom Url',
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
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Url:$url 可能不能使用p2p加速'),
      actions: <Widget>[
        Tapped(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'Cancel',
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
              'Continue',
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
    Key? key,
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
    Key? key,
    required this.resource,
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
            if (resource.image.isNotEmpty)
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
