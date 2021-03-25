//
//  EaseSettingsViewController.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/11.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseSettingsViewController.h"
#import "Masonry.h"
#import "EaseAboutHuanxinViewController.h"

@interface EaseSettingsViewController ()

@property (nonatomic, strong) UIView *logoView;

@property (nonatomic, strong) UIView *versionView;

@property (nonatomic, strong) UIButton *regardBtn;

@end

@implementation EaseSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self _setupSubviews];
}

- (void)_setupSubviews
{
    [self.view addSubview:self.logoView];
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@150);
        make.top.left.equalTo(self.view);
    }];
    
    [self.view addSubview:self.versionView];
    [_versionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@60);
        make.top.equalTo(self.logoView.mas_bottom).offset(12);
    }];
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(@2);
        make.bottom.equalTo(self.versionView.mas_bottom).offset(1);
    }];
    
    [self.view addSubview:self.regardBtn];
    [_regardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(self.view);
        make.height.equalTo(@60);
        make.top.equalTo(self.versionView.mas_bottom);
    }];
}

- (UIView*)logoView
{
    if (_logoView == nil) {
        _logoView = [[UIView alloc]init];
        _logoView.backgroundColor = [UIColor whiteColor];
        UIImageView *logoImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"huanxin-logo"]];
        [_logoView addSubview:logoImg];
        [logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@55);
            make.height.equalTo(@45);
            make.center.equalTo(_logoView);
        }];
        UILabel *productName = [[UILabel alloc]init];
        productName.text = @"环信直播聊天室";
        productName.textAlignment = NSTextAlignmentCenter;
        productName.textColor = [UIColor blackColor];
        productName.font = [UIFont systemFontOfSize:14.f];
        [_logoView addSubview:productName];
        [productName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@20);
            make.centerX.equalTo(logoImg);
            make.top.equalTo(logoImg.mas_bottom).offset(12);
        }];
    }
    return _logoView;
}

- (UIView*)versionView
{
    if (_versionView == nil) {
        _versionView = [[UIView alloc]init];
        _versionView.backgroundColor = [UIColor whiteColor];
        UILabel *version = [[UILabel alloc]initWithFrame:CGRectMake(16, 20, 50, 20)];
        version.text = @"版本";
        version.textColor = [UIColor blackColor];
        version.font = [UIFont systemFontOfSize:14];
        [_versionView addSubview:version];
        UILabel *versionNum = [[UILabel alloc]initWithFrame:CGRectMake(self.view.width - 56, 20, 40, 20)];
        versionNum.textAlignment = NSTextAlignmentRight;
        versionNum.text = kLiveDemoVersion;
        versionNum.font = [UIFont systemFontOfSize:14];
        versionNum.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [_versionView addSubview:versionNum];
    }
    return _versionView;
}

- (UIButton*)regardBtn
{
    if (_regardBtn == nil) {
        _regardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _regardBtn.backgroundColor = [UIColor whiteColor];
        UILabel *regard = [[UILabel alloc]initWithFrame:CGRectMake(16, 20, 80, 20)];
        regard.text = @"关于环信";
        regard.textColor = [UIColor blackColor];
        regard.font = [UIFont systemFontOfSize:14];
        [_regardBtn addSubview:regard];
        UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.width - 36, 20, 20, 20)];
        arrow.image = [UIImage imageNamed:@"icon-enter"];
        [_regardBtn addSubview:arrow];
        [_regardBtn addTarget:self action:@selector(reagrdHuanxin) forControlEvents:UIControlEventTouchUpInside];
    }
    return _regardBtn;
}

//关于环信
- (void)reagrdHuanxin
{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.easemob.com/about"]];
    //EaseAboutHuanxinViewController *aboutHuanxinController = [[EaseAboutHuanxinViewController alloc]init];
    //[self.navigationController pushViewController:aboutHuanxinController animated:YES];
}

@end

