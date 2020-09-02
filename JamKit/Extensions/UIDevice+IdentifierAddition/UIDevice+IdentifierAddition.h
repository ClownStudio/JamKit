//
//  UIDevice(IdentifierAddition).h
//
//  Created by chenliang
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIDevice (IdentifierAddition)

-(NSString *) uniqueDeviceIdentifier;

-(NSString *)getIDFV;

- (NSString *) macaddress;

@end
