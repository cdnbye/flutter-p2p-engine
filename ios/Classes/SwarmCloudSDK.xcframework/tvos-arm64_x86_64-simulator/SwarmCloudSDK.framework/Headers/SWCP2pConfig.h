//
//  SWCP2pConfig.h
//  SwarmCloudSDK
//
//  Created by Timmy on 2021/5/5.
//  Copyright © 2021 SwarmCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebRTC/RTCConfiguration.h"

typedef NS_ENUM(NSInteger, SWCLogLevel) {
    SWCLogLevelNone,
    SWCLogLevelDebug,
    SWCLogLevelInfo,
    SWCLogLevelWarn,
    SWCLogLevelError,
};

NS_ASSUME_NONNULL_BEGIN

@interface SWCP2pConfig : NSObject

/** WebRTC configuration. WebRTC配置 */
@property(nonatomic, strong, nullable) RTCConfiguration *webRTCConfig;

/** The address of signal server. 信令服务器地址 */
@property(nonatomic, copy, nullable) NSString *wsSignalerAddr;

/** The address of tracker server. tracker服务器地址 */
@property(nonatomic, copy, nullable) NSString *announce;

/** Enable or disable p2p engine. 是否开启P2P，默认true */
@property(nonatomic, assign) BOOL p2pEnabled;

/** Only allow uploading on Wi-Fi. 是否只在wifi模式上传数据 */
@property(nonatomic, assign) BOOL wifiOnly;

/** The port for local http server. Hls本地代理服务器的端口号 */
@property(nonatomic, assign) NSInteger localPortHls;

/** The port for local http server. Mp4本地代理服务器的端口号 */
@property(nonatomic, assign) NSInteger localPortMp4;

/** Max download timeout for WebRTC datachannel. datachannel下载二进制数据的最大超时时间 */
@property(nonatomic, assign) NSTimeInterval dcDownloadTimeout;

/** The max size of binary data that can be stored in the disk for VOD. 磁盘缓存大小 */
@property(nonatomic, assign) NSUInteger diskCacheLimit;

/** The max size of binary data that can be stored in the memory cache. 内存缓存大小 */
@property(nonatomic, assign) NSUInteger memoryCacheLimit;

/** TS file download timeout. 下载ts文件超时时间 */
@property(nonatomic, assign) NSTimeInterval downloadTimeout;

/** User defined tag which is presented in console. 用户自定义标签 */
@property(nonatomic, copy) NSString *tag;

/** Print log level. 打印日志级别 */
@property(nonatomic, assign) SWCLogLevel logLevel;

/** Max peer connections at the same time. 最大连接节点数量 */
@property(nonatomic, assign) NSUInteger maxPeerConnections;

/** Use HTTP ranges requests where it is possible. Allows to continue (and not start over) aborted P2P downloads over HTTP. 在可能的情况下使用Http Range请求来补足p2p下载超时的剩余部分数据 */
@property(nonatomic, assign) BOOL useHttpRange;

/** Set http headers while requesting ts and m3u8. 设置请求ts和m3u8时的http headers */
@property(nonatomic, copy) NSDictionary *httpHeadersForHls;
@property(nonatomic, copy) NSDictionary *httpHeadersForMp4;
//@property(nonatomic, copy) NSDictionary *httpHeadersForFile;

/** Required while using customized channelId(5 <= length <= 15), recommended to set it as the unique identifier of your organization. 如果使用自定义的channelId，则此字段必须设置，且长度必须大于4个字符并且小于16个字符，建议设置成你所在组织的唯一标识 */
@property(nonatomic, copy) NSString *channelIdPrefix;

@property(nonatomic, assign) BOOL trickleICE;

@property(nonatomic, assign) BOOL sharePlaylist;

@property(nonatomic, assign) NSTimeInterval httpLoadTime;

@property(nonatomic, assign) BOOL scheduledBySegId;

//@property(nonatomic, assign) NSUInteger pieceLengthForMp4;

//@property(nonatomic, assign) NSUInteger maxSubscribeLevel;

/**
 Create a new instance with default configuration.
 实例化方法，用默认配置初始化。
 */
+ (instancetype)defaultConfiguration;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
