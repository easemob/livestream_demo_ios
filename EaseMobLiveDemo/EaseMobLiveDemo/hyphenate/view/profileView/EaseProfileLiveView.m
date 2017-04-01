//
//  EaseProfileLiveView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseProfileLiveView.h"
#import "MBProgressHUD+Add.h"

@interface EaseProfileLiveView ()
{
    NSString *_username;
    NSString *_chatroomId;
    BOOL _isOwner;
}

@property (nonatomic, strong) UIView *profileCardView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *kickButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *blockButton;

@property (nonatomic, strong) UIButton *adminButton;

@end

@implementation EaseProfileLiveView

- (instancetype)initWithUsername:(NSString*)username
                      chatroomId:(NSString*)chatroomId
                         isOwner:(BOOL)isOwner
{
    self = [self initWithUsername:username chatroomId:chatroomId];
    if (self) {
        _isOwner = isOwner;
        if (username.length > 0 && ![username isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self.profileCardView addSubview:self.muteButton];
            [self.profileCardView addSubview:self.blockButton];
            [self.profileCardView addSubview:self.kickButton];
            if (_isOwner) {
                [self.profileCardView addSubview:self.adminButton];
            }
        }
    }
    return self;
}

- (instancetype)initWithUsername:(NSString*)username
                      chatroomId:(NSString*)chatroomId
{
    self = [super init];
    if (self) {
        _username = [username copy];
        _chatroomId = [chatroomId copy];
        [self addSubview:self.profileCardView];
        [self addSubview:self.headImageView];
        [self addSubview:self.nameLabel];
    }
    return self;
}

#pragma mark - getter

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake((KScreenWidth - 60)/2, self.profileCardView.top + 41.f, 60.f, 60.f);
        _headImageView.layer.cornerRadius = _headImageView.width/2;
        _headImageView.backgroundColor = RGBACOLOR(222, 222, 222, 1);
        _headImageView.layer.masksToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.image = [UIImage imageNamed:@"live_default_user"];
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(50.f, _headImageView.bottom + 16.f, self.width - 100, 20.f);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = kDefaultSystemTextColor;
        _nameLabel.font = [UIFont systemFontOfSize:17.f];
        _nameLabel.text = _username;
    }
    return _nameLabel;
}

- (UIView*)profileCardView
{
    if (_profileCardView == nil) {
        _profileCardView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 283.f, self.width, 283.f)];
        _profileCardView.backgroundColor = [UIColor whiteColor];
    }
    return _profileCardView;
}

- (UIButton*)kickButton
{
    if (_kickButton == nil) {
        _kickButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _kickButton.frame = CGRectMake(20 + ((KScreenWidth - 20 * 2) / 3) * 2, 150, ((KScreenWidth - 20 * 2) / 3), 30.f);
        [_kickButton setImage:[UIImage imageNamed:@"kick"] forState:UIControlStateNormal];
        [_kickButton setTitle:NSLocalizedString(@"profile.kick", @"Kick") forState:UIControlStateNormal];
        [_kickButton setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
        [_kickButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        
        [_kickButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 0.0)];
        [_kickButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 0.0)];
        
        [_kickButton addTarget:self action:@selector(kickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kickButton;
}

- (UIButton*)muteButton
{
    if (_muteButton == nil) {
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteButton.frame = CGRectMake(20, 150.f, ((KScreenWidth - 20 * 2) / 3), 30.f);
        [_muteButton setImage:[UIImage imageNamed:@"notalk"] forState:UIControlStateNormal];
        [_muteButton setTitle:NSLocalizedString(@"profile.mute", @"Mute") forState:UIControlStateNormal];
        [_muteButton setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
        [_muteButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        
        [_muteButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0)];
        [_muteButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0)];
        
        [_muteButton addTarget:self action:@selector(muteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteButton;
}

- (UIButton*)blockButton
{
    if (_blockButton == nil) {
        _blockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _blockButton.frame = CGRectMake(20 + ((KScreenWidth - 20 * 2) / 3), 150.f, ((KScreenWidth) / 3), 30.f);
        [_blockButton setImage:[UIImage imageNamed:@"admin"] forState:UIControlStateNormal];
        [_blockButton setTitle:NSLocalizedString(@"profile.block", @"Block") forState:UIControlStateNormal];
        [_blockButton setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
        [_blockButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        
        [_blockButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)];
        [_blockButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)];
        
        [_blockButton addTarget:self action:@selector(blockAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _blockButton;
}

- (UIButton*)adminButton
{
    if (_adminButton == nil) {
        _adminButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _adminButton.backgroundColor = kDefaultLoginButtonColor;
        _adminButton.frame = CGRectMake((self.width - 300)/2, _blockButton.bottom + 20.f, 300.f, 45.f);
        [_adminButton setTitle:NSLocalizedString(@"profile.setAdmin", @"Set Admin") forState:UIControlStateNormal];
        
        _adminButton.layer.cornerRadius = 4.f;
        
        [_adminButton addTarget:self action:@selector(setAdminAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminButton;
}

#pragma mark - action

- (void)muteAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"profile.mute", @"Mute")] toView:self];
    __weak MBProgressHUD *weakHud = hud;
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager muteMembers:@[_username]
                                    muteMilliseconds:-1
                                        fromChatroom:_chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError) {
                                              if (!aError) {
                                                  [weakHud hide:YES];
                                                  [weakSelf removeFromParentView];
                                              } else {
                                                  [weakHud setLabelText:aError.errorDescription];
                                                  [weakHud hide:YES afterDelay:0.5];
                                              }
                                          }];
}

- (void)kickAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"profile.kick", @"Kick")] toView:self];
    __weak MBProgressHUD *weakHud = hud;
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager removeMembers:@[_username]
                                          fromChatroom:_chatroomId
                                            completion:^(EMChatroom *aChatroom, EMError *aError) {
                                                if (!aError) {
                                                    [weakHud hide:YES];
                                                    [weakSelf removeFromParentView];
                                                } else {
                                                    [weakHud setLabelText:aError.errorDescription];
                                                    [weakHud hide:YES afterDelay:0.5];
                                                }
                                            }];
}

- (void)blockAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"profile.block", @"Block")]  toView:self];
    __weak MBProgressHUD *weakHud = hud;
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager blockMembers:@[_username]
                                         fromChatroom:_chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError) {
                                               if (!aError) {
                                                   [weakHud hide:YES];
                                                   [weakSelf removeFromParentView];
                                               } else {
                                                   [weakHud setLabelText:aError.errorDescription];
                                                   [weakHud hide:YES afterDelay:0.5];
                                               }
                                           }];
}

- (void)setAdminAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"profile.setAdmin", @"Set Admin")] toView:self];
    __weak MBProgressHUD *weakHud = hud;
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager addAdmin:_username
                                       toChatroom:_chatroomId
                                       completion:^(EMChatroom *aChatroomp, EMError *aError) {
                                           if (!aError) {
                                               [weakHud hide:YES];
                                               [weakSelf removeFromParentView];
                                           } else {
                                               [weakHud setLabelText:aError.errorDescription];
                                               [weakHud hide:YES afterDelay:0.5];
                                           }
                                       }];
}

@end
