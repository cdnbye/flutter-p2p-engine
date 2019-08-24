import 'package:cdnbye_example/model/videoResource.dart';
import 'package:cdnbye_example/pages/videoPage.dart';
import 'package:cdnbye_example/views/tapped.dart';
import 'package:flutter/material.dart';

class VideoList extends StatefulWidget {
  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<VideoResource> _list = [
    VideoResource(
      title: '上海堡垒',
      image: 'http://ty.download05.com/1566616453216553.jpeg',
      description:
          '未来世界外星黑暗势力突袭地球，上海成为了人类最后的希望。大学生江洋（鹿晗饰）追随女指挥官林澜（舒淇饰）进入了上海堡垒成为一名指挥员。外星势力不断发动猛烈袭击，林澜受命保护击退外星人的秘密武器，江洋和几个好友所在的灰鹰小队则要迎战外星侵略者，保卫人类的最后一战最终在上海打响……',
      url:
          'http://cn1.ruioushang.com/hls/20190824/6bbb04d6e14df9b331cf88409a8846c6/1566615719/index.m3u8',
    ),
    VideoResource(
      title: '哥斯拉2：怪兽之王',
      image: 'http://ty.download05.com/1559637248977096.jpeg',
      description:
          '随着《哥斯拉》和《金刚：骷髅岛》在全球范围内取得成功，传奇影业和华纳兄弟影业联手开启了怪兽宇宙系列电影的新篇章—一部史诗级动作冒险巨制。在这部电影中，哥斯拉将和众多大家在流行文化中所熟知的怪兽展开较量。全新故事中，研究神秘动物学的机构“帝王组织”将勇敢直面巨型怪兽，其中强大的哥斯拉也将和魔斯拉、拉顿和它的死对头——三头王者基多拉展开激烈对抗。当这些只存在于传说里的超级生物再度崛起时，它们将展开王者争霸，人类的命运岌岌可危……',
      url:
          'http://cn4.download05.com/hls/20190727/0248d8f0033b991444d671fea2a42c57/1564205511/index.m3u8',
    ),
    VideoResource(
      title: '宝贝计划',
      image: 'http://ty.download05.com/1565608988136038.jpeg',
      description:
          '故事围绕一个刚出生的宝宝开始。人字拖（成龙 饰）虽有不凡的身手，可是终日沉迷赌博毫无人生目标，便与包租公（许冠文 饰）、八达通（古天乐 饰）一起爆窃，干着偷偷摸摸的犯罪事。城中女富豪（余安安 饰）唯一的孙子出生后，包租公受不了金钱的诱惑，答应把宝宝偷给黑帮老大，以证明BB是否自 己死去的儿子与前女友的孩子。 　　成功偷得孩子后，一连串发生的事情，使人字拖及八达通改变了自己的人生观念。人字拖开始关心家人，八达通也看到了自己老婆（蔡卓妍 饰）的不易，开始重新做人。 在包租公及黑势利的威胁下，他们还是要把偷来的BB交出来，到底又会发生些什么事，故事有会否大团圆结局呢？',
      url:
          'http://cn5.download05.com/hls/20190812/359ffef3ec383b63ec806d20d1ed09a5/1565605515/index.m3u8',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('列表'),
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return VideoResourceRow(resource: _list[index]);
        },
      ),
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
          margin: EdgeInsets.only(top: 12),
          child: Text(
            resource.description,
            maxLines: 3,
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
              margin: EdgeInsets.fromLTRB(12, 16, 12, 16),
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
