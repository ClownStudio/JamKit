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
#import "SafeKBInputView.h"
#import <Masonry.h>
#import "WebViewViewController.h"

typedef void (^KeyBoardResponseBlock)(NSDictionary *responseData);

@interface ModuleNative()<KKJSBridgeModule,SafeKBInputViewDelegate>

@property (nonatomic, strong) ModuleContext *context;
@property (nonatomic, strong) SafeKBInputView *input;

@end

@implementation ModuleNative{
     KeyBoardResponseBlock _responseCallback;
}

+ (nonnull NSString *)moduleName {
    return @"native";
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

// 模块提供的方法
- (void)showParamsContent:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    responseCallback ? responseCallback(@{@"title": [params objectForKey:@"b"] ? [params objectForKey:@"b"] : @""}) : nil;
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
    NSString *textId = [params objectForKey:@"textId"];
    self.input.textId = textId;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.input show];
    });
    self.input.InputViewDelegate = self;
    _responseCallback = responseCallback;
}

-(void)safeKBInputViewDidChangeText:(SafeKBInputView *)inputView{
    NSString *encodeStr = [inputView.trueText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPasswordAllowedCharacterSet]];
    NSString *js = [NSString stringWithFormat:@"var field = document.getElementById('%@'); field.value= '%@'; ",inputView.textId,encodeStr];
    [_context.webview evaluateJavaScript:js completionHandler:nil];
}

@end
