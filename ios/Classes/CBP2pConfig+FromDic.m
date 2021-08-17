//
//  CBP2pConfig+FromDic.m
//  cdnbye
//
//  Created by 马嘉伦 on 2019/6/24.
//

#import "CBP2pConfig+FromDic.h"

@implementation SWCP2pConfig (FromDic)

+(instancetype)configFromDictionary:(NSDictionary *)configMap{
    SWCP2pConfig *config = [[SWCP2pConfig alloc]init];
    config.logLevel = ((NSNumber *)configMap[@"logLevel"]).integerValue;
    //config.webRTCConfig = (NSDictionary *)configMap[@"webRTCConfig"];
    
    if(![configMap[@"wsSignalerAddr"] isKindOfClass:[NSNull class]])
        config.wsSignalerAddr = (NSString *)configMap[@"wsSignalerAddr"];
    
    if(![configMap[@"announce"] isKindOfClass:[NSNull class]])
        config.announce = (NSString *)configMap[@"announce"];
    
    config.p2pEnabled = ((NSNumber *)configMap[@"p2pEnabled"]).integerValue;
    config.diskCacheLimit = ((NSNumber *)configMap[@"diskCacheLimit"]).integerValue;
//    config.memoryCacheCountLimit = ((NSNumber *)configMap[@"memoryCacheCountLimit"]).integerValue;
    config.downloadTimeout = ((NSNumber *)configMap[@"downloadTimeout"]).integerValue;
    config.dcDownloadTimeout = ((NSNumber *)configMap[@"dcDownloadTimeout"]).integerValue;
    config.localPortHls = ((NSNumber *)configMap[@"localPort"]).integerValue;
    config.maxPeerConnections = ((NSNumber *)configMap[@"maxPeerConnections"]).integerValue;
    config.tag = (NSString *)configMap[@"tag"];
    config.useHttpRange = ((NSNumber *)configMap[@"useHttpRange"]).integerValue;
    config.wifiOnly = ((NSNumber *)configMap[@"wifiOnly"]).integerValue;
    config.channelIdPrefix = (NSString *)configMap[@"channelIdPrefix"];
    
    NSDictionary* httpHeaders = (NSDictionary *)configMap[@"httpHeaders"];
    if (![httpHeaders isEqual:[NSNull null]]) {
        config.httpHeadersForHls = httpHeaders;
    }
    
    return config;
}


@end
