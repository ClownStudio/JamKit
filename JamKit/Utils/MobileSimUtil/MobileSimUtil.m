//
//  MobileSimUtil.m
//  YinYin
//
//  Created by chenliang on 2017/6/5.
//  Copyright © 2017年 China Industrial Bank. All rights reserved.
//

#import "MobileSimUtil.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <AdSupport/AdSupport.h>
#import "Constant.h"

#import <sys/utsname.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <mach/mach.h>
#import <assert.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#include <mach-o/arch.h>
#import "UserAgentUtil.h"
#import "UIDevice+IdentifierAddition.h"

@implementation MobileSimUtil

#pragma mark - init
//单例
static MobileSimUtil *instance = nil;
+ (id)sharedInstance{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

//信息可变，所以不写在init中
-(MobileSimModel *)getMobileSimModel{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    MobileSimModel *mobileSimModel = [[MobileSimModel alloc]init];
    mobileSimModel.carrierName = safeString(carrier.carrierName);
    mobileSimModel.mobileCountryCode = safeString(carrier.mobileCountryCode);
    mobileSimModel.mobileNetworkCode = safeString(carrier.mobileNetworkCode);
    mobileSimModel.isoCountryCode = safeString(carrier.isoCountryCode);
    mobileSimModel.allowsVOIP = carrier.allowsVOIP;
    
    NSArray *arr = [NSLocale preferredLanguages];
    if (arr && arr.count > 0) {
        mobileSimModel.deviceLanguage = safeString([[NSLocale preferredLanguages]objectAtIndex:0]);
    }else{
        mobileSimModel.deviceLanguage = @"";
    }
    mobileSimModel.deviceName = [self getDeviceName];
    
    return mobileSimModel;
}

//设备类型：1.android 2.ios 3.pc
-(NSString *)deviceType{
    return @"2";
}

/**
 钱大消金合作客户端信息
 {
 adId = "FE2BA513-9D18-47D4-8E1E-422CFB363EA0";  广告追踪ID
 cpu = "";  CPU类型
 deviceType = 2;  设备类型：1.android 2.ios 3.pc
 freeStorage = "";  可用容量
 imei = "";  国际移动设备身份码IMEI
 imsi = 46011;  国际移动用户身份码IMSI
 mac = "02:00:00:00:00:00";  MAC地址
 manufacturer = "";  制造厂商
 memeory = "0.95";  内存
 model = "iPhone 6 Plus";  型号
 size = "1242 x 2208";  屏幕大小
 storage = "";  磁盘容量
 udid = "2D016329-02C3-430B-B5A5-7383D814D58F";  手机序列号UDID
 udif = "";  设备唯一编码UDIF
 userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_2_2 like Mac OS X) AppleWebKit/604.4.7 (KHTML, like Gecko) Mobile/15C202";  浏览器标识
 uuid = "7C5A181D-A062-4284-868E-B11E62614EFE";  手机UUID
 version = "4.1.0";  钱大掌柜版本号
 }
 @return 客户端信息
 */
-(NSDictionary *)localInfo{
    NSString *udif = [[[UIDevice currentDevice]identifierForVendor]UUIDString];//设备唯一编码UDIF
    NSString *deviceType =  [self deviceType];//设备类型：1.android 2.ios 3.pc
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];//钱大版本号
    NSString *imei = @"";//国际移动设备身份码IMEI,无法获取
    NSString *imsi = [self getIMSI];//国际移动用户身份码IMSI
    
    NSString *adId = [[[ASIdentifierManager sharedManager]advertisingIdentifier]UUIDString];//广告追踪ID IDFA
    NSString *uuid = [NSUUID UUID].UUIDString;//手机UUID
    NSString *udid = [[[UIDevice currentDevice]identifierForVendor]UUIDString];//手机序列号UDID
    NSString *manufacturer = @"";//制造厂商
    NSString *model = [self getDeviceName];//型号    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize rectSize = rect.size;
    CGFloat width = rectSize.width;
    CGFloat height = rectSize.height;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    NSString *size = [NSString stringWithFormat:@"%.0f x %.0f",width*scale_screen,height*scale_screen];//屏幕大小
    
    NSString *cpu = [NSString stringWithFormat:@"%@",[self cpu_usage]];//CPU
    NSString *memeory = [self getTotalMemoryBytes];//内存
    NSDictionary *deviceSize = [self getDeviceSize];
    NSString *storage = [deviceSize objectForKey:@"maxspace"]; //磁盘容量
    NSString *freeStorage = [deviceSize objectForKey:@"freespace"]; //可用容量
    NSString *mac = [[UIDevice currentDevice]macaddress];
    
    NSDictionary *dictionary = @{@"udif":udif,@"deviceType":deviceType,@"version":version,@"imei":imei,@"imsi":imsi,@"adId":adId,@"uuid":uuid,@"udid":udid,@"manufacturer":manufacturer,@"model":model,@"size":size,@"cpu":cpu,@"memeory":memeory,@"storage":storage,@"freeStorage":freeStorage,@"mac":mac,@"userAgent":[[UserAgentUtil sharedInstance] getUserAgent]};
    
    return dictionary;
}
-(NSString *)getIMSI{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    return imsi;
}

