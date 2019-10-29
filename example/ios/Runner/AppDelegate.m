#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <CDNByeKit/CBP2pEngine.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
  [[CBP2pEngine sharedInstance] startWithToken:@"free" andP2pConfig:nil];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
