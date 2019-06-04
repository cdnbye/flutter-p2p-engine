#import "CdnbyePlugin.h"
#import <CDNByeKit/CBP2pEngine.h>
@interface CdnbyePlugin(){
    CBP2pEngine *engine;
}

@end
@implementation CdnbyePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"cdnbye"
            binaryMessenger:[registrar messenger]];
  CdnbyePlugin* instance = [[CdnbyePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      NSDictionary *args = call.arguments;
      // TODO: 实现初始化
      NSLog(@"读取初始化配置:\n%@",args);
      CBP2pConfig *config = [[CBP2pConfig alloc]init];
      config.announce = @"https://tracker.cdnbye.com:8090";
      config.logLevel =  CBLogLevelDebug;
      engine = [[CBP2pEngine alloc]initWithToken:@"free" andP2pConfig:config];
      result(@true);
  } else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;
      // TODO: 实现转换
      NSLog(@"转换URL:\n%@",args);
      result([engine parseStreamURL :args[@"url"]].absoluteString);
  }else {
      result(FlutterMethodNotImplemented);
  }
}

@end