-(NSDictionary *)getDeviceSize{
    NSDictionary *systemAttributes = [[NSFileManager defaultManager]attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSString *freespace = @"";
    NSString *maxspace = @"";
    if (systemAttributes) {
        NSString *diskTotalSize = [systemAttributes objectForKey:@"NSFileSystemSize"];
        maxspace = [NSString stringWithFormat:@"%.2fG",[diskTotalSize floatValue]/1024.0/1024.0/1024.0];
        
        NSString *diskFreeSize = [systemAttributes objectForKey:@"NSFileSystemFreeSize"];
        freespace = [NSString stringWithFormat:@"%.2fG",[diskFreeSize floatValue]/1024.0/1024.0/1024.0];
    }
    return @{@"freespace":freespace,@"maxspace":maxspace};
}

-(NSString *)getTotalMemoryBytes{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, HW_PHYSMEM};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return [NSString stringWithFormat:@"%.2fG",(NSUInteger) results/1024.0/1024.0/1024.0];
}


-(NSString *)cpu_usage{  // 返回CPU类型
    //    const NXArchInfo *archInfo = NXGetLocalArchInfo();
    //    cpu_type_t ctype = archInfo->cputype;
    
    NSString *cpu = @"";
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    
    kern_return_t ret = host_info(mach_host_self(),HOST_BASIC_INFO,(host_info_t)&hostInfo,&infoCount);
    if (ret == KERN_SUCCESS) {
        //        int ctype = hostInfo.cpu_type;
        //        int subtype = hostInfo.cpu_subtype;
        switch (hostInfo.cpu_type) {
            case CPU_TYPE_ARM:
                cpu = @"CPU_TYPE_ARM";
                break;
                
            case CPU_TYPE_ARM64:
                cpu = @"CPU_TYPE_ARM64";
                break;
                
            case CPU_TYPE_X86:
                cpu = @"CPU_TYPE_X86";
                break;
                
            case CPU_TYPE_X86_64:
                cpu = @"CPU_TYPE_X86_64";
                break;
            default:
                break;
        }
    }
    
    return cpu;
}

#pragma mark - is iphone
-(BOOL)iPhoneXSeries{
    if ([[UIDevice currentDevice]userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        return NO;
    }
    if (@available(iOS 11.0,*)) {
        if ([UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom > 0.0) {
            return YES;
        }
    }
    return NO;
}

-(int)iphoneDeviceNumber{
    NSString *deviceString = [self deviceString];
    if (deviceString && ![@""isEqualToString:deviceString] && [deviceString hasPrefix:@"iPhone"]) {
        deviceString = [deviceString stringByReplacingOccurrencesOfString:@"," withString:@""];
        deviceString = [deviceString stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        return [deviceString intValue];
    }
    return -1;
}

-(NSString *)deviceString{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}
-(NSString *)getDeviceName{
    NSString *deviceString = [self deviceString];
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";

    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}
@end
