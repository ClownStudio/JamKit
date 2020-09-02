//
//  PluginUtils.m
//  YinYin
//
//  Created by chenliang on 15/11/10.
//  Copyright © 2015年 China Industrial Bank. All rights reserved.
//

#import "PluginUtils.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Stuff; \
        _Pragma("clang diagnostic pop") \
    } while (0)

@implementation PluginUtils{
    NSMutableArray *_targets;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _targets = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

-(void)executePluginByUrl:(NSString *)url webView:(WKWebView *)wv webViewController:(UIViewController *)webViewController{
    //兼容http版本
    NSRange range = [url rangeOfString:CALLFUNCTION_PREFIX_HTTPS];
    NSString *temp = [url substringFromIndex:range.location + range.length];
    NSArray *arr = [temp componentsSeparatedByString:@"&"];
    
    NSString *callBackId = @"";
    NSString *className = @"";
    NSString *methodName = @"";
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:0];
    
    if(arr != nil && arr.count > 0){
        NSString *tt = [arr objectAtIndex:0];
        NSArray *tempArr = [tt componentsSeparatedByString:@"="];
        callBackId = [tempArr objectAtIndex:1];
        
        tt = [arr objectAtIndex:1];
        tempArr = [tt componentsSeparatedByString:@"="];
        className = [tempArr objectAtIndex:1];
        
        tt = [arr objectAtIndex:2];
        tempArr = [tt componentsSeparatedByString:@"="];
        methodName = [tempArr objectAtIndex:1];
        
        tt = [arr objectAtIndex:3];
        tempArr = [tt componentsSeparatedByString:@"="];
        NSString *paramStr = [tempArr objectAtIndex:1];
        paramStr = [paramStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if(paramStr != nil && paramStr.length > 0){
            params = [NSMutableArray arrayWithArray:[paramStr componentsSeparatedByString:@"$"]];
        }
        
        //反射调用有参方法
        NSMutableArray *pp = [NSMutableArray arrayWithCapacity:0];
        for(NSString *t in params){
            NSString *pt = [self filterArgument:t];
            if(pt != nil){
                [pp addObject:pt];
            }
        }
        NSLog(@"className = %@ methodName = %@",className,methodName);
        
        id target;
        if (_targets) {
            for (id targetTemp in _targets) {
                if ([safeString(className) isEqualToString:NSStringFromClass([targetTemp class])]) {
                    target = targetTemp;
                    break;
                }
            }
        }else{
             _targets = [NSMutableArray arrayWithCapacity:0];
        }
        
        if (target == nil) {
            Class cls = NSClassFromString(className);
            target = [[cls alloc] init];
            [_targets addObject:target];
        }
        
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@",methodName,@":"]);
        if([target respondsToSelector:selector]){
            @try {
                SEL sel1 = NSSelectorFromString(@"setCallbackId:");
                if ([target respondsToSelector:sel1]) {
                    SuppressPerformSelectorLeakWarning([target performSelector:sel1 withObject:callBackId]);
                }
                
                SEL sel2 = NSSelectorFromString(@"setWebView:");
                if ([target respondsToSelector:sel2]) {
                    SuppressPerformSelectorLeakWarning([target performSelector:sel2 withObject:wv]);
                }
                
                SEL sel3 = NSSelectorFromString(@"setWebViewController:");
                if ([target respondsToSelector:sel3]) {
                    SuppressPerformSelectorLeakWarning([target performSelector:sel3 withObject:webViewController]);
                }
            }@catch (NSException *exception) {
                NSLog(@"exception: %@",exception);
                NSLog(@"PluginUtils: class:%@ method:%@ execute error...",className,methodName);
            }
            //使用 performSelector withObject 是为了防止出现set方法无法立即生效的问题
            SuppressPerformSelectorLeakWarning([target performSelector:selector withObject:pp]);
            
        }
    }
}

#pragma mark -
-(NSString *)filterArgument:(NSString *)argument{
    if([argument isEqual:[NSNull null]] ||
       argument == nil ||
       [@"undefined"isEqualToString:argument]){
        return nil;
    }else{
        return argument;
    }
}

-(void)clearTargets{
    NSLog(@"clearTargets...");
    if (_targets) {
        while ([_targets count] > 0) {
            id target = [_targets firstObject];
            target = nil;
            [_targets removeObjectAtIndex:0];
        }
        _targets = nil;
    }
}

@end
