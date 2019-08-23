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
      // NSLog(@"读取初始化配置:\n%@",args);
      NSDictionary *configMap =args[@"config"];
      CBP2pConfig *config = [CBP2pConfig configFromDictionary:configMap];
      NSString *token = args[@"token"];
      // NSLog(@"token:\n%@",token);
      engine = [[CBP2pEngine alloc]initWithToken:token andP2pConfig:config];
      result(@1);
  }
  
  else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;

      // NSLog(@"转换URL:\n%@",args);
      NSURL *originalUrl = [NSURL URLWithString:args[@"url"]];
      result([engine parseStreamURL :originalUrl].absoluteString);
  }
  
  else if([@"startListen" isEqualToString:call.method]){
      // NSLog(@"开始监听");
      [[NSNotificationCenter defaultCenter]addObserverForName:kP2pEngineDidReceiveStatistics object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
          [self->channel invokeMethod:@"info" arguments:note.object];
      }];
      result(@1);
  }
  
  else if([@"getPlatformVersion" isEqualToString:call.method]) {
      result(CBP2pEngine.engineVersion);
  }
  
  else if([@"isConnected" isEqualToString:call.method]) {
      if (engine.connected) {
          result(@1);
      } else {
          result(@0);
      }
  }
  
  else if([@"restartP2p" isEqualToString:call.method]) {
      [engine restartP2p];
      result(@1);
  }
  
  else if([@"stopP2p" isEqualToString:call.method]) {
      [engine stopP2p];
      result(@1);
  }
  
  else if([@"getPeerId" isEqualToString:call.method]) {
      result(engine.peerId);
  }
    
  else {
      // NSLog(@"没找到方法:%@",call.method);
      result(FlutterMethodNotImplemented);
  }
}
@end
