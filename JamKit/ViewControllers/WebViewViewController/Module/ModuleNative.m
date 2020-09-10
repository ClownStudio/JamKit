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
#import "FYKeybordFactory.h"
#import <Masonry.h>

typedef void (^KeyBoardResponseBlock)(NSDictionary *responseData);

@interface ModuleNative()<KKJSBridgeModule,FYNumberKeybordViewDelegate>

@property (nonatomic, weak) ModuleContext *context;

@end

@implementation ModuleNative{
     KeyBoardResponseBlock _responseCallback;
}

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
- (void)showParamsContent:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    responseCallback ? responseCallback(@{@"title": [params objectForKey:@"b"] ? [params objectForKey:@"b"] : @""}) : nil;
}

- (void)showNumberKeyboard:(KKJSBridgeEngine *)engine params:(NSDictionary *)params responseCallback:(void (^)(NSDictionary *responseData))responseCallback {
    FYNumberKeybordView *keybordView = [FYKeybordFactory fy_createNumberKeybordViewWithNumberPadType:normalNumberPadType];
    keybordView.fyNumberKeybordDelegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:keybordView];
    [keybordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(@0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo([UIApplication sharedApplication].keyWindow).mas_offset(-[UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom);
        } else {
            make.bottom.equalTo([UIApplication sharedApplication].keyWindow);
        }
        make.height.equalTo(@247);
    }];
    _responseCallback = responseCallback;
}

- (void)fyNumberKeybordView:(FYNumberKeybordView *)numberKeybordView clickNumberStr:(NSString *)clickNumberStr{
    if (_responseCallback) {
        _responseCallback(@{@"value":clickNumberStr});
    }
}

- (void)clickDeleteButtonWithFYNumberKeybordView:(FYNumberKeybordView *)numberKeybordView{
//    if (_responseCallback) {
//        _responseCallback(clickNumberStr);
//    }
}

@end
