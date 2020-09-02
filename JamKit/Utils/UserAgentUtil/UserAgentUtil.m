//
//  UserAgentUtil.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/28.
//  Copyright © 2020年 张文洁. All rights reserved.
//

#import "UserAgentUtil.h"
#import <UIKit/UIKit.h>
#import "Constant.h"
#import <WebKit/WebKit.h>
#import "UIDevice+IdentifierAddition.h"
#import "MobileSimUtil.h"

@implementation UserAgentUtil{
    NSString *_localUserAgent;
}

+(UserAgentUtil *)sharedInstance{
    static UserAgentUtil *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id)init{
    if(self = [super init]){
        _localUserAgent = @"";
    }
    return self;
}

-(void)createUserAgent{
    if([@""isEqualToString:_localUserAgent]){
        NSString *originalUserAgent = @"";
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        SEL privateUASel = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@%@%@",@"_",@"user",@"Agent"]);
        if ([webView respondsToSelector:privateUASel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            originalUserAgent = [webView performSelector:privateUASel];
#pragma clang diagnostic pop
        }
        
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        MobileSimModel *model =  [[MobileSimUtil sharedInstance] getMobileSimModel];
        NSString *deviceAgent = [NSMutableString stringWithString:[NSString stringWithFormat:@"cibbank/yyptclient/%@/iphone/%@/%@/devicename/%@",[[UIDevice currentDevice]uniqueDeviceIdentifier],version,APP_ACCESS_KEY,model.deviceName]];
        
        _localUserAgent = [NSString stringWithFormat:@"%@ %@",originalUserAgent,deviceAgent];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:_localUserAgent, @"UserAgent",nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *) getUserAgent{
    if([@""isEqualToString:_localUserAgent]){
        [self createUserAgent];
    }
    return _localUserAgent;
}

@end
