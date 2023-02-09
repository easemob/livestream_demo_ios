//
//  EaseLiveCastView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/26.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCastView.h"
#import "EaseLiveRoom.h"
#import "EaseDefaultDataHelper.h"
#import <Masonry/Masonry.h>
#import "ELDGenderView.h"


@interface EaseLiveCastView ()
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UILabel *giftValuesLabel;
@property (nonatomic, strong) ELDGenderView *genderView;
@property (nonatomic, strong) UIImageView *giftIconImageView;
@property (nonatomic, strong) EMUserInfo *userInfo;


@end


@implementation EaseLiveCastView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.height / 2;
        [self placeAndlayoutSubviews];
        [self addTapGesture];
        
    }
    return self;
}

- (void)addTapGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHeadImage)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
}


- (void)placeAndlayoutSubviews {

    [self addSubview:self.headImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.genderView];
    [self addSubview:self.giftIconImageView];
    [self addSubview:self.giftValuesLabel];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(2.0);
        make.size.equalTo(@32.0);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(4.0);
        make.left.equalTo(self.headImageView.mas_right).offset(kEaseLiveDemoPadding);
        make.width.lessThanOrEqualTo(@80.0);
        make.height.equalTo(@16.0);
    }];

    [self.genderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
        make.right.equalTo(self).offset(-8.0);
        make.width.equalTo(@(kGenderViewWidth));
        make.height.equalTo(@(kGenderViewHeight));
    }];

    [self.giftIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-4.0);
        make.left.equalTo(self.nameLabel);
        make.size.equalTo(@10.0);
    }];
    
    [self.giftValuesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.giftIconImageView.mas_right).offset(5.0);
        make.centerY.equalTo(self.giftIconImageView);
        make.right.equalTo(self.genderView);
    }];
}


- (void)updateUIWithUserInfo:(EMUserInfo *)userInfo {
    if (userInfo) {
        self.userInfo = userInfo;
        self.nameLabel.text = userInfo.nickname ?:userInfo.userId;
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:kDefultUserImage];
        [self.genderView updateWithGender:userInfo.gender birthday:userInfo.birth];
    }
}


#pragma mark getter and setter
- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(2, 2, self.height - 4, self.height - 4);
        _headImageView.image = kDefultUserImage;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = (self.height - 4)/2;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}


- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(_headImageView.width + 10.f, self.height / 4, self.width - (_headImageView.width + 10.f), self.height/2);
        _nameLabel.font = BFont(12.0f);
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)praiseLabel
{
    if (_praiseLabel == nil) {
        _praiseLabel = [[UILabel alloc] init];
        _praiseLabel.font = [UIFont systemFontOfSize:12.f];
        _praiseLabel.textColor = [UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:1.0];
        _praiseLabel.text = [NSString stringWithFormat:NSLocalizedString(@"like.number", nil),[EaseDefaultDataHelper.shared.praiseStatisticstCount intValue]];
        _praiseLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _praiseLabel;
}

- (UILabel*)giftValuesLabel
{
    if (_giftValuesLabel == nil) {
        _giftValuesLabel = [[UILabel alloc] init];
        _giftValuesLabel.font = [UIFont systemFontOfSize:10.0f];
        _giftValuesLabel.textColor = [UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:0.74];
        _giftValuesLabel.text = @"8,420";
        _giftValuesLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _giftValuesLabel;
}

- (ELDGenderView *)genderView {
    if (_genderView == nil) {
        _genderView = [[ELDGenderView alloc] initWithFrame:CGRectZero];
        _genderView.layer.cornerRadius = kGenderViewHeight * 0.5;
        _genderView.clipsToBounds = YES;
    }
    return _genderView;
}

- (UIImageView *)giftIconImageView {
    if (_giftIconImageView == nil) {
        _giftIconImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"receive_gift_icon")];
        _giftIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _giftIconImageView.layer.masksToBounds = YES;
    }
    return _giftIconImageView;
}


#pragma mark - action
- (void)didSelectHeadImage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAnchorCard:)]) {
        [self.delegate didClickAnchorCard:self.userInfo];
    }
}



@end
