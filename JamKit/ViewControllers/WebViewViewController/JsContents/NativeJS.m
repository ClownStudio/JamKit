//
//  NativeJS.m
//  YinYin
//
//  Created by lion on 2020/3/19.
//  Copyright © 2020 China Industrial Bank. All rights reserved.
//

#import "NativeJS.h"
#import "NativePlugin.h"
#import <objc/runtime.h>

static NSString *nativeJsString;
@implementation NativeJS

+(NSString *)js{
    if (nativeJsString) {
        return nativeJsString;
    }
    NSArray *classArray = @[[NativePlugin class]];
    NSMutableString *js = [NSMutableString stringWithString:@"if(!window.plugins){window.plugins={};}"];
    if (classArray) {
        for (Class class in classArray) {
            NSString *classString = NSStringFromClass(class);
            NSString *definition = [NSString stringWithFormat:@"function %@(){};",class];
            [js appendString:definition];
            NSArray *methods = [self getAllMethods:class];
            if (methods) {
                for (NSString *methodString in methods) {
                    NSString *m = [NSString stringWithFormat:@"%@.prototype.%@=function(successCallback, failureCallback,params){js2native.exec(successCallback,failureCallback, \"%@\", \"%@\",[params]);};",classString,methodString,classString,methodString];
                    [js appendString:m];
                }
            }
            [js appendString:[NSString stringWithFormat:@"window.plugins.%@=new %@();",[self firstLowercase:classString],classString]];
        }
    }
    NSLog(@"NativePlugin js = %@",js);
    nativeJsString = js;
    return js;
}

/* 获取对象的所有方法 */
+(NSArray *)getAllMethods:(Class)class{
    unsigned int count = 0;
    Method* methodList = class_copyMethodList(class,&count);
    NSMutableArray *methodsArray = [NSMutableArray array];
    for (unsigned int i = 0; i<count; i++) {
        Method method = methodList[i];
        NSString *methodString = NSStringFromSelector(method_getName(method));
        
        //filter method name
        if(methodString && [methodString hasSuffix:@":"] && [self isEnglishFirst:methodString]){
            [methodsArray addObject:[methodString substringToIndex:methodString.length-1]];
        }
    }
    return methodsArray;
}

+(BOOL)isEnglishFirst:(NSString *)str {
    NSString *regular = @"^[A-Za-z].+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    if ([predicate evaluateWithObject:str] == YES){
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)firstLowercase:(NSString *)word{
    if(word && word.length>1){
        return [NSString stringWithFormat:@"%@%@",[[word lowercaseString]substringToIndex:1],[word substringFromIndex:1]];
    }
    return word;
}


@end
