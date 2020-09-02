//
//  BaseViewController.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/31.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "BaseViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self setFd_interactivePopMaxAllowedInitialDistanceToLeftEdge:20];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
