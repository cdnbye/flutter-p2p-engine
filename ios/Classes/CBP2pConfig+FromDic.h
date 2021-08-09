//
//  CBP2pConfig+FromDic.h
//  cdnbye
//
//  Created by 马嘉伦 on 2019/6/24.
//

#import <SwarmCloudSDK/SwarmCloudSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWCP2pConfig (FromDic)
+(instancetype)configFromDictionary:(NSDictionary *)configMap;
@end

NS_ASSUME_NONNULL_END
