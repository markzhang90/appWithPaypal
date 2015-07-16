//
//  ZZAppDelegate.m
//  PayPal-iOS-SDK-Sample-App
//
//  Copyright (c) 2014, PayPal
//  All rights reserved.
//

#import "AppWithPaypalDelegate.h"
#import "PayPalMobile.h"

@implementation AppWithPaypalDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#warning "mock version Enter your credentials"
  [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                         PayPalEnvironmentSandbox : @"YOUR_CLIENT_ID_FOR_SANDBOX"}];
  return YES;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application{
    
}
@end
