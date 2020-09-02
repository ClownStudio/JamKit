//
//  MainViewController.m
//  JamKit
//
//  Created by 张文洁 on 2020/8/31.
//  Copyright © 2020 张文洁. All rights reserved.
//

#import "MainViewController.h"
#import "WMPageController.h"
#import "WebViewViewController.h"
#import "Constant.h"

@interface MainViewController () <WMPageControllerDataSource,WMPageControllerDelegate,UITabBarDelegate>

@property (nonatomic, strong) WMPageController *pageViewController;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *tabbarItems;
@property (nonatomic, strong) UITabBar *tabbar;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WebViewViewController *first = [[WebViewViewController alloc] initWithUrl:[NSURL URLWithString:@"https://www.alipay.com"] isTop:YES];
    
    WebViewViewController *second = [[WebViewViewController alloc] initWithUrl:[NSURL URLWithString:@"https://2.taobao.com"] isTop:YES];
    
    WebViewViewController *third = [[WebViewViewController alloc] initWithUrl:[NSURL URLWithString:@"https://www.weibo.com"] isTop:YES];
    
    WebViewViewController *fourth = [[WebViewViewController alloc] initWithUrl:[NSURL URLWithString:@"https://www.github.com"] isTop:YES];
    
    _viewControllers = [[NSMutableArray alloc] initWithObjects:first,second,third,fourth, nil];
    
    _pageViewController = [[WMPageController alloc] init];
    [_pageViewController setDataSource:self];
    [_pageViewController setDelegate:self];
    
    [self addChildViewController:_pageViewController];
    [_pageViewController.view setFrame:self.view.bounds];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    
    NSArray *itemTitles = @[@"首页",@"群组",@"消息",@"我的"];
    NSArray *itemImageNames = @[@"home",@"group",@"message",@"account"];
    _tabbarItems = [NSMutableArray new];
    for (int i = 0; i < [itemTitles count]; i++) {
        NSString *title = [itemTitles objectAtIndex:i];
        NSString *imageName = [itemImageNames objectAtIndex:i];
        UIImage *image = [UIImage imageNamed:imageName];
        UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_highlight",imageName]];
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
        [_tabbarItems addObject:item];
    }
    _tabbar = [[UITabBar alloc] initWithFrame:CGRectMake(0, HEIGHT - TABBAR_HEIGHT, WIDTH, TABBAR_HEIGHT)];
    _tabbar.delegate = self;
    [_tabbar setItems:_tabbarItems];
    [_tabbar setSelectedItem:[_tabbarItems firstObject]];
    [self.view addSubview:_tabbar];
}

- (void)viewSafeAreaInsetsDidChange{
    [super viewSafeAreaInsetsDidChange];
    CGRect temp = _tabbar.frame;
    temp.size.height = TABBAR_HEIGHT + self.view.safeAreaInsets.bottom;
    temp.origin.y = HEIGHT - temp.size.height;
    _tabbar.frame = temp;
}

#pragma mark PageViewControllerDelegate

//分页数
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController
{
    return 4;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    return [_viewControllers objectAtIndex:index];
}

- (CGRect)pageController:(nonnull WMPageController *)pageController preferredFrameForContentView:(nonnull WMScrollView *)contentView {
    return CGRectMake(0, 0, WIDTH, HEIGHT);
}


- (CGRect)pageController:(nonnull WMPageController *)pageController preferredFrameForMenuView:(nonnull WMMenuView *)menuView {
    return CGRectZero;
}


- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info{
    NSInteger index = 0;
    for (NSInteger i=0 ; i < [_viewControllers count]; i++) {
        if ([viewController isEqual:[_viewControllers objectAtIndex:i]]) {
            index = i;
            break;
        }
    }
    [_tabbar setSelectedItem:[_tabbarItems objectAtIndex:index]];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    int index = 0;
    for (int i=0 ; i < [_tabbarItems count]; i++) {
        if ([item isEqual:[_tabbarItems objectAtIndex:i]]) {
            index = i;
            break;
        }
    }
    [_pageViewController setSelectIndex:index];
}

@end
