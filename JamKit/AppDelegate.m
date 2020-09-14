//
//  AppDelegate.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/28.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "RootViewController.h"
#import "UserAgentUtil.h"
#import <IQKeyboardManager.h>
#import "Masonry.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    RootViewController *rootViewController = [[RootViewController alloc] initWithRootViewController:[[MainViewController alloc] init]];
    [rootViewController setNavigationBarHidden:YES];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.autoresizesSubviews = YES;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:rootViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
