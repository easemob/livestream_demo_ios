//
//  EaseProfileLiveView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseProfileLiveView.h"

#import "EaseTagView.h"
#import "EaseProfileTextView.h"

@interface EaseProfileLiveView ()
{
    NSString *_username;
}

@property (nonatomic, strong) UIView *profileCardView;
@property (nonatomic, strong) EaseTagView *headTagView;

@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UIButton *replyButton;

@property (nonatomic, strong) UIButton *kickButton;
@property (nonatomic, strong) UIButton *muteButton;

@property (nonatomic, strong) EaseProfileTextView *followTextView;
@property (nonatomic, strong) EaseProfileTextView *followingTextView;

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation EaseProfileLiveView

- (instancetype)initWithUsername:(NSString*)username;
{
    self = [super init];
    if (self) {
        _username = [username copy];
        [self addSubview:self.profileCardView];
        [self addSubview:self.headTagView];
        
        if (username.length > 0 && ![username isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self.profileCardView addSubview:self.kickButton];
            [self.profileCardView addSubview:self.muteButton];
            [self.profileCardView addSubview:self.followButton];
            [self.profileCardView addSubview:self.messageButton];
            [self.profileCardView addSubview:self.replyButton];
            
            UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.followButton.frame) - 0.5, self.followButton.top + 12, 1, 30)];
            line1.backgroundColor = RGBACOLOR(99, 99, 99, 1);
            [self.profileCardView addSubview:line1];
            
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.messageButton.frame) - 0.5, self.followButton.top + 12, 1, 30)];
            line2.backgroundColor = RGBACOLOR(99, 99, 99, 1);
            [self.profileCardView addSubview:line2];
        }
        [self.profileCardView addSubview:self.followTextView];
        [self.profileCardView addSubview:self.followingTextView];
        [self.profileCardView addSubview:self.descLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.width/2 - 0.5, _followTextView.top, 1, 20)];
        line.backgroundColor = RGBACOLOR(99, 99, 99, 1);
        [self.profileCardView addSubview:line];
    }
    return self;
}

#pragma mark - getter

- (UILabel*)descLabel
{
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _followTextView.bottom + 10.f, KScreenWidth, 16.f)];
        _descLabel.font = [UIFont systemFontOfSize:14.f];
        _descLabel.textColor = kDefaultSystemTextColor;
        _descLabel.text = @"Text Example text ExampleText Example.";
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (EaseProfileTextView*)followTextView
{
    if (_followTextView == nil) {
        _followTextView = [[EaseProfileTextView alloc] initWithFrame:CGRectMake(KScreenWidth/2 - 100, 89.f, 100.f, 18.f) name:NSLocalizedString(@"profile.follow", @"Follow") number:@"10"];
    }
    return _followTextView;
}

- (EaseProfileTextView*)followingTextView
{
    if (_followingTextView == nil) {
        _followingTextView = [[EaseProfileTextView alloc] initWithFrame:CGRectMake(KScreenWidth/2, 89.f, 100.f, 18.f) name:NSLocalizedString(@"profile.following", @"Following") number:@"100"];
    }
    return _followingTextView;
}

- (EaseTagView*)headTagView
{
    if (_headTagView == nil) {
        _headTagView = [[EaseTagView alloc] initWithFrame:CGRectMake((KScreenWidth - 86.f)/2, self.height - 206.f - 30, 86.f, 108.f) name:_username imageName:nil];
        [_headTagView setNameColor:kDefaultSystemTextColor];
    }
    return _headTagView;
}

- (UIView*)profileCardView
{
    if (_profileCardView == nil) {
        _profileCardView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 206.f, self.width, 206.f)];
        _profileCardView.backgroundColor = [UIColor whiteColor];
    }
    return _profileCardView;
}

- (UIButton*)followButton
{
    if (_followButton == nil) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame = CGRectMake(0, _profileCardView.height - 54.f, _profileCardView.width/3, 54.f);
        _followButton.backgroundColor = kDefaultSystemBgColor;
        [_followButton setTitle:NSLocalizedString(@"profile.follow", @"Follow") forState:UIControlStateNormal];
        [_followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _followButton;
}

- (UIButton*)messageButton
{
    if (_messageButton == nil) {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageButton.frame = CGRectMake(_followButton.left + _followButton.width, _profileCardView.height - 54.f, _profileCardView.width/3, 54.f);
        _messageButton.backgroundColor = kDefaultSystemBgColor;
        [_messageButton setTitle:NSLocalizedString(@"profile.message", @"Message") forState:UIControlStateNormal];
        [_messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_messageButton addTarget:self action:@selector(messageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

- (UIButton*)replyButton
{
    if (_replyButton == nil) {
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.frame = CGRectMake(_messageButton.left + _messageButton.width, _profileCardView.height - 54.f, _profileCardView.width/3, 54.f);
        _replyButton.backgroundColor = kDefaultSystemBgColor;
        [_replyButton setTitle:NSLocalizedString(@"profile.reply", @"Reply") forState:UIControlStateNormal];
        [_replyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_replyButton addTarget:self action:@selector(replyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replyButton;
}

- (UIButton*)kickButton
{
    if (_kickButton == nil) {
        _kickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _kickButton.frame = CGRectMake(14.f, 5.f, 23.f, 28.f);
        [_kickButton setImage:[UIImage imageNamed:@"popup_admin_kick"] forState:UIControlStateNormal];
        [_kickButton setTitle:NSLocalizedString(@"profile.kick", @"Kick") forState:UIControlStateNormal];
        [_kickButton setTitleColor:kDefaultSystemTextColor forState:UIControlStateNormal];
        [_kickButton.titleLabel setFont:[UIFont systemFontOfSize:9.f]];
        
        CGFloat totalHeight = (_kickButton.imageView.height + _kickButton.titleLabel.height);
        [_kickButton setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - _kickButton.imageView.height), 0.0, 0.0, -_kickButton.titleLabel.width)];
        [_kickButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -_kickButton.imageView.width, -(totalHeight - _kickButton.titleLabel.height),0.0)];
    }
    return _kickButton;
}

- (UIButton*)muteButton
{
    if (_muteButton == nil) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteButton.frame = CGRectMake(57.f , 5.f, 23.f, 28.f);
        [_muteButton setImage:[UIImage imageNamed:@"popup_admin_mute"] forState:UIControlStateNormal];
        [_muteButton setTitle:NSLocalizedString(@"profile.mute", @"Mute") forState:UIControlStateNormal];
        [_muteButton setTitleColor:kDefaultSystemTextColor forState:UIControlStateNormal];
        [_muteButton.titleLabel setFont:[UIFont systemFontOfSize:9.f]];
        
        CGFloat totalHeight = (_muteButton.imageView.height + _muteButton.titleLabel.height);
        [_muteButton setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight - _muteButton.imageView.height), 0.0, 0.0, -_muteButton.titleLabel.width)];
        [_muteButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -_muteButton.imageView.width, -(totalHeight - _muteButton.titleLabel.height),0.0)];
    }
    return _muteButton;
}

#pragma mark - action

- (void)replyAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectReplyWithUsername:)]) {
        [self.delegate didSelectReplyWithUsername:_username];
        [self removeFromParentView];
    }
}

- (void)messageAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMessageWithUsername:)]) {
        [self.delegate didSelectMessageWithUsername:_username];
        [self removeFromParentView];
    }
}

@end
