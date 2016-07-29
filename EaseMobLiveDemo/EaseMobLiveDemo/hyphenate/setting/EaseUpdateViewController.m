//
//  EaseUpdateViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseUpdateViewController.h"

@interface EaseUpdateViewController ()

@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *updateButton;
@property (nonatomic, strong) UIButton *refreshButton;

@end

@implementation EaseUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.update", @"Update Info");
    
    [self.view addSubview:self.versionLabel];
    [self.view addSubview:self.infoLabel];
    [self.view addSubview:self.updateButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshButton];
}

#pragma mark - getter

- (UIButton*)refreshButton
{
    if (_refreshButton == nil) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton.frame = CGRectMake(0, 0, 60.f, 44.f);
        [_refreshButton setTitle:NSLocalizedString(@"setting.update.button.refresh", @"Refresh") forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

- (UIButton*)updateButton
{
    if (_updateButton == nil) {
        _updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateButton.frame = CGRectMake(0, _infoLabel.bottom + 10.f, KScreenWidth, 54.f);
        _updateButton.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _updateButton.width, 0.5)];
        line.backgroundColor = kDefaultSystemLightGrayColor;
        [_updateButton addSubview:line];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, _updateButton.height - 0.5, _updateButton.width, 0.5)];
        line2.backgroundColor = kDefaultSystemLightGrayColor;
        [_updateButton addSubview:line2];
        
        [_updateButton setTitle:NSLocalizedString(@"setting.update.button.update", @"Update") forState:UIControlStateNormal];
        [_updateButton setTitleColor:kDefaultSystemTextColor forState:UIControlStateNormal];
        [_updateButton setTitleColor:kDefaultSystemTextGrayColor forState:UIControlStateSelected];
        
        [_updateButton addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateButton;
}

- (UILabel*)versionLabel
{
    if (_versionLabel == nil) {
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.f, 32.f, KScreenWidth - 12.f, 20.f)];
        _versionLabel.textColor = kDefaultSystemTextColor;
        _versionLabel.font = [UIFont boldSystemFontOfSize:18];
        _versionLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"setting.update.label.version", @"Version"),kLiveDemoVersion];
    }
    return _versionLabel;
}

- (UILabel*)infoLabel
{
    if (_infoLabel == nil) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.f, _versionLabel.bottom + 10.f, KScreenWidth - 24.f, 0)];
        _infoLabel.textColor = RGBACOLOR(148, 148, 148, 1);
        _infoLabel.font = [UIFont systemFontOfSize:15];
        _infoLabel.text = @"Information \nLorem ipsum dolor sit amet, consectetur adipiscing elit.Aenean euismod bibendum laoreet. Proingravida dolor sitamet lacus accumsan et viverra justo commodo. Proinsodales pulvinar tempor. Cum sociis natoque penatibus etmagnis dis parturient montes, nascetur ridiculus mus. Namfermentum, nulla luctus pharetra vulputate, felis tellus mollisorci, sed rhoncus sapien nunc eget odio.";
        CGRect rect = [_infoLabel.text boundingRectWithSize:CGSizeMake(_infoLabel.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0f]} context:nil];
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _infoLabel.numberOfLines = rect.size.height/15;
        _infoLabel.height = rect.size.height;
    }
    return _infoLabel;
}

#pragma mark - action

- (void)updateAction
{

}

- (void)refreshAction
{

}

@end
