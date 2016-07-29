//
//  EasePrintImageView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/19.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EasePrintImageView.h"

#define kMargin 5.f

@interface EasePrintImageView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *printImageView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation EasePrintImageView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)];
        [self addGestureRecognizer:tap];
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.printImageView];
        [self.bgView addSubview:self.shareButton];
        [self.bgView addSubview:self.cancelButton];
    }
    return self;
}

#pragma mark - getter

- (UIView*)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(52.f, 100.f, KScreenWidth - 104, KScreenHeight/2 + 100.f + kMargin * 4)];
        _bgView.layer.cornerRadius = 4.f;
        _bgView.backgroundColor = [UIColor whiteColor];
        
    }
    return _bgView;
}

- (UIImageView*)printImageView
{
    if (_printImageView == nil) {
        _printImageView = [[UIImageView alloc] init];
        _printImageView.frame = CGRectMake(5.f, 5.f, _bgView.width - 10.f, KScreenHeight/2);
        _printImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _printImageView.contentMode = UIViewContentModeScaleAspectFill;
        _printImageView.layer.masksToBounds = YES;
    }
    return _printImageView;
}

- (UIButton*)shareButton
{
    if (_shareButton == nil) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(5.f, CGRectGetMaxY(_printImageView.frame) + kMargin, _bgView.width - 10.f, 50.f);
        [_shareButton setTitle:NSLocalizedString(@"button.share", @"Share") forState:UIControlStateNormal];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton setBackgroundColor:kDefaultSystemBgColor];
        [_shareButton addTarget:self action:@selector(shareButton) forControlEvents:UIControlEventTouchUpInside];
        _shareButton.layer.cornerRadius = 4.f;
    }
    return _shareButton;
}

- (UIButton*)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(5.f, CGRectGetMaxY(_shareButton.frame) + kMargin, _bgView.width - 10.f, 50.f);
        [_cancelButton setTitle:NSLocalizedString(@"button.cancel", @"Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:kDefaultSystemTextColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.layer.cornerRadius = 4.f;
    }
    return _cancelButton;
}

#pragma mark - setter

- (void)setImage:(UIImage *)image
{
    _printImageView.image = image;
}

#pragma mark - action

- (void)shareAction
{

}

- (void)cancelAction
{
    [self removeFromSuperview];
}

@end
