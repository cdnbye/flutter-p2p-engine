#import "CdnbyePlugin.h"
#import <CDNByeKit/CBP2pEngine.h>
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
      CBP2pConfig *config = [[CBP2pConfig alloc]init];
      
      if([configMap[@"logLevel"] class]!=[NSNull class]){
          config.logLevel = ((NSNumber *)configMap[@"logLevel"]).integerValue;
      }
      if([configMap[@"webRTCConfig"] class]!=[NSNull class]){
//          config.webRTCConfig = (NSDictionary *)configMap[@"webRTCConfig"];
      }
      if([configMap[@"wsSignalerAddr"] class]!=[NSNull class]){
          config.wsSignalerAddr = (NSString *)configMap[@"wsSignalerAddr"];
      }
      if([configMap[@"announce"] class]!=[NSNull class]){
          config.announce = (NSString *)configMap[@"announce"];
      }
      if([configMap[@"p2pEnabled"] class]!=[NSNull class]){
          config.p2pEnabled = ((NSNumber *)configMap[@"p2pEnabled"]).integerValue;
      }
      if([configMap[@"packetSize"] class]!=[NSNull class]){
          config.packetSize = ((NSNumber *)configMap[@"packetSize"]).integerValue;
      }
      if([configMap[@"downloadTimeout"] class]!=[NSNull class]){
          config.downloadTimeout = ((NSNumber *)configMap[@"downloadTimeout"]).integerValue;
      }
      if([configMap[@"dcDownloadTimeout"] class]!=[NSNull class]){
          config.dcDownloadTimeout = ((NSNumber *)configMap[@"dcDownloadTimeout"]).integerValue;
      }
      if([configMap[@"dcUploadTimeout"] class]!=[NSNull class]){
          config.dcUploadTimeout = ((NSNumber *)configMap[@"dcUploadTimeout"]).integerValue;
      }
      if([configMap[@"tag"] class]!=[NSNull class]){
          config.tag = (NSString *)configMap[@"tag"];
      }
      if([configMap[@"agent"] class]!=[NSNull class]){
          config.agent = (NSString *)configMap[@"agent"];
      }
      engine = [[CBP2pEngine alloc]initWithToken:@"free" andP2pConfig:config];
      result(@1);
  } else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;

      NSLog(@"转换URL:\n%@",args);
      result([engine parseStreamURL :args[@"url"]].absoluteString);
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
