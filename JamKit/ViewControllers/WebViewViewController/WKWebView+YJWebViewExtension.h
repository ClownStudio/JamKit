//
//  WKWebView+YJWebViewExtension.h
//  JamKit
//
//  Created by 张文洁 on 2020/8/31.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, YJWebViewConfigUAType) {
    YJWebViewConfigUATypeReplace,     //replace all UA string
    YJWebViewConfigUATypeAppend,      //append to original UA string
};

@interface WKWebView (YJWebViewExtension)

#pragma mark - UA
+ (void)configCustomUAWithType:(YJWebViewConfigUAType)type
                      UAString:(NSString *)customString;

#pragma mark - clear webview cache

+ (void)safeClearAllCacheIncludeiOS8:(BOOL)includeiOS8;


@end

NS_ASSUME_NONNULL_END
