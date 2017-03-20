//
//  MainViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseMainViewController.h"

#import "EaseLiveTVListViewController.h"
#import "EasePublishViewController.h"
#import "UIImage+Color.h"
#import "EaseCreateLiveViewController.h"
#import "EaseSearchDisplayController.h"

@interface EaseMainViewController () <UITabBarControllerDelegate>
{
    EaseLiveTVListViewController *_liveTVListViewController;
}

@end

@implementation EaseMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = NSLocalizedString(@"title.live", @"Easemob Live");
    [self setupSubviews];
    self.selectedIndex = 0;
    self.tabBar.hidden = YES;
    
    self.delegate = self;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = NSLocalizedString(@"title.live", @"Easemob Live");
        self.navigationItem.rightBarButtonItem = _liveTVListViewController.logoutItem;
        self.navigationItem.leftBarButtonItem = _liveTVListViewController.searchBarItem;
    }
}


- (void)setupSubviews
{    
    [self.tabBar setTintColor:kDefaultSystemBgColor];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];

    _liveTVListViewController = [[EaseLiveTVListViewController alloc] init];
    _liveTVListViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.live", @"Easemob Live")
                                                                         image:nil
                                                                           tag:0];
    [_liveTVListViewController.tabBarItem setImage:[UIImage imageNamed:@"home_bottombar_finder_nm"]];
    [_liveTVListViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"home_bottombar_finder_hl"]];
    
    self.navigationItem.rightBarButtonItem = _liveTVListViewController.logoutItem;
    self.navigationItem.leftBarButtonItem = _liveTVListViewController.searchBarItem;
    
    self.viewControllers = @[_liveTVListViewController];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController.tabBarItem.tag == 1) {
        EasePublishViewController *publishViewController = [[EasePublishViewController alloc] init];
        [self presentViewController:publishViewController animated:YES completion:NULL];
        return NO;
    }
    return YES;
}

@end
