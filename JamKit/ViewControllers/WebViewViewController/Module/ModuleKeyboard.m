//
//  ModuleNative.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/8.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "ModuleKeyboard.h"
#import <KKJSBridge.h>
#import "ModuleContext.h"
#import "WebViewViewController.h"
#import "YJInputView.h"

@interface ModuleKeyboard()<KKJSBridgeModule,YJInputViewDelegate>

@property (nonatomic, strong) ModuleContext *context;
@property (nonatomic, strong) YJInputView *input;

@end

@implementation ModuleKeyboard

+ (nonnull NSString *)moduleName {
    return @"keyboard";
}

+ (BOOL)isSingleton {
    return true;
}

// 模块初始化方法，支持上下文带入
- (instancetype)initWithEngine:(KKJSBridgeEngine *)engine context:(id)context {
    if (self = [super init]) {
        _context = context;
    }
    
    return self;
}

- (void)showNativeKeyboard:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    NSString *type = [params objectForKey:@"type"];
    if ([type isEqualToString:@"letter"])
    {
        self.input = [YJInputView shareInputViewWithTypeLetter];
    }
    else if ([type isEqualToString:@"number"])
    {
        self.input = [YJInputView shareInputViewWithTypeNum];
    }
    else if ([type isEqualToString:@"password"])
    {
        self.input = [YJInputView shareInputViewWithTypeNum];
    }
    else if ([type isEqualToString:@"all"])
    {
        self.input = [YJInputView shareInputViewWithTypeAll];
    }
    
    NSString *textTag = [params objectForKey:@"textTag"];
    self.input.textTag = textTag;
    
    NSString *text = [params objectForKey:@"content"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.input showWithOriginText:text];
    });
    
    self.input.inputViewDelegate = self;
}

- (void)editTextWithTag:(NSString *)textTag content:(NSString *)content{
    NSString *js = [NSString stringWithFormat:@"var field = document.getElementById('%@'); field.value = '%@'; ",textTag,content];
    [_context.webview evaluateJavaScript:js completionHandler:nil];
}

@end
