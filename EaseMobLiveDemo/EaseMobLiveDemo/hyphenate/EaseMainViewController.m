//
//  MainViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseMainViewController.h"

#import "ViewController.h"
#import "EaseLiveTVListViewController.h"
#import "EaseSettingViewController.h"
#import "EasePublishViewController.h"
#import "EaseConversationViewController.h"
#import "UIImage+Color.h"
#import "EaseSearchViewController.h"

@interface EaseMainViewController () <UITabBarControllerDelegate>
{
    EaseSettingViewController *_settingViewController;
    ViewController *_viewController;
    EaseLiveTVListViewController *_liveTVListViewController;
    EaseConversationViewController *_conversationController;
    
    UIBarButtonItem *_searchBarItem;
    UIBarButtonItem *_rankBarItem;
}

@end

@implementation EaseMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"广场";
    [self setupSubviews];
    self.selectedIndex = 0;
    
    self.delegate = self;
    [self setupUnreadMessageCount];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = NSLocalizedString(@"home.tabbar.finder", @"Finder");
        self.navigationItem.rightBarButtonItem = _rankBarItem;
        self.navigationItem.leftBarButtonItem = _searchBarItem;
    }else if (item.tag == 1){
    }else if (item.tag == 2){
        self.title = NSLocalizedString(@"home.tabbar.message", @"Message");
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }else if (item.tag == 3){
        self.title = NSLocalizedString(@"home.tabbar.profile", @"Profile");
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
}


- (void)setupSubviews
{    
    [self.tabBar setTintColor:kDefaultSystemBgColor];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBACOLOR(255, 255, 255, 1)} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kDefaultSystemBgColor} forState:UIControlStateSelected];
    
    self.tabBar.backgroundImage = [UIImage imageWithColor:kDefaultSystemBgColor size:CGSizeMake(KScreenWidth/4, 49)];
    self.tabBar.selectionIndicatorImage = [UIImage imageWithColor:RGBACOLOR(255, 255, 255, 1) size:CGSizeMake(KScreenWidth/4, 49)];

    _liveTVListViewController = [[EaseLiveTVListViewController alloc] init];
    _liveTVListViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"home.tabbar.finder", @"Finder")
                                                                         image:nil
                                                                           tag:0];
    [_liveTVListViewController.tabBarItem setImage:[UIImage imageNamed:@"home_bottombar_finder_nm"]];
    [_liveTVListViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"home_bottombar_finder_hl"]];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(0, 0, 44.f, 44.f);
    [searchButton setImage:[UIImage imageNamed:@"home_search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, -12, 0, 0)];
    _searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.leftBarButtonItem = _searchBarItem;
    
    UIButton *rankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rankButton.frame = CGRectMake(0, 0, 44.f, 44.f);
    [rankButton setImage:[UIImage imageNamed:@"home_ranking"] forState:UIControlStateNormal];
    [rankButton addTarget:self action:@selector(rankAction) forControlEvents:UIControlEventTouchUpInside];
    [rankButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -12)];
    _rankBarItem = [[UIBarButtonItem alloc] initWithCustomView:rankButton];
    self.navigationItem.rightBarButtonItem = _rankBarItem;
    
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"home.tabbar.live", @"Live")
                                                              image:nil
                                                                tag:1];
    [viewController.tabBarItem setImage:[UIImage imageNamed:@"home_bottombar_live_nm"]];
    [viewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"home_bottombar_live_hl"]];
    
    _conversationController = [[EaseConversationViewController alloc] init];
    _conversationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"home.tabbar.message", @"Message")
                                                                      image:nil
                                                                        tag:2];
    [_conversationController.tabBarItem setImage:[UIImage imageNamed:@"home_bottombar_message_nm"]];
    [_conversationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"home_bottombar_message_hl"]];
    
    _settingViewController = [[EaseSettingViewController alloc] init];
    _settingViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"home.tabbar.profile", @"Profile")
                                                                      image:nil
                                                                        tag:3];
    [_settingViewController.tabBarItem setImage:[UIImage imageNamed:@"home_bottombar_profile_nm"]];
    [_settingViewController.tabBarItem setSelectedImage:[UIImage imageNamed:@"home_bottombar_profile_hl"]];
    
    self.viewControllers = @[_liveTVListViewController,viewController,_conversationController,_settingViewController];
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

-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        if (conversation.type == EMConversationTypeChat) {
            unreadCount += conversation.unreadMessagesCount;
        }
    }
    if (_conversationController) {
        if (unreadCount > 0) {
            _conversationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _conversationController.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - action

- (void)searchAction
{
    EaseSearchViewController *searchView = [[EaseSearchViewController alloc] init];
    [self.navigationController pushViewController:searchView animated:YES];
}

- (void)rankAction
{

}

@end
