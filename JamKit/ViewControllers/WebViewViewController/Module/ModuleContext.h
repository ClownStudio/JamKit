//
//  ModuleContext.h
//  KKJSBridgeDemo
//
//  Created by karos li on 2019/8/29.
//  Copyright © 2019 karosli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModuleContext : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) KKWebView *webview;

@end

NS_ASSUME_NONNULL_END
