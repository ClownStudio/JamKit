//
//  ModuleNative.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/8.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "ModuleNative.h"
#import <KKJSBridge.h>
#import "ModuleContext.h"

@interface ModuleNative()<KKJSBridgeModule>

@property (nonatomic, weak) ModuleContext *context;

@end

@implementation ModuleNative

+ (nonnull NSString *)moduleName {
    return @"native";
}

// 模块初始化方法，支持上下文带入
- (instancetype)initWithEngine:(KKJSBridgeEngine *)engine context:(id)context {
    if (self = [super init]) {
        _context = context;
    }

    return self;
}

// 模块提供的方法
- (void)getNativeTitle:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    responseCallback ? responseCallback(@{@"title": [params objectForKey:@"b"] ? [params objectForKey:@"b"] : @""}) : nil;
}

@end
