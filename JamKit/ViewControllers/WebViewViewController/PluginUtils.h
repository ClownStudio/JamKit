//
//  PluginUtils.h
//  YinYin
//
//  Created by chenliang on 15/11/10.
//  Copyright © 2015年 China Industrial Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#define CALLFUNCTION_PREFIX_HTTPS @"https://callfunction//"

@interface PluginUtils : NSObject

-(void)executePluginByUrl:(NSString *)url webView:(WKWebView *)wv webViewController:(UIViewController *)webViewController;

-(void)clearTargets;

@end
