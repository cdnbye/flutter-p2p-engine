**English | [简体中文](Readme_zh.md)**

<h1 align="center"><a href="" target="_blank" rel="noopener noreferrer"><img width="250" src="https://cdnbye.oss-cn-beijing.aliyuncs.com/pic/cdnbye.png" alt="cdnbye logo"></a></h1>
<h4 align="center">Live/VOD P2P Engine for Flutter</h4>
<p align="center">
<a href="https://pub.dartlang.org/packages/cdnbye"><img src="https://img.shields.io/pub/v/cdnbye.svg" alt="pub"></a>
</p>

## Features
- Support iOS and Android platform
- Support live and VOD streams over HLS protocol(m3u8)
- Support encrypted HLS stream
- Support cache to avoid repeating the download of TS file
- Very easy to integrate with an existing flutter project
- Support any flutter player
- Efficient scheduling policies to enhance the performance of P2P streaming
- Highly configurable
- Use IP database to group up peers by ISP and regions

## Screenshot
<div style="text-align: center"><table><tr>
<td style="text-align: center">
<img src="./figs/list.jpeg" width="250"/>
</td>
  <td style="text-align: center">
<img src="./figs/detail.jpeg" width="250"/>
</td>
</tr></table></div>

## Environment Configuration
See [documentation](https://docs.cdnbye.com/#/flutter)

## Example
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

## Example using ijk_player.

[cdnbye_ijk_example](https://github.com/mjl0602/cdnbye_ijk_example)

## Obtain Token
See [here](https://docs.cdnbye.com/#/en/bindings?id=app-id-and-token)

## Consloe
Register your AppId at https://oms.cdnbye.com, where you can view p2p-related information.

## Issue & Feature Request
- If you found a bug, open an issue.
- If you have a feature request, open an issue.

## Related Projects
- [hlsjs-p2p-engine](https://github.com/cdnbye/hlsjs-p2p-engine) - Web Video Delivery Technology with No Plugins.
- [ios-p2p-engine](https://github.com/cdnbye/ios-p2p-engine) -  iOS Video P2P Engine for Any Player.
- [android-p2p-engine](https://github.com/cdnbye/android-p2p-engine) -  iOS Video P2P Engine for Any Player.

## FAQ
We have collected some [frequently asked questions](https://docs.cdnbye.com/#/en/FAQ). Before reporting an issue, please search if the FAQ has the answer to your problem.

## Contact Us
Email：service@cdnbye.com
