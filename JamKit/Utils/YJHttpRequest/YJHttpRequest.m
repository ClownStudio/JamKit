//
//  YJHttpRequest.m
//  YJKit
//
//  Created by 张文洁 on 2017/8/17.
//  Copyright © 2017年 张文洁. All rights reserved.
//

#import "YJHttpRequest.h"
#import "AFNetworking.h"
#import "YJJsonKit.h"
#import "Constant.h"
#import "UserAgentUtil.h"

@implementation YJHttpRequest{
    NSString *_userAgent;
}

//单例
+ (id)sharedInstance
{
    static YJHttpRequest *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)getJsonWithUrl:(NSString *)url andBlock:(void(^)(id result))block{
    [self getDataWithUrl:url andBlock:^(id result) {
        if (result == nil) {
            if (block)block(nil);
        }else{
            NSError *error = nil;
            NSObject *resultObject = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&error];
            if (error != nil) {
                if (block)block(nil);
            } else {
                if (block)block(resultObject);
            }
        }
    }];
}

- (void)getRequestDataWithUrl:(NSString *)url andBlock:(void (^)(id result))block andParameters:(id)parameters andCache:(NSURLRequestCachePolicy)cache{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = TIME_OUT_SECONDS;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setValue:[[UserAgentUtil sharedInstance] getUserAgent] forHTTPHeaderField:USER_AGENT];
    if(cache){
        [manager.requestSerializer setCachePolicy:cache];
    }
#if defined(DEV_VERSION)
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
#endif
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (block) block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (block) block(nil);
    }];
}

- (void)getDataWithUrl:(NSString *)url andBlock:(void (^)(id result))block{
    [self getRequestDataWithUrl:url andBlock:block andParameters:nil andCache:NSURLRequestUseProtocolCachePolicy];
}

- (void)getDataWithUrl:(NSString *)url cache:(NSURLRequestCachePolicy)cache andBlock:(void (^)(id result))block{
    [self getRequestDataWithUrl:url andBlock:block andParameters:nil andCache:cache];
}

- (void)postJsonWithUrl:(NSString *)url andRequestContents:(NSDictionary *)contents andBlock:(void(^)(id result))block{
    [self postDataWithUrl:url andRequestContents:contents andBlock:^(id result) {
        if (result == nil) {
            if (block)block(nil);
        }else{
            if (block)block([[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] objectFromJSONString]);
        }
    }];
}

- (void)postDataWithUrl:(NSString *)url andRequestContents:(NSDictionary *)contents andBlock:(void(^)(id result))block{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = TIME_OUT_SECONDS;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager.requestSerializer setValue:[[UserAgentUtil sharedInstance] getUserAgent] forHTTPHeaderField:USER_AGENT];
    
#if defined(DEV_VERSION)
    NSLog(@"UnSafePost");
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
#endif
    
    [manager POST:url parameters:contents progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (block) block(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (block) block(nil);
    }];
}

@end
