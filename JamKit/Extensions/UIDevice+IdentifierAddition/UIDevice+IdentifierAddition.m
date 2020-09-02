//
//  UIDevice(IdentifierAddition).m
//
//  Created by chenliang
//

#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5.h"
#import "Constant.h"


#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

static NSString *udidCache = @"";

@implementation UIDevice (IdentifierAddition)

#pragma mark - uniqueDeviceIdentifier
- (NSString *)uniqueDeviceIdentifier{
    if(![@""isEqualToString:udidCache]){
        return udidCache;
    }
    NSString *udid = @"";
    @try {
        udid = safeString([self getUUID]);
    }
    @catch (NSException *exception) {
        NSLog(@"uniqueDeviceIdentifier exception = %@",exception);
    }
    
    udidCache = udid;
    return udidCache;
}


#pragma mark - private methods
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

-(NSString *)getIdentifierForVendor{
    NSString *identifierForVendor = [NSString stringWithFormat:@"%@",[[[UIDevice currentDevice]identifierForVendor]UUIDString]];
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",identifierForVendor,DEVICE_TOKEN_PASS];
    return [NSString md5:stringToHash];
}

-(NSString *)getIDFV{
    return safeString([[[UIDevice currentDevice]identifierForVendor]UUIDString]);
}


#pragma mark - key chain
-(NSString *)getUUID{
    NSString * const KEY_GESTURELOCKERPLUGIN_TOKEN_VALUE = @"com.cib.yypt.gesturelockerplugin.token.key";
    NSString * const KEY_GESTURELOCKERPLUGIN_TOKEN_DICTIONARY_VALUE = @"com.cib.yypt.gesturelockerplugin.token.dictionary.key";
    
    NSMutableDictionary *readUserPwd = (NSMutableDictionary *)[self load:KEY_GESTURELOCKERPLUGIN_TOKEN_VALUE];
    
    if(readUserPwd == nil || [@""isEqualToString:safeString([readUserPwd objectForKey:KEY_GESTURELOCKERPLUGIN_TOKEN_DICTIONARY_VALUE])]){
        NSString *identifierStr = [self getIdentifierForVendor];
        NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
        [usernamepasswordKVPairs setObject:identifierStr forKey:KEY_GESTURELOCKERPLUGIN_TOKEN_DICTIONARY_VALUE];
        //save
        [self save:KEY_GESTURELOCKERPLUGIN_TOKEN_VALUE data:usernamepasswordKVPairs];

        return identifierStr;
    }else{
        return [readUserPwd objectForKey:KEY_GESTURELOCKERPLUGIN_TOKEN_DICTIONARY_VALUE];
    }
}


#pragma mark - 
-(void)save:(NSString *)service data:(id)data{
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

-(NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService,
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock,(__bridge id)kSecAttrAccessible,
            nil];
}

//取
-(id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}


-(void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}
@end
