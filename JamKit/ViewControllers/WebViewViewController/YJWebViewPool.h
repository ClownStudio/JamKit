//
//  YJWebViewPool.h
//  YinYin
//
//  Created by Jam Zhang on 2020/3/28.
//  Copyright © 2020 China Industrial Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJWebViewPool : NSObject

+ (WKProcessPool *)sharedPoolManager;

@end

NS_ASSUME_NONNULL_END
