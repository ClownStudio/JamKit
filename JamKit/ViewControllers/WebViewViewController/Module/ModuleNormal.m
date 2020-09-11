//
//  ModuleNative.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/8.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "ModuleNormal.h"
#import <KKJSBridge.h>
#import "ModuleContext.h"

//  单次调用单次返回的Module
@interface ModuleNormal()<KKJSBridgeModule>

@property (nonatomic, strong) ModuleContext *context;

@end

@implementation ModuleNormal

+ (nonnull NSString *)moduleName {
    return @"normal";
}

// 模块初始化方法，支持上下文带入
- (instancetype)initWithEngine:(KKJSBridgeEngine *)engine context:(id)context {
    if (self = [super init]) {
        _context = context;
    }

    return self;
}

// 模块提供的方法
- (void)showParamsContent:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    responseCallback ? responseCallback(@{@"content": [params objectForKey:@"content"] ? [params objectForKey:@"content"] : @""}) : nil;
}

@end
