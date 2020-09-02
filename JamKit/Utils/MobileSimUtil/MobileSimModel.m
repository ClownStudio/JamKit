//
//  MobileSimModel.m
//  YinYin
//
//  Created by chenliang on 2017/6/5.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import "MobileSimModel.h"

@implementation MobileSimModel

- (NSString *)description{
    return [NSString stringWithFormat:@"MobileSimModel propertys is : carrierName=%@,mobileCountryCode=%@,mobileNetworkCode=%@,isoCountryCode=%@,allowsVOIP=%d,fullDeviceNumber=%@,deviceLanguage=%@,deviceName=%@",_carrierName,_mobileCountryCode,_mobileNetworkCode,_isoCountryCode,_allowsVOIP,_fullDeviceNumber,_deviceLanguage,_deviceName];
}

@end
