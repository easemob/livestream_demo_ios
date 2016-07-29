//
//  EaseProfileHeaderView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseProfileHeaderView.h"

#import "EaseTagView.h"
#import "EaseProfileTextView.h"

@interface EaseProfileHeaderView ()

@property (nonatomic, strong) EaseTagView *userTagView;
@property (nonatomic, strong) EaseProfileTextView *followersTextView;
@property (nonatomic, strong) EaseProfileTextView *followingTextView;
@property (nonatomic, strong) EaseProfileTextView *likeTextView;

@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation EaseProfileHeaderView

- (instancetype)initWithUsername:(NSString*)username
{
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, 214.f)];
    if (self) {
        self.backgroundColor = kDefaultSystemBgColor;
        _userTagView = [[EaseTagView alloc] initWithFrame:CGRectMake((KScreenWidth - 86.f)/2, 43.f, 86.f, 108.f) name:[EMClient sharedClient].currentUsername imageName:nil];
        [self addSubview:self.userTagView];
        [self addSubview:self.followersTextView];
        [self addSubview:self.followingTextView];
        [self addSubview:self.likeTextView];
        [self addSubview:self.descLabel];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.followersTextView.frame) - 0.5, self.followersTextView.top, 1, self.followersTextView.height)];
        line1.backgroundColor = [UIColor whiteColor];
        [self addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.followingTextView.frame) - 0.5, self.followingTextView.top, 1, self.followingTextView.height)];
        line2.backgroundColor = [UIColor whiteColor];
        [self addSubview:line2];
        
        
    }
    return self;
}

#pragma mark - getter

- (UILabel*)descLabel
{
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _followersTextView.bottom + 5.f, KScreenWidth, 16.f)];
        _descLabel.text = @"The computer can manipulate operating pump mode";
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.font = [UIFont systemFontOfSize:14.f];
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (EaseProfileTextView*)followersTextView
{
    if (_followersTextView == nil) {
        _followersTextView = [[EaseProfileTextView alloc] initWithFrame:CGRectMake(34.f, _userTagView.bottom + 10.f,(KScreenWidth - 68.f)/3, 18.f) name:NSLocalizedString(@"setting.profile.followers", @"Followers") number:@"10"];
        [_followersTextView setNameColor:[UIColor whiteColor]];
        [_followersTextView setNumberColor:[UIColor whiteColor]];
    }
    return _followersTextView;
}

- (EaseProfileTextView*)followingTextView
{
    if (_followingTextView == nil) {
        _followingTextView = [[EaseProfileTextView alloc] initWithFrame:CGRectMake(_followersTextView.left + _followersTextView.width, _userTagView.bottom + 10.f,(KScreenWidth - 68.f)/3, 18.f) name:NSLocalizedString(@"setting.profile.following", @"Following")  number:@"10"];
        [_followingTextView setNameColor:[UIColor whiteColor]];
        [_followingTextView setNumberColor:[UIColor whiteColor]];
    }
    return _followingTextView;
}

- (EaseProfileTextView*)likeTextView
{
    if (_likeTextView == nil) {
        _likeTextView = [[EaseProfileTextView alloc] initWithFrame:CGRectMake(_followingTextView.left + _followingTextView.width, _userTagView.bottom + 10.f, (KScreenWidth - 68.f)/3, 18.f) name:NSLocalizedString(@"setting.profile.like", @"Like") number:@"10"];
        [_likeTextView setNameColor:[UIColor whiteColor]];
        [_likeTextView setNumberColor:[UIColor whiteColor]];
    }
    return _likeTextView;
}

@end
