//
//  BackNavigationBar.h
//  YinYin
//
//  Created by Jason on 15/5/20.
//  Copyright (c) 2015年 China Industrial Bank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackNavigationBarDelegate

@optional
-(void)onBackScreen;
-(void)onBackScreen:(void (^)(void))block;
-(void)onDoneScreen;
@end

@interface BackNavigationBar : UIView

-(void)setBackButtonImage:(UIImage *)backImage;
-(void)setTitle:(NSString *)title;
-(void)setNavTitleColor:(UIColor *)color;
-(void)setNavTitleShowOrHide:(BOOL)isShow;
-(void)customizeBackButton;
-(void)setNotUseBackscreen;
-(void)reLayoutWithBlankHeight:(CGFloat)blankHeight;

@property(nonatomic,strong)UIView *line;
@property(assign,nonatomic) id <BackNavigationBarDelegate> delegate;

@end
