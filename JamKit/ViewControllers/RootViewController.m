//
//  RootViewController.m
//  YinYin
//
//  Created by Jason on 16/1/9.
//  Copyright © 2016年 China Industrial Bank. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
