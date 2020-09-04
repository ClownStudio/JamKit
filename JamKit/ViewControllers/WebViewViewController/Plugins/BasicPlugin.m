//
//  BasicPlugin.m
//
//  Created by chenliang on 2015-06-09
//

#import "BasicPlugin.h"
#import "YJJsonKit.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation BasicPlugin

- (id)init
{
    self = [super init];
    if (self) {
        _keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    return self;
}

typedef enum{
    CallBackTypeSuccess = 0,
    CallBackTypeFail = 1
}CallBackType;

-(void)compatibleCallback:(NSString *)callbackId type:(CallBackType)type param:(id)param{
    NSString *execJS = @"";
    NSString *suffix = @"SuccessEvent";
    if (type == CallBackTypeFail) {
        suffix = @"FailEvent";
    }
    if (param) {
        NSString *result = @"";
        //三种格式参数：string,dictionary,array
        if ([param isKindOfClass:[NSString class]]) {
            result = [NSString stringWithFormat:@"'%@'",param];
        }else if([param isKindOfClass:[NSDictionary class]]){
            result = safeString([param objectToJSONString]);
        }else if([param isKindOfClass:[NSArray class]]){
            result = @"[]";
            NSArray *arr =(NSArray *)param;
            if (arr != nil && arr.count > 0) {
                result = [arr objectToJSONString];
            }
        }
        
        if ([callbackId hasPrefix:@"cid_"]) {//新方式
            NSString *key = [NSString stringWithFormat:@"%@%@",callbackId,suffix];
            execJS = [NSString stringWithFormat:@"app_plugin_execute_callback('%@',%@)",key,result];
        }else{//需要兼容旧方式
            execJS = [NSString stringWithFormat:@"%@%@(%@)",callbackId,suffix,result];
        }
    }else{
        if ([callbackId hasPrefix:@"cid_"]) {
            NSString *key = [NSString stringWithFormat:@"%@%@",callbackId,suffix];
            execJS = [NSString stringWithFormat:@"app_plugin_execute_callback('%@')",key];
        }else{
            execJS = [NSString stringWithFormat:@"%@%@()",callbackId,suffix];
        }
    }
    NSLog(@"execJS = %@",execJS);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_webView)[self->_webView stringByEvaluatingJavaScriptFromString:execJS];
    });
    
}
/**
 *  执行成功回调函数
 *
 *  @param callBackId 回调函数名
 */
-(void)toSuccessWithCallbackId:(NSString *)callBackId{
    [self compatibleCallback:callBackId type:CallBackTypeSuccess param:nil];
}

/**
 *  执行失败回调函数
 *
 *  @param callBackId 回调函数名
 */
-(void)toFailWithCallbackId:(NSString *)callBackId{
    [self compatibleCallback:callBackId type:CallBackTypeFail param:nil];
}

/**
 *  执行成功回调函数
 *
 *  @param callBackId 回调函数名
 *  @param msg        回调消息
 */
-(void)toSuccessCallback:(NSString *)callBackId messageAsString:(NSString *)msg{
    [self compatibleCallback:callBackId type:CallBackTypeSuccess param:msg];
}

/**
*  执行失败回调函数
*
*  @param callBackId 回调函数名
*  @param msg        回调消息
*/
-(void)toFailCallback:(NSString *)callBackId messageAsString:(NSString *)msg{
    [self compatibleCallback:callBackId type:CallBackTypeFail param:msg];
}

/**
 *  执行成功回调函数
 *
 *  @param callBackId 回调函数名
 *  @param arr        回调消息数组
 */
-(void)toSuccessCallback:(NSString *)callBackId messageAsArray:(NSArray *)arr{
    [self compatibleCallback:callBackId type:CallBackTypeSuccess param:arr];
}

/**
 *  执行成功回调函数
 *
 *  @param callBackId 回调函数名
 *  @param dict       回调消息字典
 */
-(void)toSuccessCallback:(NSString *)callBackId messageAsDictionary:(NSDictionary *)dict{
    [self compatibleCallback:callBackId type:CallBackTypeSuccess param:dict];
}

-(void)toSuccessCallbackMessageAsString:(NSString *)msg{
    [self compatibleCallback:self.callbackId type:CallBackTypeSuccess param:msg];
}

-(void)toFailCallbackMessageAsString:(NSString *)msg{
    [self compatibleCallback:self.callbackId type:CallBackTypeFail param:msg];
}

-(void)toFailCallbackAsMessageAsDictionary:(NSDictionary *)dict{
    [self compatibleCallback:self.callbackId type:CallBackTypeFail param:dict];
}


-(void)toSuccessCallbackMessageAsArray:(NSArray *)arr{
    [self compatibleCallback:self.callbackId type:CallBackTypeSuccess param:arr];
}

-(void)toSuccessCallbackMessageAsDictionary:(NSDictionary *)dict{
    [self compatibleCallback:self.callbackId type:CallBackTypeSuccess param:dict];
}

@end
