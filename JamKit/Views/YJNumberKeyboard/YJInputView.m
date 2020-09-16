//
//  YJInputView.m
//  JamKit
//
//  Created by 张文洁 on 2020/9/11.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "YJInputView.h"

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
+(YJInputView *)shareInputViewWithTypeLetter
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
        self.textField.inputAccessoryView = nil;
        
        [self addSubview:self.textField];
        _keyboard = [KRKeyboard creatWithKeyboardType:type delegateTarget:self];
        self.textField.inputView = _keyboard;
    }
    return self;
}

- (void)showWithOriginText:(NSString *)text{
    UIViewController *topVC = [self getCurrentViewController];
    [topVC.view addSubview:self];
    [_keyboard setContent:text];
    [self.textField becomeFirstResponder];
}

- (void)pressKey:(NSString *)key keyType:(KRKeyType)keyType keyboardType:(KRKeyboardType)keyboardType content:(NSString *)content{
    if (keyType == DoneKeyType) {
        [self.textField resignFirstResponder];
        return;
    }
    if (self.inputViewDelegate && [self.inputViewDelegate respondsToSelector:@selector(editTextWithTag: content:)])
    {
        [self.inputViewDelegate editTextWithTag:_textTag content:content];
    }
}

#pragma mark - getter setter

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentViewController{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

@end
