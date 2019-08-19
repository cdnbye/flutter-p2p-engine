**[English](README.md) | 简体中文**

<h1 align="center"><a href="" target="_blank" rel="noopener noreferrer"><img width="250" src="https://cdnbye.oss-cn-beijing.aliyuncs.com/pic/cdnbye.png" alt="cdnbye logo"></a></h1>
<h4 align="center">Flutter视频/直播APP省流量&加速神器.</h4>
<p align="center">
<a href="https://pub.dartlang.org/packages/cdnbye"><img src="https://img.shields.io/pub/v/cdnbye.svg" alt="pub"></a>
</p>

该插件的优势如下：
- 支持iOS和安卓平台，可与[Web端插件]((https://github.com/cdnbye/hlsjs-p2p-engine))P2P互通
- 支持基于HLS流媒体协议(m3u8)的直播和点播场景
- 支持加密HLS传输
- 支持ts文件缓存从而避免重复下载
- 几行代码即可在现有Flutter项目中快速集成
- 支持任何Flutter播放器
- 通过预加载形式实现P2P加速，完全不影响用户的播放体验
- 高可配置化，用户可以根据特定的使用环境调整各个参数
- 通过有效的调度策略来保证用户的播放体验以及p2p分享率
- Tracker服务器根据访问IP的ISP、地域等进行智能调度

## 引入插件
在项目的[pubspec.yaml](https://flutterchina.club/using-packages/)中添加 `cdnbye` 作为依赖。

## iOS
系统要求：支持iOS 9.0以上系统。注意：本SDK暂时不支持bitcode，在发布前请在xcode关闭bitcode。
<br>
CDNBye通过本地代理服务器拦截数据请求的方式来进行P2P缓存和传输，所以需要在项目的info.plist中允许HTTP请求：
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Android
系统要求：安卓4.4以上版本(API level >= 19)
<br>
在`app/src/main`目录中的`AndroidManifest.xml`中增加如下权限声明:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```
从Android P系统开始，如果应用使用的是非加密的明文流量的http网络请求，则会导致该应用无法进行网络请求，https则不会受影响。由于本地代理服务需要使用http协议访问，针对这个问题，有以下两种解决方法：
<br>
（1） `targetSdkVersion` 降到27以下
<br>
（2） 更改网络安全配置，在`app/src/main`目录中的`AndroidManifest.xml`的<application>标签中直接插入：
```xml
<application
  ...
  android:usesCleartextTraffic="true"
  ...
    />
```
在`app/build.gradle`中加入以下配置以开启Java8支持：
```
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

## 示例
```dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cdnbye/cdnbye.dart';

// Init p2p engine
_initEngine();

// Start playing video
_loadVideo();

_initEngine() async {
    await Cdnbye.init(
      YOUR_TOKEN,
      config: P2pConfig.byDefault()
    );
}

_loadVideo() async {
    var url = YOUR_STREAM_URL;
    url = await Cdnbye.parseStreamURL(url);           // Parse your stream url
    player = VideoPlayerController.network(url);
    player.play();
}
```

## 获取Token
参考[如何获取token](https://docs.cdnbye.com/#/bindings?id=%e7%bb%91%e5%ae%9a-app-id-%e5%b9%b6%e8%8e%b7%e5%8f%96token)

## 反馈及意见
当你遇到任何问题时，可以通过在 GitHub 的 repo 提交 issues 来反馈问题，请尽可能的描述清楚遇到的问题，如果有错误信息也一同附带，并且在 Labels 中指明类型为 bug 或者其他。

## 相关项目
- [hlsjs-p2p-engine](https://github.com/cdnbye/hlsjs-p2p-engine) - 目前最好的Web端P2P流媒体方案。
- [ios-p2p-engine](https://github.com/cdnbye/ios-p2p-engine) - iOS端P2P流媒体加速引擎。
- [android-p2p-engine](https://github.com/cdnbye/android-p2p-engine) - 安卓端P2P流媒体加速引擎。

## FAQ
我们收集了一些[常见问题](https://docs.cdnbye.com/#/FAQ)。在报告issue之前请先查看一下。

## 联系我们
邮箱：service@cdnbye.com
