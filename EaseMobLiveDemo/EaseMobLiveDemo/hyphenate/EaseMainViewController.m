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

@interface EaseMainViewController () <UITabBarControllerDelegate>
{
    EaseSettingViewController *_settingViewController;
    ViewController *_viewController;
    EaseLiveTVListViewController *_liveTVListViewController;
    EaseConversationViewController *_conversationController;
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
        self.title = @"广场";
        self.navigationItem.rightBarButtonItem = nil;
    }else if (item.tag == 1){
        self.title = @"发布";
        self.navigationItem.rightBarButtonItem = nil;
    }else if (item.tag == 2){
        self.title =@"私信";
        self.navigationItem.rightBarButtonItem = nil;
    }else if (item.tag == 3){
        self.title =@"设置";
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (void)setupSubviews
{
    self.tabBar.backgroundImage = [[UIImage imageNamed:@"tabbarBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"tabbarSelectBg"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
    

    _liveTVListViewController = [[EaseLiveTVListViewController alloc] init];    
    _liveTVListViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"广场"
                                                                         image:nil
                                                                           tag:0];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发布"
                                                              image:nil
                                                                tag:1];
    
    _conversationController = [[EaseConversationViewController alloc] init];
    _conversationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"私信"
                                                                      image:nil
                                                                        tag:2];
    
    _settingViewController = [[EaseSettingViewController alloc] init];
    _settingViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置"
                                                                      image:nil
                                                                        tag:3];
    
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


@end
