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
#import "SafeKBInputView.h"
#import <Masonry.h>
#import "WebViewViewController.h"

@interface ModuleKeyboard()<KKJSBridgeModule,SafeKBInputViewDelegate>

@property (nonatomic, strong) ModuleContext *context;
@property (nonatomic, strong) SafeKBInputView *input;

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
    if ([type isEqualToString:@"abc"])
    {
        self.input = [SafeKBInputView shareKBInputViewWithTypeABC];
    }
    else if ([type isEqualToString:@"num"])
    {
        self.input = [SafeKBInputView shareKBInputViewWithTypeNum];
    }
    else if ([type isEqualToString:@"all"])
    {
        self.input = [SafeKBInputView shareKBInputViewWithTypeAll];
    }
    NSString *textTag = [params objectForKey:@"textTag"];
    self.input.textTag = textTag;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.input show];
    });
    self.input.InputViewDelegate = self;
}

-(void)safeKBInputViewDidChangeText:(SafeKBInputView *)inputView{
    NSString *js = [NSString stringWithFormat:@"var field = document.getElementById('%@'); field.value = '%@'; ",inputView.textTag,inputView.trueText];
    [_context.webview evaluateJavaScript:js completionHandler:nil];
}

@end
