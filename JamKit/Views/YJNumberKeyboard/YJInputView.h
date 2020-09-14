//
//  YJInputView.h
//  JamKit
//
//  Created by 张文洁 on 2020/9/11.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YJInputView;

NS_ASSUME_NONNULL_BEGIN

// 点击的代理事件 传递到外层
@protocol YJInputViewDelegate <NSObject>
// 每次输入的代理事件
-(void)inputViewDidChangeText:(YJInputView *)inputView;

@end

@interface YJInputView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) NSMutableString *placeholderText;
@property (nonatomic, strong) NSString *textTag;
@property (nonatomic, weak) id<YJInputViewDelegate> InputViewDelegate;

/**
 *  带字母 字符 数字切换工具条
 */
+(YJInputView *)shareKBInputViewWithTypeAll;
/**
 *  数字
 */
+(YJInputView *)shareKBInputViewWithTypeNum;
/**
 *  数字+小数点
 */
+(YJInputView *)shareKBInputViewWithTypePassword;
/**
 *  字母+符号
 */
+(YJInputView *)shareKBInputViewWithTypeLetter;

// 显示
-(void)show;

@end

NS_ASSUME_NONNULL_END
