//
//  ModuleNative.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/8.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "ModuleNative.h"
#import "KKJSBridge.h"

@implementation ModuleNative

+ (nonnull NSString *)moduleName {
    return @"native";
}

+ (nonnull NSDictionary<NSString *, NSString *> *)methodInvokeMapper {
    // 消息转发，可以把 本模块的消息转发到 c 模块里
    return @{@"method": @"c.method"};
}

- (void)callToTriggerEvent:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    [engine dispatchEvent:@"triggerEvent" data:@{@"eventData": @"dddd"}];
}

- (void)method:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    responseCallback ? responseCallback(@{@"desc": @"我是默认模块"}) : nil;
}

@end
