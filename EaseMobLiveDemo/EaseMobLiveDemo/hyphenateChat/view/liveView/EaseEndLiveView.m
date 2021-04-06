//
//  EaseEndLiveView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/19.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseEndLiveView.h"

@interface EaseEndLiveView ()

@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *audienceLabel;


@end

@implementation EaseEndLiveView

- (instancetype)initWithUsername:(NSString*)username
                        audience:(NSString*)audience
{
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if (self) {
        self.backgroundColor = kDefaultSystemBgColor;
        
        [self addSubview:self.closeButton];
        [self addSubview:self.headImageView];
        [self addSubview:self.nameLabel];
        self.nameLabel.text = username;
        [self addSubview:self.endLabel];
        [self addSubview:self.audienceLabel];
        self.audienceLabel.text = audience;
        [self addSubview:self.continueButton];
    }
    return self;
}

#pragma mark - getter

- (UIButton*)continueButton
{
    if (_continueButton == nil) {
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _continueButton.frame = CGRectMake((KScreenWidth - 300)/2, KScreenHeight - 75.f, 300.f, 45.f);
        _continueButton.backgroundColor = kDefaultLoginButtonColor;
        [_continueButton setTitle:NSLocalizedString(@"endview.continue.live", @"Continue") forState:UIControlStateNormal];
        [_continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_continueButton addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
        _continueButton.layer.cornerRadius = 4.f;
    }
    return _continueButton;
}

- (UIButton*)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(KScreenWidth - 40, 31.f, 30, 30);
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((KScreenWidth-80)/2, 121, 80, 80)];
        _headImageView.image = [UIImage imageNamed:@"live_default_user"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = _headImageView.width/2;
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 217.f, KScreenWidth, 15)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _nameLabel;
}

- (UILabel*)endLabel
{
    if (_endLabel == nil) {
        _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 306.f, KScreenWidth, 25)];
        _endLabel.textAlignment = NSTextAlignmentCenter;
        _endLabel.textColor = [UIColor whiteColor];
        _endLabel.font = [UIFont systemFontOfSize:25 weight:100];
        _endLabel.text = NSLocalizedString(@"endview.live.end", @"Live Finished");
    }
    return _endLabel;
}

- (UILabel*)audienceLabel
{
    if (_audienceLabel == nil) {
        _audienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 347.f, KScreenWidth, 15)];
        _audienceLabel.textAlignment = NSTextAlignmentCenter;
        _audienceLabel.textColor = [UIColor whiteColor];
        _audienceLabel.font = [UIFont systemFontOfSize:15];
    }
    return _audienceLabel;
}

#pragma mark - public

- (void)setAudience:(NSString *)audience
{
    _audienceLabel.text = audience;
}

#pragma mark - action

- (void)closeAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickEndButton)]) {
        [self.delegate didClickEndButton];
    }
}

- (void)continueAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickContinueButton)]) {
        [self.delegate didClickContinueButton];
    }
    [self removeFromSuperview];
}

@end
