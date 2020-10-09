---
title: API文档
---

## P2P配置
用建造者模式实例化 ***P2pConfig***，以下的参数是默认值：
```dart
  /// 打印日志的级别
  final P2pLogLevel logLevel;

  /// 通过webRTCConfig来修改WebRTC默认配置
  final Map<String, dynamic> webRTCConfig;

  /// 信令服务器地址
  final String wsSignalerAddr;

  /// tracker服务器地址
  final String announce;

  /// 点播模式下P2P在磁盘缓存的最大数据量(设为0可以禁用磁盘缓存)
  final int diskCacheLimit;

  /// P2P在内存缓存的最大数据量，用ts文件个数表示，仅安卓有效
  final int memoryCacheCountLimit;
  // @Deprecated('Use memoryCacheCountLimit now')
  // 仅iOS有效
  final int memoryCacheLimit;

  /// 开启或关闭p2p engine
  final bool p2pEnabled;

  /// HTTP下载ts文件超时时间
  final Duration downloadTimeout;

  /// datachannel下载二进制数据的最大超时时间
  final Duration dcDownloadTimeout;

  /// 用户自定义的标签，可以在控制台查看分布图
  final String tag;

  /// 本地代理服务器的端口号
  final int localPort;

  /// 最大连接节点数量
  final int maxPeerConnections;

  /// 在可能的情况下使用Http Range请求来补足p2p下载超时的剩余部分数据
  final bool useHttpRange;

  /// 是否只在wifi和有线网络模式上传数据（建议在云端设置）
  final bool wifiOnly;

  /// 设置请求ts和m3u8时的HTTP请求头
  final Map<String, String> httpHeaders;

  /// 如果使用自定义的channelId，则此字段必须设置，且长度必须在5到15个字符之间，建议设置成你所在组织的唯一标识
  final String channelIdPrefix;

  /// 如果运行于机顶盒请设置成true
  final bool isSetTopBox;

  P2pConfig({
    this.logLevel: P2pLogLevel.warn,
    this.webRTCConfig: const {}, // TODO: 默认值缺少
    this.wsSignalerAddr: 'wss://signal.cdnbye.com',
    this.announce: 'https://tracker.cdnbye.com/v1',
    this.diskCacheLimit: 1024 * 1024 * 1024,
    this.memoryCacheLimit: 60 * 1024 * 1024,
    this.memoryCacheCountLimit: 30,
    this.p2pEnabled: true,
    this.downloadTimeout: const Duration(seconds: 10),
    this.dcDownloadTimeout: const Duration(seconds: 4),
    this.tag: "flutter",
    this.localPort: 52019,
    this.maxPeerConnections: 10,
    this.useHttpRange: true,
    this.wifiOnly: false,
    this.httpHeaders,
    this.channelIdPrefix: "cdnbye",
    this.isSetTopBox: false,
  });
```

## P2pEngine
实例化P2pEngine，获得一个全局单例：
```dart
// 初始化
Cdnbye.init(
  'ZMuO5qHZg', // replace with your token
  config: P2pConfig(
    logLevel: P2pLogLevel.debug,
  ),
  infoListener: _listen,
  segmentIdGenerator: (level, sn, url) {
    // TODO: segmentIdGenerator
    return url;
  },
);
```
参数说明:
<br>

|           参数           |                      类型                      | 是否必须 |        说明         |
| :----------------------: | :--------------------------------------------: | :------: | :-----------------: |
|       ***token***        |                     String                     |    是    | CDNBye分配的token。 |
|       ***config***       |                   P2pConfig                    |    否    |    自定义配置。     |
|    ***infoListener***    |               CdnByeInfoListener               |    否    |   监听p2p信息更新   |
| ***segmentIdGenerator*** | String Function(int level, int sn, String url) |    否    |    生成SegmentId    |

### 切换源
当播放器切换到新的播放地址时，只需要将新的播放地址(m3u8)传给 ***Cdnbye***，从而获取新的本地播放地址：
```dart
String url = await Cdnbye.parseStreamURL(oldUrl);
```

