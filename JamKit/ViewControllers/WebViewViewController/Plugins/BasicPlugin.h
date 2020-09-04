//
//  BasicPlugin.h
//
//  Created by chenliang on 2015-06-09
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSMutableArray+QueueAdditions.h"

@interface BasicPlugin : NSObject

@property(nonatomic,weak)UIViewController *webViewController;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)NSString *callbackId;
@property(nonatomic,strong)UIWindow *keyWindow;

-(void)toSuccessWithCallbackId:(NSString *)callBackId;

-(void)toFailWithCallbackId:(NSString *)callBackId;

-(void)toSuccessCallbackMessageAsString:(NSString *)msg;

-(void)toFailCallbackMessageAsString:(NSString *)msg;

-(void)toFailCallbackAsMessageAsDictionary:(NSDictionary *)dict;

-(void)toSuccessCallbackMessageAsArray:(NSArray *)arr;

-(void)toSuccessCallbackMessageAsDictionary:(NSDictionary *)dict;

-(void)toSuccessCallback:(NSString *)callBackId messageAsDictionary:(NSDictionary *)dict;

@end
