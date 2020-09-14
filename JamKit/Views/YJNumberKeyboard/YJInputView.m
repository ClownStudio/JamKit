//
//  YJInputView.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/11.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "YJInputView.h"
#import "KRKeyboard.h"

@implementation YJInputView

static YJInputView* keyboardInputViewInstance = nil;
static YJInputView* keyboardViewTypePasswordInstance = nil;
static YJInputView* keyboardViewTypeNumInstance = nil;
static YJInputView* keyboardViewTypeLetterInstance = nil;

// 默认可切换键盘
+(YJInputView *)shareInputViewWithTypeAll
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboardInputViewInstance = [[YJInputView alloc] initWithSafeKeyboardType:CommonKeyboard];
    });
    return keyboardInputViewInstance;
}
// 数字
+(YJInputView *)shareInputViewWithTypeNum
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboardViewTypeNumInstance = [[YJInputView alloc] initWithSafeKeyboardType:NumberKeyboard];
    });
    return keyboardViewTypeNumInstance;
}
// 交易密码
+(YJInputView *)shareInputViewWithTypePassword
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboardViewTypePasswordInstance = [[YJInputView alloc] initWithSafeKeyboardType:PassWordKeyboard];
    });
    return keyboardViewTypePasswordInstance;
}
// 字母
+(YJInputView *)shareKBInputViewWithTypeLetter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboardViewTypeLetterInstance = [[YJInputView alloc] initWithSafeKeyboardType:LetterKeyboard];
    });
    return keyboardViewTypeLetterInstance;
}

- (instancetype)initWithSafeKeyboardType:(KRKeyboardType)type
{
    self = [super init];
    if (self) {
        self.textField = [[UITextField alloc] init];
        self.textField.delegate = self;
        KRKeyboard *keyboard = [KRKeyboard creatWithKeyboardType:type delegateTarget:self];
        [self addSubview:self.textField];
    }
    return self;
}

@end
