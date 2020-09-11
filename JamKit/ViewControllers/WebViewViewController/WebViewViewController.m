//
//  WebViewViewController.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/28.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "WebViewViewController.h"
#import "Constant.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "NotificationName.h"
#import "UserAgentUtil.h"
#import <KKJSBridge.h>
#import "ModuleContext.h"
#import "ModuleNative.h"
#import <AFNetworking.h>

@interface WebViewViewController () <WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong, readwrite) KKWebView *webView;
@property (nonatomic, strong) KKJSBridgeEngine *jsBridgeEngine;

@end

static NSString *_lastPage;//只记录无逻辑

@implementation WebViewViewController{
    UIActivityIndicatorView *_indicatorView;
    NSMutableArray *_targets;
    NSURL *_originUrl;
}

-(id)initWithUrl:(NSURL *)url{
    return [self initWithUrl:url isTop:NO title:@""];
}

-(id)initWithUrl:(NSURL *)url title:(NSString *)title{
    return [self initWithUrl:url isTop:NO title:title];
}

-(id)initWithUrl:(NSURL *)url isTop:(BOOL)isTop{
    return [self initWithUrl:url isTop:isTop title:@""];
}

-(id)initWithUrl:(NSURL *)url isTop:(BOOL)isTop title:(NSString *)title{
    self = [super init];
    if (self) {
        title = safeString(title);
        _originUrl = url;
        [self commonInit];
        [self createWebWithTop:isTop andTitle:title];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pageFlowDestroy) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

+ (void)load {
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self prepareWebView];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}

+ (void)prepareWebView {
    // 预先缓存一个 webView
    [KKWebView configCustomUAWithType:KKWebViewConfigUATypeReplace UAString:[[UserAgentUtil sharedInstance] getUserAgent]];
    [[KKWebViewPool sharedInstance] makeWebViewConfiguration:^(WKWebViewConfiguration * _Nonnull configuration) {
        // 必须前置配置，否则会造成属性不生效的问题
        configuration.allowsInlineMediaPlayback = YES;
        if (@available(iOS 10.0, *)) {
            configuration.mediaTypesRequiringUserActionForPlayback = NO;
        }
    }];
    [[KKWebViewPool sharedInstance] enqueueWebViewWithClass:KKWebView.class];
    KKJSBridgeConfig.ajaxDelegateManager = (id<KKJSBridgeAjaxDelegateManager>)self; // 请求外部代理处理，可以借助 AFN 网络库来发送请求
}

- (void)dealloc {
    [[KKWebViewPool sharedInstance] enqueueWebView:self.webView];
    NSLog(@"WebViewController dealloc");
}

-(void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    if (self.navigationBar) {
        [self.navigationBar reLayoutWithBlankHeight:self.view.safeAreaInsets.top];
        CGRect temp = self.webView.frame;
        temp.origin.y = self.navigationBar.bounds.size.height;
        temp.size.height = HEIGHT - (self.navigationBar.bounds.size.height + (_isTop ? (TABBAR_HEIGHT + self.view.safeAreaInsets.bottom):0));
        self.webView.frame = temp;
    }else{
        CGRect temp = self.webView.frame;
        temp.size.height = HEIGHT - (TABBAR_HEIGHT + self.view.safeAreaInsets.bottom);
        self.webView.frame = temp;
    }
}

-(void)refreshWebViewWithUrl:( NSURL * _Nullable )url{
    if (url == nil) {
        url = _originUrl;
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_SECONDS]];
}

- (void)commonInit{
    _webView = [[KKWebViewPool sharedInstance] dequeueWebViewWithClass:KKWebView.class webViewHolder:self];
    _webView.navigationDelegate = self;
    _jsBridgeEngine = [KKJSBridgeEngine bridgeForWebView:self.webView];
    _jsBridgeEngine.config.enableAjaxHook = NO;
    
    [self compatibleWebViewJavascriptBridge];
    [self registerModule];
}

- (void)compatibleWebViewJavascriptBridge {
    NSError *error;
    NSString *jsString = [[NSString alloc] initWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"WebViewJavascriptBridge" ofType:@"js"] encoding:NSUTF8StringEncoding error:&error];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.webView.configuration.userContentController addUserScript:userScript];
}

