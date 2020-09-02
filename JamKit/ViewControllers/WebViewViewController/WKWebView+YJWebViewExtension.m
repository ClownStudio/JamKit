//
//  WKWebView+YJWebViewExtension.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/31.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "WKWebView+YJWebViewExtension.h"
#import <objc/runtime.h>

@implementation WKWebView (YJWebViewExtension)

#pragma mark - UA

+ (void)configCustomUAWithType:(YJWebViewConfigUAType)type
                      UAString:(NSString *)customString {
    if (!customString || customString.length <= 0) {
        NSLog(@"WKWebView (SyncConfigUA) config with invalid string");
        return;
    }
    
    if (type == YJWebViewConfigUATypeReplace) {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:customString, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    } else if (type == YJWebViewConfigUATypeAppend) {
        
        //同步获取webview UserAgent
        NSString *originalUserAgent;
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        SEL privateUASel = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@%@%@",@"_",@"user",@"Agent"]);
        if ([webView respondsToSelector:privateUASel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            originalUserAgent = [webView performSelector:privateUASel];
#pragma clang diagnostic pop
        }
        
        NSString *appUserAgent = [NSString stringWithFormat:@"%@ %@", originalUserAgent ?: @"", customString];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:appUserAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    } else {
        NSLog(@"WKWebView (SyncConfigUA) config with invalid type :%@", @(type));
    }
}

#pragma mark - clear webview cache

static inline void clearWebViewCacheFolderByType(NSString *cacheType) {
    static dispatch_once_t once;
    static NSDictionary *cachePathMap = nil;
    dispatch_once(&once,
                  ^{
                      NSString *bundleId = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleIdentifierKey];
                      NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
                      NSString *storageFileBasePath = [libraryPath stringByAppendingPathComponent:
                                                       [NSString stringWithFormat:@"WebKit/%@/WebsiteData/", bundleId]];
                      cachePathMap = @{ @"WKWebsiteDataTypeCookies":
                                            [libraryPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"],
                                        @"WKWebsiteDataTypeLocalStorage":
                                            [storageFileBasePath stringByAppendingPathComponent:@"LocalStorage"],
                                        @"WKWebsiteDataTypeIndexedDBDatabases":
                                            [storageFileBasePath stringByAppendingPathComponent:@"IndexedDB"],
                                        @"WKWebsiteDataTypeWebSQLDatabases":
                                            [storageFileBasePath stringByAppendingPathComponent:@"WebSQL"] };
                  });
    NSString *filePath = cachePathMap[cacheType];
    if (filePath && filePath.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"removed file fail: %@ ,error %@", [filePath lastPathComponent], error);
            }
        }
    }
}

+ (void)safeClearAllCacheIncludeiOS8:(BOOL)includeiOS8 {
    if (@available(iOS 9, *)) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeSessionStorage,
                                                        WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeOfflineWebApplicationCache,
                                                        WKWebsiteDataTypeCookies,
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeIndexedDBDatabases,
                                                        WKWebsiteDataTypeWebSQLDatabases
                                                        ]];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                                   modifiedSince:date
                                               completionHandler:^{
                                                   NSLog(@"Clear All Cache Done");
                                               }];
    } else {
        if (includeiOS8) {
            NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                            @"WKWebsiteDataTypeCookies",
                                                            @"WKWebsiteDataTypeLocalStorage",
                                                            @"WKWebsiteDataTypeIndexedDBDatabases",
                                                            @"WKWebsiteDataTypeWebSQLDatabases"
                                                            ]];
            for (NSString *type in websiteDataTypes) {
                clearWebViewCacheFolderByType(type);
            }
        }
    }
}

@end
