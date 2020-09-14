//
//  YJInputView.h
//  JamKit
//
//  Created by 张文洁 on 2020/9/11.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRKeyboard.h"

@class YJInputView;

NS_ASSUME_NONNULL_BEGIN

// 点击的代理事件 传递到外层
@protocol YJInputViewDelegate <NSObject>
// 每次输入的代理事件
- (void)editTextWithTag:(NSString *)textTag content:(NSString *)content;

@end

@interface YJInputView : UIView <UITextFieldDelegate,KRKeyboardDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) NSMutableString *placeholderText;
@property (nonatomic, strong) NSString *textTag;
@property (nonatomic, weak) id<YJInputViewDelegate> inputViewDelegate;

/**
 *  带字母 字符 数字切换工具条
 */
+(YJInputView *)shareInputViewWithTypeAll;
/**
 *  数字
 */
+(YJInputView *)shareInputViewWithTypeNum;
/**
 *  密码键盘
 */
+(YJInputView *)shareInputViewWithTypePassword;
/**
 *  字母+符号
 */
+(YJInputView *)shareInputViewWithTypeLetter;

- (void)show;

@end

NS_ASSUME_NONNULL_END