- (void)registerModule{
    ModuleContext *context = [ModuleContext new];
    context.viewController = self;
    context.webview = self.webView;
    
    // 注册 默认模块
    [self.jsBridgeEngine.moduleRegister registerModuleClass:ModuleNative.class withContext:context];
}

#pragma mark - KKJSBridgeAjaxDelegateManager
+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request callbackDelegate:(NSObject<KKJSBridgeAjaxDelegate> *)callbackDelegate {
    return [[self ajaxSesstionManager] dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        // 处理响应数据
        [callbackDelegate JSBridgeAjax:callbackDelegate didReceiveResponse:response];
        if ([responseObject isKindOfClass:NSData.class]) {
            [callbackDelegate JSBridgeAjax:callbackDelegate didReceiveData:responseObject];
        } else if ([responseObject isKindOfClass:NSDictionary.class]) {
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
            [callbackDelegate JSBridgeAjax:callbackDelegate didReceiveData:responseData];
        } else {
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            [callbackDelegate JSBridgeAjax:callbackDelegate didReceiveData:responseData];
        }
        [callbackDelegate JSBridgeAjax:callbackDelegate didCompleteWithError:error];
    }];
}

+ (AFHTTPSessionManager *)ajaxSesstionManager {
    static AFHTTPSessionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        instance.requestSerializer = [AFHTTPRequestSerializer serializer];
        instance.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return instance;
}

//isTop：是否是最外层的ViewController
//title：如果title为空且为最外层，默认不初始化导航栏。
-(void)createWebWithTop:(BOOL)isTop andTitle:(NSString *)title{
    _isTop = isTop;
    CGFloat bottomHeight = 0;
    if ([@"" isEqualToString:title] && !isTop) {
        title = @"详情";
    }

    if ([@"" isEqualToString:title] == NO) {
        self.navigationBar = [[BackNavigationBar alloc] init];
        self.navigationBar.delegate = self;
        [self.navigationBar setTitle:title];
    }
    
    if (isTop) {
        bottomHeight = 50;
    }else{
        [self.navigationBar customizeBackButton];
    }
    
    [self.webView setFrame:CGRectMake(0, self.navigationBar.bounds.size.height, WIDTH, HEIGHT - CGRectGetMaxY(self.navigationBar.frame) - bottomHeight)];
    self.webView.scrollView.delegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = false;
    
    if (@available(iOS 11.0, *)) {
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:self.webView.bounds];
    [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.webView addSubview:_indicatorView];
    [self.view addSubview:self.webView];
    
    if (self.navigationBar) {
        [self.view addSubview:self.navigationBar];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [self setFd_interactivePopMaxAllowedInitialDistanceToLeftEdge:60.0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏神州泰岳的系统导航栏
    self.navigationController.navigationBarHidden = YES;
    if (self.webView.scrollView.delegate == nil) {
        self.webView.scrollView.delegate = self;
    }
    
    if (self.webView.navigationDelegate == nil) {
        self.webView.navigationDelegate = self;
    }
    
    if (self.webView.UIDelegate == nil) {
        self.webView.UIDelegate = self;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setFd_interactivePopDisabled:true];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_indicatorView) {
        [_indicatorView stopAnimating];
    }
    if (_webView.scrollView.delegate) {
        _webView.scrollView.delegate = nil;
    }
    if (_webView.navigationDelegate) {
        _webView.navigationDelegate = nil;
    }
    if (_webView.UIDelegate) {
        _webView.UIDelegate = nil;
    }
    
    [self pageFlowDestroy];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if(@available(iOS 13.0, *)){
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return UIStatusBarStyleDarkContent;
        }
    }
    return UIStatusBarStyleDefault;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (challenge.previousFailureCount == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [_indicatorView startAnimating];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [_indicatorView stopAnimating];
    [self pageFlowStart];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"%@ = ",error);//打印错误，否则错误不好定位
    [_indicatorView stopAnimating];
    
    if([error code] == NSURLErrorTimedOut){
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadLocalErrorPage) userInfo:nil repeats:NO];
        return;
    }
    if (error.code == NSURLErrorCancelled) return;
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
    if([error code] != NSURLErrorCancelled){
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadLocalErrorPage) userInfo:nil repeats:NO];
        return;
    }
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
     if ([navigationAction.request.URL.absoluteString containsString:@"https://__bridge_loaded__"]) {// 防止 WebViewJavascriptBridge 注入
         decisionHandler(WKNavigationActionPolicyCancel);
         return;
     }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

