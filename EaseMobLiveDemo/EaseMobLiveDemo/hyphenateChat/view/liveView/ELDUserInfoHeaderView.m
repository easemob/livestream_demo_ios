//
//  ELDUserInfoHeaderView.m
//  EaseMobLiveDemo
//
//  Created by liang on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDUserInfoHeaderView.h"
#import "ELDGenderView.h"

typedef NS_ENUM(NSInteger, ELDImageLayoutStyle) {
    ELDImageLayoutStyleNone,
    ELDImageLayoutStyleRole,
    ELDImageLayoutStyleMute,
    ELDImageLayoutStyleRoleAndMute
};

#define kBgImageViewHeight  (kUserInfoHeaderImageHeight + 2 * 2)


@interface ELDUserInfoHeaderView ()
@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, strong) UIView *bgContentView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIView *avatarBgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ELDGenderView *genderView;
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) EMUserInfo *userInfo;
@property (nonatomic, assign) ELDImageLayoutStyle imageLayoutStyle;


@end

@implementation ELDUserInfoHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageLayoutStyle = ELDImageLayoutStyleNone;
        [self placeAndlayoutSubviews];
    }
    return self;
}

- (void)placeAndlayoutSubviews {
      self.backgroundColor = UIColor.clearColor;
//      self.backgroundColor = UIColor.blueColor;

        [self addSubview:self.alphaView];
        [self addSubview:self.bgContentView];

        [self.alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kBgImageViewHeight * 0.5);
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(20.0);
        }];
    
}

- (void)updateUIWithUserInfo:(EMUserInfo *)userInfo
                    roleType:(ELDMemberRoleType)roleType
                      isMute:(BOOL)isMute {
    self.userInfo = userInfo;
    self.roleType = roleType;
    self.isMute = isMute;
    
    [self.roleImageView removeFromSuperview];
    [self.muteImageView removeFromSuperview];
    
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:kDefultUserImage];
    self.nameLabel.text = self.userInfo.nickname ?:self.userInfo.userId;
    [self.genderView updateWithGender:self.userInfo.gender birthday:self.userInfo.birth];
    
    
    self.roleImageView.hidden = self.roleType == ELDMemberRoleTypeMember ? YES :NO;
    self.muteImageView.hidden = !self.isMute;

    if (self.roleType == ELDMemberRoleTypeMember) {
        if (self.isMute) {
            self.imageLayoutStyle = ELDImageLayoutStyleMute;
        }
    }else {
        if (self.roleType == ELDMemberRoleTypeOwner) {
            [self.roleImageView setImage:ImageWithName(NSLocalizedString(@"live.streamer.imageName",nil))];
            self.imageLayoutStyle = ELDImageLayoutStyleRole;
        }else {
            [self.roleImageView setImage:ImageWithName(NSLocalizedString(@"live.moderator.imageName",nil))];
    
            if (self.isMute) {
                self.imageLayoutStyle = ELDImageLayoutStyleRoleAndMute;
            }else {
                self.imageLayoutStyle = ELDImageLayoutStyleRole;
            }
        }
    }
    
    
    if (self.imageLayoutStyle == ELDImageLayoutStyleRoleAndMute) {
        [self.bgContentView addSubview:self.roleImageView];
        [self.bgContentView addSubview:self.muteImageView];

        [self.roleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5.0);
            make.centerX.equalTo(self.avatarImageView.mas_centerX).offset(-kEaseLiveDemoPadding);
            make.width.equalTo(@(60.0));
            make.height.equalTo(@(16.0));
        }];
        
        [self.muteImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.roleImageView);
            make.left.equalTo(self.roleImageView.mas_right).offset(5.0);
            make.size.equalTo(@(16.0));
        }];
        
    }else if(self.imageLayoutStyle == ELDImageLayoutStyleRole) {
        [self.bgContentView addSubview:self.roleImageView];

        [self.roleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5.0);
            make.centerX.equalTo(self.avatarImageView);
            make.width.equalTo(@(60.0));
            make.height.equalTo(@(16.0));
        }];
    }else if(self.imageLayoutStyle == ELDImageLayoutStyleMute){
        [self.bgContentView addSubview:self.muteImageView];

        [self.muteImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(5.0);
            make.centerX.equalTo(self.avatarImageView);
            make.size.equalTo(@(16.0));
        }];
    }else {
        // do nothing for role and mute imageview
    }
    
}


#pragma mark getter and setter
- (UIImageView*)topBgImageView
{
    if (_topBgImageView == nil) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.image = [UIImage imageNamed:@"member_bg_top"];
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.layer.masksToBounds = YES;
    }
    return _topBgImageView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = kUserInfoHeaderImageHeight * 0.5;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.image = kDefultUserImage;
    }
    return _avatarImageView;
}

- (UIView *)avatarBgView {
    if (_avatarBgView == nil) {
        _avatarBgView = [[UIView alloc] init];
        _avatarBgView.backgroundColor = UIColor.whiteColor;
        _avatarBgView.layer.cornerRadius = (kUserInfoHeaderImageHeight + 2 * 2)* 0.5;
        _avatarBgView.clipsToBounds = YES;

        [_avatarBgView addSubview:self.avatarImageView];
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(kUserInfoHeaderImageHeight));
            make.center.equalTo(_avatarBgView);
        }];
    }
    return _avatarBgView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NFont(16.0f);
        _nameLabel.textColor = TextLabelBlackColor;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.text = @"123";
    }
    return _nameLabel;
}


- (ELDGenderView *)genderView {
    if (_genderView == nil) {
        _genderView = [[ELDGenderView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
        _genderView.layer.cornerRadius = kGenderViewHeight * 0.5;
        _genderView.clipsToBounds = YES;
        [_genderView updateWithGender:2 birthday:@""];
    }
    return _genderView;
}


- (UIImageView *)muteImageView {
    if (_muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] init];
        _muteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_muteImageView setImage:ImageWithName(@"member_mute_icon")];
    }
    return _muteImageView;
}

- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}


- (UIView *)bgContentView {
    if (_bgContentView == nil) {
        _bgContentView = [[UIView alloc] init];
        _bgContentView.backgroundColor = UIColor.whiteColor;
//        _bgContentView.backgroundColor = UIColor.yellowColor;
        _bgContentView.layer.cornerRadius = 12.0;
        
        [_bgContentView addSubview:self.avatarBgView];
        [_bgContentView addSubview:self.nameLabel];
        [_bgContentView addSubview:self.genderView];
      
        [self.avatarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bgContentView).offset(-kBgImageViewHeight*0.5);
            make.centerX.equalTo(_bgContentView);
            make.size.equalTo(@(kBgImageViewHeight));
        }];

        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarBgView.mas_bottom).offset(15.0f);
            make.centerX.equalTo(self.avatarBgView).offset(-kEaseLiveDemoPadding);
            make.width.mas_lessThanOrEqualTo(self.frame.size.width *0.4);
            make.height.equalTo(@(kGenderViewHeight));
        }];

        [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
            make.width.equalTo(@(kGenderViewWidth));
            make.height.equalTo(@(kGenderViewHeight));
        }];

    }
    return _bgContentView;
}

- (UIView *)alphaView {
    if (_alphaView == nil) {
        _alphaView = [[UIView alloc] init];
        _alphaView.backgroundColor = UIColor.blackColor;
        _alphaView.alpha = 0.01;
    }
    return _alphaView;
}

@end


#undef kBgImageViewHeight
