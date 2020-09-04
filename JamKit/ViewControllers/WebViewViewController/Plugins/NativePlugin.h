//
//  NativePlugin.h
//  JamKit
//
//  Created by 张文洁 on 2020/8/31.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface NativePlugin : BasicPlugin

//数字键盘
- (void)showNumberKeyboard:(NSMutableArray *)arguments;
- (void)hideNumberKeyboard:(NSMutableArray *)arguments;
- (void)cleanNumberKeyboard:(NSMutableArray *)arguments;

@end

NS_ASSUME_NONNULL_END
