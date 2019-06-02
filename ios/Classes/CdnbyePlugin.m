#import "CdnbyePlugin.h"
//#import <CDNByeKit/CBP2pEngine.h>
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
      result(@true);
  } else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;
      // TODO: 实现转换
      NSLog(@"转换URL:\n%@",args);
      result(args[@"url"]);
  }else {
      result(FlutterMethodNotImplemented);
  }
}

@end
