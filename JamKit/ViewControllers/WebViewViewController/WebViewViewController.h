//
//  WebViewViewController.h
//  JamKit
//
//  Created by 张文洁 on 2020/8/28.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackNavigationBar.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebViewViewController : UIViewController <BackNavigationBarDelegate,UIScrollViewDelegate,UIActionSheetDelegate,WKNavigationDelegate,WKUIDelegate>

@property (nonatomic,strong)BackNavigationBar *navigationBar;
@property (nonatomic,strong)WKWebView *webView;

-(id)initWithUrl:(NSURL *)url;
-(id)initWithUrl:(NSURL *)url isTop:(BOOL)isTop;
-(id)initWithUrl:(NSURL *)url title:(NSString *)title;
-(id)initWithUrl:(NSURL *)url isTop:(BOOL)isTop title:(NSString *)title;
-(void)refreshWebViewWithUrl:(NSURL *)url;

-(void)showIndicatorView;
-(void)hideIndicatorView;

@end

NS_ASSUME_NONNULL_END
