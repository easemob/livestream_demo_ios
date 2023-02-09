//
//  EaseFinishLiveView.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/16.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseFinishLiveView.h"
#import "Masonry.h"

@interface EaseFinishLiveView()

@property (nonatomic, strong) NSString *titleText;

@end

@implementation EaseFinishLiveView

- (instancetype)initWithTitleInfo:(NSString *)titleText
{
    self = [super init];
       if (self) {
           _titleText = titleText;
           [self _setupSuviews];
       }
    return self;
}

- (void)_setupSuviews
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *finishView = [[UIView alloc]init];
    finishView.backgroundColor = [UIColor whiteColor];
    finishView.layer.cornerRadius = 8;
    [self addSubview:finishView];
    [finishView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(self);
        make.centerY.centerX.equalTo(self);
    }];
    
    UILabel *content = [[UILabel alloc]init];
    content.text = _titleText;
    content.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0];
    content.textAlignment = NSTextAlignmentCenter;
    content.font = [UIFont fontWithName:@"PingFangSC" size: 20];
    [finishView addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(finishView).offset(76);
        make.left.equalTo(finishView).offset(32);
        make.right.equalTo(finishView).offset(-32);
        make.height.equalTo(@28);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setTitle:NSLocalizedString(@"publish.cancel", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn setTitleColor:RGBACOLOR(51, 51, 51, 1) forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    cancelBtn.layer.borderWidth = 1;
    cancelBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    cancelBtn.layer.cornerRadius = 8;
    [finishView addSubview:cancelBtn];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-32)/2;
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(finishView);
        make.height.equalTo(@55);
        make.width.mas_equalTo(width);
    }];
    
    UIButton *confirmBtn = [[UIButton alloc]init];
    [confirmBtn setTitle:@"end and exit" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [confirmBtn setTitleColor:RGBACOLOR(255, 43, 43, 1) forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:[UIColor whiteColor]];
    confirmBtn.layer.borderWidth = 1;
    confirmBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    confirmBtn.layer.cornerRadius = 8;
    [finishView addSubview:confirmBtn];
    confirmBtn.tag = 1;
    [confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(finishView);
        make.height.equalTo(@55);
        make.width.mas_equalTo(width);
    }];
}

#pragma mark - Action

- (void)confirmAction:(UIButton *)btn
{
    BOOL isFinish = false;
    if (btn.tag == 1) {
        isFinish = true;
    }
    if (_doneCompletion) {
        _doneCompletion(isFinish);
    }
}

@end
