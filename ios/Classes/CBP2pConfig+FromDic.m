//
//  CBP2pConfig+FromDic.m
//  cdnbye
//
//  Created by 马嘉伦 on 2019/6/24.
//

#import "CBP2pConfig+FromDic.h"

@implementation CBP2pConfig (FromDic)

+(instancetype)configFromDictionary:(NSDictionary *)configMap{
    CBP2pConfig *config = [[CBP2pConfig alloc]init];
    config.logLevel = ((NSNumber *)configMap[@"logLevel"]).integerValue;
    //config.webRTCConfig = (NSDictionary *)configMap[@"webRTCConfig"];
    config.wsSignalerAddr = (NSString *)configMap[@"wsSignalerAddr"];
    config.announce = (NSString *)configMap[@"announce"];
    config.p2pEnabled = ((NSNumber *)configMap[@"p2pEnabled"]).integerValue;
    config.packetSize = ((NSNumber *)configMap[@"packetSize"]).integerValue;
    config.downloadTimeout = ((NSNumber *)configMap[@"downloadTimeout"]).integerValue;
    config.dcDownloadTimeout = ((NSNumber *)configMap[@"dcDownloadTimeout"]).integerValue;
//    config.dcUploadTimeout = ((NSNumber *)configMap[@"dcUploadTimeout"]).integerValue;
    config.tag = (NSString *)configMap[@"tag"];
    config.agent = (NSString *)configMap[@"agent"];
    return config;
}


@end