### Cdnbye API
```dart
/// The version of SDK. SDK的版本号
static Future<String> get platformVersion 

/// Create a new instance with token and the specified config.
static Future<int> init(
  token, {
  P2pConfig config,
  CdnByeInfoListener infoListener,
  String Function(int level, int sn, String url) segmentIdGenerator,
})

/// Get parsed local stream url by passing the original stream url(m3u8) to CBP2pEngine instance.
static Future<String> parseStreamURL(
  String sourceUrl, [
  String videoId,
])

/// Get the connection state of p2p engine. 获取P2P Engine的连接状态
static Future<bool> isConnected()

/// Restart p2p engine.
static Future restartP2p()

/// Stop p2p and free used resources.
static Future stopP2p()

/// Get the peer ID of p2p engine. 获取P2P Engine的peer ID
static Future<String> getPeerId()
```

### P2P统计

请参考`example`中的例子。

::: warning
下载和上传数据量的单位是KB。
:::

## 高级用法

### 解决动态m3u8路径问题
某些流媒体提供商的m3u8是动态生成的，不同节点的m3u8地址不一样，例如example.com/clientId1/streamId.m3u8和example.com/clientId2/streamId.m3u8, 而本插件默认使用m3u8地址(去掉查询参数)作为channelId。这时候就要构造一个共同的chanelId，使实际观看同一直播/视频的节点处在相同频道中。构造channelId方法如下：

```dart
// 根据url构造ChannelId
String channelId = oldUrl.split('/').last;
String url = await Cdnbye.parseStreamURL(oldUrl,channelId);
```

::: warning
如果要与其他平台互通，则必须确保两者拥有相同的 channelIdPrefix 和 channelId 。
:::


### 解决动态ts路径问题
类似动态m3u8路径问题，相同ts文件的路径也可能有差异，这时候需要忽略ts路径差异的部分。插件默认用ts的绝地路径(url)来标识每个ts文件，所以需要通过钩子函数重新构造标识符。可以按如下设置：
```dart
// 初始化
Cdnbye.init(
  'ZMuO5qHZg', // replace with your token
  segmentIdGenerator: (level, sn, url) {
    // TODO: return your segmentId
    return url;
  },
);
```
### 设置HTTP请求头
出于防盗链或者统计的需求，有些HTTP请求需要加上 ***referer*** 或者 ***User-Agent*** 等头信息，可以通过 ***httpHeaders*** 进行设置：
```dart
P2pConfig(
  httpHeaders: {
    "referer": "XXX",
    "User-Agent": "XXX",
  }
)
```
<!-- 

### 切换信令
某些场景下需要动态修改信令地址，防止单个信令负载过大，例如根据播放地址的哈希值选择信令。可以通过调用 ***engine.setConfig(config)*** 运行时动态调整配置，示例如下：
```java
P2pConfig config = new P2pConfig.Builder()
        .wsSignalerAddr("wss://yoursignal2.com")
        .build();
P2pEngine.getInstance().setConfig(config);
```
需要注意的是这个方法会重置 ***P2pEngine*** 的所有config，因此之前已经修改的字段需要再设置一次以保持一致。

### 自行配置 STUN 和 TURN 服务器地址
STUN用于p2p连接过程中获取公网IP地址，TURN则可以在p2p连接不通时用于中转数据。本SDK已内置公开的STUN服务，开发者可以通过P2pConfig来更换STUN地址。TURN服务器则需要开发者自行搭建，可以参考[coturn](https://github.com/coturn/coturn)。
```java
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnection.RTCConfiguration;

List<PeerConnection.IceServer> iceServers = new ArrayList<>();
iceServers.add(PeerConnection.IceServer.builder(YOUR_STUN_OR_TURN_SERVER).createIceServer());
RTCConfiguration rtcConfig = new RTCConfiguration(iceServers);
P2pConfig config = new P2pConfig.Builder()
    .webRTCConfig(rtcConfig)
    .build();
``` -->
