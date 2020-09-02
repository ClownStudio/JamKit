//
//  YJWebViewPool.m
//  YinYin
//
//  Created by Jam Zhang on 2020/3/28.
//  Copyright © 2020 China Industrial Bank. All rights reserved.
//

#import "YJWebViewPool.h"

static WKProcessPool *sharedManager = nil;

@implementation YJWebViewPool

+ (id)sharedPoolManager{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[WKProcessPool alloc] init];
    });
    return sharedManager;
}

@end
