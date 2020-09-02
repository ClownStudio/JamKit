//
//  UserAgentUtil.h
//  JamKit
//
//  Created by 张文洁 on 2020/8/28.
//  Copyright © 2020年 张文洁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAgentUtil : NSObject

+ (UserAgentUtil *) sharedInstance;

- (NSString *) getUserAgent;


@end
