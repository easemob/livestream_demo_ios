//
//  ELDUserHeaderView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//


#import "ELDUserHeaderView.h"

@interface ELDUserHeaderView ()
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, assign) BOOL isEditable;

@end


@implementation ELDUserHeaderView
#pragma mark life cycle
- (instancetype)initWithFrame:(CGRect)frame
                   isEditable:(BOOL)isEditable {
    self = [super initWithFrame:frame];
    if (self) {
        self.isEditable = isEditable;
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    self.backgroundColor = ViewControllerBgBlackColor;
    
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
        
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kEaseLiveDemoPadding * 2.4);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(kMeHeaderImageViewHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(kEaseLiveDemoPadding * 1.2);
        make.left.equalTo(self).offset(kEaseLiveDemoPadding * 10);
        make.right.equalTo(self).offset(-kEaseLiveDemoPadding * 10);
        make.bottom.equalTo(self).offset(-kEaseLiveDemoPadding);
    }];
    
    if (self.isEditable) {
        [self addSubview:self.alphaView];
        [self.alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.avatarImageView);
            make.size.equalTo(self.avatarImageView);
        }];
    }

}

- (void)tapHeaderViewAction {
    if (self.tapHeaderViewBlock) {
        self.tapHeaderViewBlock();
    }
}


#pragma mark getter and setter
- (UIImageView *)photoImageView {
    if (_photoImageView == nil) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _photoImageView.image = ImageWithName(@"photo_icon");
    }
    return _photoImageView;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = kMeHeaderImageViewHeight * 0.5;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.image = kDefultUserImage;
    }
    return _avatarImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textColor = COLOR_HEX(0xFFFFFF);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = @"agoraChat";
    }
    return _nameLabel;
}


- (UIView *)alphaView {
    if (_alphaView == nil) {
        _alphaView = [[UIView alloc] init];
        _alphaView.backgroundColor = ViewControllerBgBlackColor;
        _alphaView.alpha = 0.5;
        _alphaView.layer.cornerRadius = kMeHeaderImageViewHeight * 0.5;
        _alphaView.layer.masksToBounds = YES;
        _alphaView.clipsToBounds = YES;

        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderViewAction)];
        [_alphaView addGestureRecognizer:tap];
        
        [_alphaView addSubview:self.photoImageView];
        
        [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_alphaView);
            make.centerY.equalTo(_alphaView);
        }];
    }
    return _alphaView;
}


@end