/**
 *  加载系统本地自带error.html错误提示页面
 */
-(void)loadLocalErrorPage{
    
}


/**
 *  是否是本地页面
 *
 *  @param url 访问的Url
 *
 *  @return 返回是否为本地页面,YES是，NO不是
 */
-(BOOL)isLocalUrl:(NSString *)url{
    return (![@""isEqualToString:url] && ([url hasPrefix:@"/Users/"] || [url hasPrefix:@"/var/"] || [url hasPrefix:@"file://"] || [url hasPrefix:@"/private/var/"]));
}

/**
 *  根据url加载需要跳转的页面1
 *
 *  @param url url地址
 */
- (void)loadWebViewWithUrl:(NSString *)url{
    url = safeString(url);
    if (self.webView) {
        if(![@""isEqualToString:safeString(url)]){
            if([url hasPrefix:@"App://"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:CALL_OUT_NATIVE_BY_URL object:nil userInfo:[NSDictionary dictionaryWithObjects:@[url,@""] forKeys:@[@"serviceUrl",@"serviceTitle"]]];
            }else if([self isLocalUrl:url]){//本地html
                [self loadWebContent:url];
            }else{
                NSURL *tempURL = [NSURL URLWithString:url];
                if ([@"" isEqualToString:safeString(tempURL)]) {
                    [self loadLocalErrorPage];
                } else {
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:tempURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_SECONDS];
                    [request setValue:[[UserAgentUtil sharedInstance] getUserAgent] forHTTPHeaderField:@"User-Agent"];
                    [self.webView loadRequest:request];
                }
            }
        }else{
            NSLog(@"loadWebViewWithUrl url is null");
        }
    }
}

- (void)loadWebContent:(NSString *)url{
    if (self.webView) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIME_OUT_SECONDS]];
    }
}

/**
 *  执行金生宝页面
 */
-(void)pageFlowDestroy{
    if(self.webView != nil){
        [self.webView evaluateJavaScript:@"if(typeof(pageFlowDestroy)!='undefined' && pageFlowDestroy != null){pageFlowDestroy()}" completionHandler:nil];
    }
}

-(void)pageFlowStart{
    if(self.webView != nil){
        [self.webView evaluateJavaScript:@"if(typeof(pageFlowStart)!='undefined' && pageFlowStart != null){pageFlowStart()}" completionHandler:nil];
    }
}

/**
 *  处理拨号传过来的数据拨号地址
 *
 *  @param url url链接地址
 *
 *  @return return电话号码
 */

-(NSString *)extractPhoneNumber:(NSString *)url{
    if ([url hasPrefix:@"telprompt://"] || [url hasPrefix:@"tel://"]) {
        NSRange range = [url rangeOfString:@"://"];
        url = [url substringFromIndex:range.location + 3];
    }else if([url hasPrefix:@"telprompt:"] || [url hasPrefix:@"tel:"]){
        NSRange range = [url rangeOfString:@":"];
        url = [url substringFromIndex:range.location + 1];
    }
    return url;
}

/**
 *  导航栏标题显示与隐藏
 */
-(void)navTitleShowOrHidden:(BOOL)isShow {
    if (self.navigationBar) {
        [self.navigationBar setNavTitleShowOrHide:isShow];
    }
}

#pragma mark  BackNavigationBarDelegate
/**
 *  响应导航栏完成按钮点击事件
 */
-(void)onDoneScreen{
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(void)showIndicatorView{
    if (_indicatorView) {
        [_indicatorView startAnimating];
    }
}

-(void)hideIndicatorView{
    if (_indicatorView) {
        [_indicatorView stopAnimating];
    }
}

@end
