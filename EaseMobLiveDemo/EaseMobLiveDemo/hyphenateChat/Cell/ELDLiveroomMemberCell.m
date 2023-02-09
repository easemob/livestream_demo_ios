//
//  ELDLiveroomMemberCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLiveroomMemberCell.h"
@interface ELDLiveroomMemberCell ()
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) EMUserInfo *userInfo;
@property (nonatomic, assign) BOOL hasRoleIcon;
@property (nonatomic, assign) BOOL hasMuteIcon;

@end



@implementation ELDLiveroomMemberCell

- (void)prepare {
    
    self.nameLabel.textColor = COLOR_HEX(0x0D0D0D);
    self.nameLabel.font = Font(@"Roboto", 14.0);
    self.iconImageView.layer.cornerRadius = kContactAvatarHeight * 0.5;
    
    self.contentView.backgroundColor = UIColor.whiteColor;

    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
}


- (void)placeSubViews {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12.0f);
        make.size.mas_equalTo(kContactAvatarHeight);
    }];
}


- (void)updateWithObj:(id)obj {
    self.userInfo = (EMUserInfo *)obj;
  
    [self.roleImageView removeFromSuperview];
    [self.muteImageView removeFromSuperview];
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:kDefultUserImage];
    
    self.nameLabel.text = self.userInfo.nickName ?: self.userInfo.userId;

    if ([self.userInfo.userId isEqualToString:self.chatroom.owner]) {
        [self.roleImageView setImage:ImageWithName(NSLocalizedString(@"live.streamer.imageName",nil))];
        self.hasRoleIcon = YES;
    }else if ([self.chatroom.adminList containsObject:self.userInfo.userId]){
        [self.roleImageView setImage:ImageWithName(NSLocalizedString(@"live.moderator.imageName",nil))];
        self.hasRoleIcon = YES;
    }else {
        [self.roleImageView setImage:ImageWithName(@"")];
        self.hasRoleIcon = NO;
    }
    
    
    if ([self.chatroom.muteList containsObject:self.userInfo.userId]) {
        self.hasMuteIcon = YES;
    }else {
        self.hasMuteIcon = NO;
    }
    
    if (self.hasRoleIcon && self.hasMuteIcon) {
        [self.contentView addSubview:self.roleImageView];
        [self.contentView addSubview:self.muteImageView];
                
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.mas_right).offset(16.0);
            make.right.equalTo(self.roleImageView.mas_left).offset(-8.0);
        }];
        
        [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.width.equalTo(@(60.0));
            make.height.equalTo(@(16.0));
            make.right.equalTo(self.muteImageView.mas_left).offset(-8.0);
        }];
        
        
        [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.size.equalTo(@(20.0));
            make.right.lessThanOrEqualTo(self.contentView).offset(-12.0);
        }];
        
    }else if(self.hasRoleIcon) {
        [self.contentView addSubview:self.roleImageView];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.mas_right).offset(16.0);
            make.right.equalTo(self.roleImageView.mas_left).offset(-8.0);
        }];

        [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.width.equalTo(@(60.0));
            make.height.equalTo(@(16.0));
            make.right.lessThanOrEqualTo(self.contentView).offset(-12.0);
        }];
        
    }else if (self.hasMuteIcon) {
        [self.contentView addSubview:self.muteImageView];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.mas_right).offset(16.0);
        }];
        
        [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.size.equalTo(@(20.0));
            make.left.equalTo(self.nameLabel.mas_right).offset(8.0);
            make.right.lessThanOrEqualTo(self.contentView).offset(-12.0);
        }];
        
    }else {
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImageView);
            make.left.equalTo(self.iconImageView.mas_right).offset(16.0);
            make.right.equalTo(self).offset(-12.0);
        }];
    }
    
}

+ (CGFloat)height {
    return 54.0;
}

#pragma mark getter and setter
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



@end
