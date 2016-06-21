//
//  EaseSettingViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/2.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSettingViewController.h"

@interface EaseSettingViewController ()

@property (strong, nonatomic) UIView *footerView;

@end

@implementation EaseSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
}

#pragma mark - getter

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 10, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_footerView addSubview:line];
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, _footerView.frame.size.width - 20, 45)];
        [logoutButton setBackgroundColor:RGBACOLOR(0xfe, 0x64, 0x50, 1)];
        NSString *username = [[EMClient sharedClient] currentUsername];
        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:@"退出登录(%@)", username];
        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];
    }
    
    return _footerView;
}

#pragma mark - Action

- (void)logoutAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"退出中..." toView:nil];
    [[EMClient sharedClient] logout:NO];
    [hud hide:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@NO];
}

@end
