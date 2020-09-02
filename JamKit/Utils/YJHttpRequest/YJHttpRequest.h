//
//  YJHttpRequest.h
//  YJKit
//
//  Created by 张文洁 on 2017/8/17.
//  Copyright © 2017年 张文洁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJHttpRequest : NSObject

//单例
+ (id)sharedInstance;

//Get方式获取Json数据
- (void)getJsonWithUrl:(NSString *)url andBlock:(void(^)(id result))block;

//Get方式获取二进制数据
- (void)getDataWithUrl:(NSString *)url andBlock:(void (^)(id result))block;

- (void)getDataWithUrl:(NSString *)url cache:(NSURLRequestCachePolicy)cache andBlock:(void (^)(id result))block;

//Post方式获取Json数据
- (void)postJsonWithUrl:(NSString *)url andRequestContents:(NSDictionary *)contents andBlock:(void(^)(id result))block;

//Post方式获取二进制数据
- (void)postDataWithUrl:(NSString *)url andRequestContents:(NSDictionary *)contents andEphemeral:(BOOL)ephemeral andBlock:(void(^)(id result))block;

//Post方式临时的进程内会话
- (void)ephemeralPostJsonWithUrl:(NSString *)url andRequestContents:(NSDictionary *)contents andBlock:(void(^)(id result))block;

@end
