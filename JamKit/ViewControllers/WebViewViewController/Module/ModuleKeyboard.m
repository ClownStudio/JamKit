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
#import <objc/runtime.h>

@interface _NoInputAccessoryView : NSObject

-(void)hideWKWebviewKeyboardShortcutBar:(KKWebView *)webview;

@end


@implementation _NoInputAccessoryView

-(id)inputAccessoryView{
    return nil;
}

-(void)hideWKWebviewKeyboardShortcutBar:(KKWebView *)webview
{
    UIView *targetView ;
    for (UIView *view in webview.scrollView.subviews) {
        if ([[view.class description] hasPrefix:@"WKContent"]) {
            targetView = view;
        }
    }
    if (!targetView) {
        return;
    }

    NSString *noInputAccessoryViewClassName = [NSString stringWithFormat:@"%@_NoInputAccessoryView",targetView.class.superclass];
    Class newClass = NSClassFromString(noInputAccessoryViewClassName);
    if (newClass == nil) {
        //创建一个类class 类型 类名
        newClass = objc_allocateClassPair(targetView.class, [noInputAccessoryViewClassName cStringUsingEncoding:NSASCIIStringEncoding], 0);
        if (!newClass) {
            return;
        }
        //实例方法
        Method method = class_getInstanceMethod([_NoInputAccessoryView class], @selector(inputAccessoryView));
        //添加成员方法
        class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));
        objc_registerClassPair(newClass);
    }

    object_setClass(targetView, newClass);
    [targetView reloadInputViews];
}

@end

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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    NSString *textTag = [params objectForKey:@"textTag"];
    self.input.textTag = textTag;
    
    NSString *text = [params objectForKey:@"content"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.input showWithOriginText:text];
    });
    self.input.inputViewDelegate = self;
}

-(void)keyboardWillShow:(NSNotification *)notificaiton{
    _NoInputAccessoryView *noInputAccessoryView = [[_NoInputAccessoryView alloc]init];
    [noInputAccessoryView hideWKWebviewKeyboardShortcutBar:_context.webview];
}

- (void)editTextWithTag:(NSString *)textTag content:(NSString *)content{
    NSString *js = [NSString stringWithFormat:@"var field = document.getElementById('%@'); field.value = '%@'; ",textTag,content];
    [_context.webview evaluateJavaScript:js completionHandler:nil];
}

@end
