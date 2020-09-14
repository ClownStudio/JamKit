//
//  NoInputAccessoryView.h
//  JamKit
//
//  Created by 张文洁 on 2020/9/14.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoInputAccessoryView : NSObject

- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
