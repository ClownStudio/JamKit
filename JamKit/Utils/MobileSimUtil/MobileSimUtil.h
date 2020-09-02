//
//  MobileSimUtil.h
//  YinYin
//
//  Created by chenliang on 2017/6/5.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileSimModel.h"


@interface MobileSimUtil : NSObject

+ (id)sharedInstance;

-(MobileSimModel *)getMobileSimModel;

-(NSDictionary *)localInfo;

-(BOOL)iPhoneXSeries;
-(NSString *)deviceString;

@end
