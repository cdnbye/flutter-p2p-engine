#import "CdnbyePlugin.h"
#import <CDNByeKit/CBP2pEngine.h>
#import "CBP2pConfig+FromDic.h"
@interface CdnbyePlugin(){
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
       [[CBP2pEngine sharedInstance] startWithToken:token andP2pConfig:config];
      // NSLog(@"token:\n%@",token);
      result(@1);
  }
  
  else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;

      // NSLog(@"转换URL:\n%@",args);
      NSURL *originalUrl = [NSURL URLWithString:args[@"url"]];
      result([[CBP2pEngine sharedInstance] parseStreamURL :originalUrl].absoluteString);
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
      if ([CBP2pEngine sharedInstance].connected) {
          result([NSNumber numberWithBool:YES]);
      } else {
          result([NSNumber numberWithBool:NO]);
      }
  }
  
  else if([@"restartP2p" isEqualToString:call.method]) {
      [[CBP2pEngine sharedInstance] restartP2p];
      result(@1);
  }
  
  else if([@"stopP2p" isEqualToString:call.method]) {
      [[CBP2pEngine sharedInstance] stopP2p];
      result(@1);
  }
  
  else if([@"getPeerId" isEqualToString:call.method]) {
      result([CBP2pEngine sharedInstance].peerId);
  }
    
  else {
      // NSLog(@"没找到方法:%@",call.method);
      result(FlutterMethodNotImplemented);
  }
}
@end
