//
//  EaseSettingViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/2.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSettingViewController.h"

#import "EaseProfileHeaderView.h"
#import "EaseUpdateViewController.h"

@interface EaseSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) EaseProfileHeaderView *profileHeaderView;

@end

@implementation EaseSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"home.tabbar.profile", @"Profile");
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = RGBACOLOR(230, 230, 235, 1);
    self.tableView.tableHeaderView = self.profileHeaderView;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.tableView.height = KScreenHeight;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - getter

- (EaseProfileHeaderView*)profileHeaderView
{
    if (_profileHeaderView == nil) {
        _profileHeaderView = [[EaseProfileHeaderView alloc] initWithUsername:@"Username"];
    }
    return _profileHeaderView;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 54.f)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _footerView.width, 54.f)];
        [logoutButton setBackgroundColor:[UIColor whiteColor]];
        [logoutButton setTitle:NSLocalizedString(@"setting.logout.text", @"Exit") forState:UIControlStateNormal];
        [logoutButton setTitleColor:RGBACOLOR(0xfe, 0x64, 0x50, 1) forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _footerView.width, 0.5)];
        line.backgroundColor = kDefaultSystemLightGrayColor;
        [_footerView addSubview:line];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, _footerView.height - 0.5, _footerView.width, 0.5)];
        line2.backgroundColor = kDefaultSystemLightGrayColor;
        [_footerView addSubview:line2];
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        EaseUpdateViewController *updateView = [[EaseUpdateViewController alloc] init];
        [self.navigationController pushViewController:updateView animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"profileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"v%@",kLiveDemoVersion];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


@end
