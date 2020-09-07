//
//  BackNavigationBar.m
//  YinYin
//
//  Created by Jason on 15/5/20.
//  Copyright (c) 2015年 China Industrial Bank. All rights reserved.
//

#import "BackNavigationBar.h"
#import "Constant.h"

@implementation BackNavigationBar{
    UIView *_backBtn;
    UIView *_closeBtn;
    UILabel *_title;
    UIButton *_goBack;
}

-(id)init{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, WIDTH, NAVIGATIONBAR_HEIGHT)];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, self.bounds.size.width - 180, NAVIGATIONBAR_HEIGHT)];
        [_title setNumberOfLines:1];
        [_title setCenter:self.center];
        [_title setBackgroundColor:[UIColor clearColor]];
        [_title setFont:[UIFont boldSystemFontOfSize:20.0]];
        [_title setTextColor:[UIColor blackColor]];
        [_title setTextAlignment:NSTextAlignmentCenter];
        [_title setAdjustsFontSizeToFitWidth:NO];
        [self addSubview:_title];
    }
    return self;
}

-(void)customizeBackButton{
    _backBtn = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, NAVIGATIONBAR_HEIGHT)];
    _backBtn.backgroundColor = [UIColor clearColor];
    _backBtn.userInteractionEnabled = YES;
    [_backBtn addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onBack:)]];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(15, (NAVIGATIONBAR_HEIGHT - 24)/2, 24, 24)];
    [back setBackgroundColor:[UIColor clearColor]];
    [back setImage:[UIImage imageNamed:@"nav_arrow_black"] forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"nav_arrow_black"] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn addSubview:back];
    _goBack = back;
    [self addSubview:_backBtn];
}

-(void)reLayoutWithBlankHeight:(CGFloat)blankHeight{
    [self setFrame:CGRectMake(0, 0, WIDTH, NAVIGATIONBAR_HEIGHT + blankHeight)];
    if (_title) {
        CGRect temp = _title.frame;
        temp.origin.x = (WIDTH - temp.size.width)/2;
        temp.origin.y = blankHeight + ((self.frame.size.height - blankHeight) - temp.size.height)/2;
        _title.frame = temp;
    }
    if (_backBtn) {
        CGRect temp = _backBtn.frame;
        temp.origin.y = blankHeight + ((self.frame.size.height - blankHeight) - temp.size.height)/2;
        _backBtn.frame = temp;
    }
    if (_closeBtn) {
        CGRect temp = _closeBtn.frame;
        temp.origin.y = blankHeight + ((self.frame.size.height - blankHeight) - temp.size.height)/2;
        _closeBtn.frame = temp;
    }
    [self setNeedsLayout];
}

-(void)setNotUseBackscreen{
    if (_backBtn) {
        [_backBtn removeFromSuperview];
        _backBtn = nil;
    }
}

-(void)done{
    if(_closeBtn){
        id tempDelegate = self.delegate;
        if (tempDelegate && [tempDelegate respondsToSelector:@selector(onDoneScreen)]) {
            [self.delegate onDoneScreen];
        }
    }
}

-(void)onBack:(id)sender{
    if (_backBtn) {
        id tempDelegate = self.delegate;
        if (tempDelegate && [tempDelegate respondsToSelector:@selector(onBackScreen)]) {
            [self.delegate onBackScreen];
        }
    }
}

/**
 *  设置返回按钮图片
 *
 *  @param backImage 返回图片
 */
-(void)setBackButtonImage:(UIImage *)backImage{
    if (_goBack) {
        [_goBack setImage:backImage forState:UIControlStateNormal];
        [_goBack setImage:backImage forState:UIControlStateHighlighted];
    }
}

/**
 *  设置标题
 *
 *  @param title 标题内容
 */
-(void)setTitle:(NSString *)title{
    if (_title) {
        [_title setText:title];
    }
}

/**
 *  设置标题
 *
 *  @param color 标题颜色
*/
-(void)setNavTitleColor:(UIColor *)color {
    if (_title) {
        [_title setTextColor:color];
    }
}

/**
 *  设置标题
 *
 *  @param isShow 标题是否隐藏 yes显示。 no隐藏
*/
-(void)setNavTitleShowOrHide:(BOOL)isShow {
    if (_title) {
        if (isShow) {
            _title.hidden = NO;
        } else {
            _title.hidden = YES;
        }
    }
}

@end
