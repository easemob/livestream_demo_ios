//
//  EaseAnchorView.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/17.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseAnchorCardView.h"

@interface EaseAnchorCardView ()
{
    EaseLiveRoom *_room;
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UILabel *giftLabel;
@property (nonatomic, strong) UILabel *fansLabel;

@end

@implementation EaseAnchorCardView

- (instancetype)initWithLiveRoom:(EaseLiveRoom *)room
{
    self = [super init];
    if (self) {
        _room = room;
        [self _setupSubviews];
    }
    return self;
}


- (void)_setupSubviews
{
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@180);
        make.center.equalTo(self);
        make.width.equalTo(@280);
    }];
    
    [bgView addSubview:self.headImageView];
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@60);
        make.top.equalTo(bgView.mas_top).offset(30);
        make.left.equalTo(bgView).offset(55);
    }];
    
    [bgView addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@60);
        make.top.equalTo(bgView.mas_top).offset(30);
        make.right.equalTo(bgView).offset(-55);
    }];
    
    [bgView addSubview:self.fansLabel];
    [_fansLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.top.equalTo(_headImageView.mas_bottom).offset(15);
        make.left.equalTo(bgView).offset(40);
    }];
    
    [bgView addSubview:self.giftLabel];
    [_giftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.top.equalTo(_headImageView.mas_bottom).offset(15);
        make.left.equalTo(self.fansLabel.mas_right).offset(10);
    }];
    
    [bgView addSubview:self.praiseLabel];
    [_praiseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.top.equalTo(_headImageView.mas_bottom).offset(15);
        make.left.equalTo(self.giftLabel.mas_right).offset(10);
    }];
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.image = [UIImage imageNamed:@"live_default_user"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = CGRectGetHeight(_headImageView.frame)/2;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        if (_room) {
            _nameLabel.text = _room.session.anchor;
        }
    }
    return _nameLabel;
}

- (UILabel*)praiseLabel
{
    if (_praiseLabel == nil) {
        _praiseLabel = [[UILabel alloc] init];
        _praiseLabel.font = [UIFont systemFontOfSize:14.f];
        _praiseLabel.textColor = [UIColor blackColor];
        _praiseLabel.text = @"赞:900";
    }
    return _praiseLabel;
}

- (UILabel*)giftLabel
{
    if (_giftLabel == nil) {
        _giftLabel = [[UILabel alloc] init];
        _giftLabel.font = [UIFont systemFontOfSize:14.f];
        _giftLabel.textColor = [UIColor blackColor];
        _giftLabel.text = @"礼物:900";
    }
    return _giftLabel;
}

- (UILabel*)fansLabel
{
    if (_fansLabel == nil) {
        _fansLabel = [[UILabel alloc] init];
        _fansLabel.font = [UIFont systemFontOfSize:14.f];
        _fansLabel.textColor = [UIColor blackColor];
        _fansLabel.text = @"粉丝:200";
    }
    return _fansLabel;
}

@end
