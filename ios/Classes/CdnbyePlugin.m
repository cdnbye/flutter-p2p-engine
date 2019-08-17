#import "CdnbyePlugin.h"
#import <CDNByeKit/CBP2pEngine.h>
#import "CBP2pConfig+FromDic.h"
@interface CdnbyePlugin(){
    CBP2pEngine *engine;
    FlutterMethodChannel* channel;
}

@end
@implementation CdnbyePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"cdnbye"
                                   binaryMessenger:[registrar messenger]];
    CdnbyePlugin* instance = [[CdnbyePlugin alloc] init];
    instance->channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      NSDictionary *args = call.arguments;
      // TODO: 实现初始化
      NSLog(@"读取初始化配置:\n%@",args);
      NSDictionary *configMap =args[@"config"];
      CBP2pConfig *config = [CBP2pConfig configFromDictionary:configMap];
      NSString *token = args[@"token"];
      NSLog(@"token:\n%@",token);
      engine = [[CBP2pEngine alloc]initWithToken:token andP2pConfig:config];
      result(@1);
  } else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;

      NSLog(@"转换URL:\n%@",args);
      NSURL *originalUrl = [NSURL URLWithString:args[@"url"]];
      result([engine parseStreamURL :originalUrl].absoluteString);
  }else if([@"startListen" isEqualToString:call.method]){
      NSLog(@"开始监听");
      [[NSNotificationCenter defaultCenter]addObserverForName:kP2pEngineDidReceiveStatistics object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
          [self->channel invokeMethod:@"info" arguments:note.object];
      }];
      result(@1);
  }
  else {
      NSLog(@"没找到方法:%@",call.method);
      result(FlutterMethodNotImplemented);
  }
}


//-(FlutterEventChannel *)flutterEventChannel{
//    if (!_flutterEventChannel) {
//        _flutterEventChannel= [FlutterEventChannel eventChannelWithName:@"cdnbye" binaryMessenger:[registrar messenger]];
//    }
//    return _flutterEventChannel;
//}
//
//- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData * _Nullable)message {
//    <#code#>
//}
//
//- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData * _Nullable)message binaryReply:(FlutterBinaryReply _Nullable)callback {
//    <#code#>
//}
//
//- (void)setMessageHandlerOnChannel:(nonnull NSString *)channel binaryMessageHandler:(FlutterBinaryMessageHandler _Nullable)handler {
//    <#code#>
//}

@end
