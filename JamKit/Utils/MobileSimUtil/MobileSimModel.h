//
//  MobileSimModel.h
//  YinYin
//
//  Created by chenliang on 2017/6/5.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileSimModel : NSObject

@property (strong, nonatomic) NSString *carrierName;
@property (strong, nonatomic) NSString *mobileCountryCode;
@property (strong, nonatomic) NSString *mobileNetworkCode;
@property (strong, nonatomic) NSString *isoCountryCode;
@property (assign, nonatomic) BOOL allowsVOIP;

@property (strong, nonatomic) NSString *fullDeviceNumber;

@property (strong, nonatomic) NSString *deviceLanguage;

@property (strong, nonatomic) NSString *deviceName;

@end
