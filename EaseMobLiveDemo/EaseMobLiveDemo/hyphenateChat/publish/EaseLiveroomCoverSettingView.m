//
//  EaseLiveroomCoverSettingView.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/10/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseLiveroomCoverSettingView.h"
#import "Masonry.h"

@interface EaseLiveroomCoverSettingView ()

@property (nonatomic, strong) UIButton *camerBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@end

@implementation EaseLiveroomCoverSettingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
    }
    return self;
}

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    [self addSubview:self.photoBtn];
    [_photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@46);
        make.bottom.equalTo(self).offset(-30);
    }];
    [self addSubview:self.camerBtn];
    [_camerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@46);
        make.bottom.equalTo(_photoBtn.mas_top).offset(-1);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeFromParentView];
}

- (UIButton*)camerBtn
{
    if (_camerBtn == nil) {
        _camerBtn = [[UIButton alloc]init];
        _camerBtn.backgroundColor = [UIColor whiteColor];
        _camerBtn.tag = 0;
        [_camerBtn setTitle:@"相机拍摄" forState:UIControlStateNormal];
        [_camerBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_camerBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        _camerBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_camerBtn addTarget:self action:@selector(coverPicker:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _camerBtn;
}

- (UIButton*)photoBtn
{
    if (_photoBtn == nil) {
        _photoBtn = [[UIButton alloc]init];
        _photoBtn.backgroundColor = [UIColor whiteColor];
        _photoBtn.tag = 1;
        [_photoBtn setTitle:@"相册选择" forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_photoBtn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        _photoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_photoBtn addTarget:self action:@selector(coverPicker:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (void)coverPicker:(UIButton *)btn
{
    [self removeFromParentView];
    if (_doneCompletion) {
        _doneCompletion(btn.tag);
    }
}

@end
