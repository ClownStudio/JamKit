//
//  NativePlugin.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/31.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "NativePlugin.h"
#import "KRKeyboard.h"
#import "Constant.h"

@interface NativePlugin() <KRKeyboardDelegate>

@end

@implementation NativePlugin{
    KRKeyboard *_keyboard;
}

- (void)showNumberKeyboard:(NSMutableArray *)arguments{
    NSLog(@"88888");
    _keyboard = [KRKeyboard creatWithKeyboardType:SymbolKeyboard delegateTarget:self];
    CGRect temp = _keyboard.frame;
//    temp.origin.y = HEIGHT - temp.size.height;
    _keyboard.frame = temp;
    [self.keyWindow addSubview:_keyboard];
}

- (void)hideNumberKeyboard:(NSMutableArray *)arguments{
    
}

- (void)cleanNumberKeyboard:(NSMutableArray *)arguments{
    
}

/**
 按键回调

 @param key 单击的文本
 @param keyType 单击的文本类型
 @param keyboardType 键盘类型
 @param content 已输入的内容
 */
- (void)pressKey:(NSString *)key keyType:(KRKeyType)keyType keyboardType:(KRKeyboardType)keyboardType content:(NSString *)content{
    
}

@end
