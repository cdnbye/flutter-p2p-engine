#import "CdnbyePlugin.h"
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

+ (NSString *)SWCRangeGetHeaderString:(SWCRange)range
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"bytes="];
    if (range.start != SWCNotFound) {
        [string appendFormat:@"%lld", range.start];
    }
    [string appendFormat:@"-"];
    if (range.end != SWCNotFound) {
        [string appendFormat:@"%lld", range.end];
    }
    return [string copy];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      NSDictionary *args = call.arguments;
      // NSLog(@"读取初始化配置:\n%@",args);
      NSDictionary *configMap =args[@"config"];
      SWCP2pConfig *config = [SWCP2pConfig configFromDictionary:configMap];
      NSString *token = args[@"token"];
      [[SWCP2pEngine sharedInstance] startWithToken:token andP2pConfig:config];
      // NSLog(@"token:\n%@",token);

      [SWCP2pEngine sharedInstance].segmentIdForHls = ^NSString * _Nonnull(NSString * _Nonnull streamId, NSNumber * _Nonnull sn, NSString * _Nonnull segmentUrl, SWCRange byteRange) {
          NSDictionary *arguments = @{
              @"streamId": streamId,
              @"sn": sn,
              @"segmentUrl": segmentUrl,
          };
          NSMutableDictionary *argumentsM = [NSMutableDictionary dictionaryWithDictionary:arguments];
          if (byteRange.start == SWCNotFound) {
              argumentsM[@"range"] = [NSNull null];
          } else {
              argumentsM[@"range"] = [CdnbyePlugin SWCRangeGetHeaderString:byteRange];
          }
          __block NSString *segmentId = segmentUrl;
          dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
          [self->channel invokeMethod:@"segmentId" arguments:argumentsM result:^(id  _Nullable result) {
              if (result) {
                  NSDictionary *map = (NSDictionary *)result;
                  segmentId = (NSString *)map[@"result"];
              }
              dispatch_semaphore_signal(semaphore);
          }];
          dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC));
          return segmentId;
      };

      result(@1);
  }
  
  else if([@"parseStreamURL" isEqualToString:call.method]){
      NSDictionary *args = call.arguments;

      // NSLog(@"转换URL:\n%@",args);
      NSURL *originalUrl = [NSURL URLWithString:args[@"url"]];
      NSString *targetUrl = @"";
      if ([args[@"videoId"] isKindOfClass:[NSNull class]]) {
          targetUrl = [[SWCP2pEngine sharedInstance] parseStreamURL:originalUrl].absoluteString;
      }else{
          targetUrl = [[SWCP2pEngine sharedInstance] parseStreamURL:originalUrl withVideoId:args[@"videoId"]].absoluteString;
      }
     
      result(targetUrl);
      
  }
  
  else if([@"startListen" isEqualToString:call.method]){
      // NSLog(@"开始监听");
      [[NSNotificationCenter defaultCenter]addObserverForName:kP2pEngineDidReceiveStatistics object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
          [self->channel invokeMethod:@"info" arguments:note.object];
      }];
      result(@1);
  }
  
  else if([@"getPlatformVersion" isEqualToString:call.method]) {
      result(SWCP2pEngine.engineVersion);
  }
  
  else if([@"isConnected" isEqualToString:call.method]) {
      if ([SWCP2pEngine sharedInstance].isConnected) {
          result([NSNumber numberWithBool:YES]);
      } else {
          result([NSNumber numberWithBool:NO]);
      }
  }
  
  else if([@"restartP2p" isEqualToString:call.method]) {
      [[SWCP2pEngine sharedInstance] restartP2p];
      result(@1);
  }
  
  else if([@"stopP2p" isEqualToString:call.method]) {
      [[SWCP2pEngine sharedInstance] stopP2p];
      result(@1);
  }
  
  else if([@"getPeerId" isEqualToString:call.method]) {
      result([SWCP2pEngine sharedInstance].peerId);
  }
    
  else {
      // NSLog(@"没找到方法:%@",call.method);
      result(FlutterMethodNotImplemented);
  }
}
@end
