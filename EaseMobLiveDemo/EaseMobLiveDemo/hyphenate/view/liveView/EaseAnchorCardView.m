//
//  EaseAnchorView.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/17.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseAnchorCardView.h"
#import "EaseDefaultDataHelper.h"

@interface EaseAnchorCardView ()
{
    EaseLiveRoom *_room;
    BOOL _attention; //关注
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UILabel *giftLabel;
@property (nonatomic, strong) UILabel *fansLabel;
@property (nonatomic, strong) UIButton *attentionBtn;
@property (nonatomic, strong) UILabel *attentionLabel;
@property (nonatomic, strong) UIImageView *attentionImg;

@property (nonatomic, strong) CAGradientLayer *attentionGl;

@end

@implementation EaseAnchorCardView

- (instancetype)initWithLiveRoom:(EaseLiveRoom *)room
{
    self = [super init];
    if (self) {
        _room = room;
        _attention = false;
        [self _setupSubviews];
        [self _setviewData];
    }
    return self;
}


- (void)_setupSubviews
{
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@180);
        make.center.equalTo(self);
        make.width.equalTo(@280);
    }];
    
    [bgView addSubview:self.headImageView];
    [_headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@80);
        make.top.equalTo(bgView.mas_top).offset(-40);
        make.centerX.equalTo(bgView);
    }];
    
    [bgView addSubview:self.nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@100);
        make.height.equalTo(@30);
        make.top.equalTo(_headImageView.mas_bottom).offset(10);
        make.centerX.equalTo(bgView);
    }];
    
    [bgView addSubview:self.fansLabel];
    [_fansLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.top.equalTo(_nameLabel.mas_bottom).offset(10);
        make.left.equalTo(bgView).offset(40);
    }];
    
    [bgView addSubview:self.giftLabel];
    [_giftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.top.equalTo(_nameLabel.mas_bottom).offset(10);
        make.centerX.equalTo(bgView);
    }];
    
    [bgView addSubview:self.praiseLabel];
    [_praiseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.top.equalTo(_nameLabel.mas_bottom).offset(10);
        make.right.equalTo(bgView).offset(-40);
    }];
    
    NSLog(@"%@", EMClient.sharedClient.currentUsername);
    if (![_room.anchor isEqualToString:EMClient.sharedClient.currentUsername]) {
        [bgView addSubview:self.attentionBtn];
        [_attentionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@120);
            make.height.equalTo(@35);
            make.centerX.equalTo(bgView.mas_centerX);
            make.bottom.equalTo(bgView.mas_bottom).offset(-15);
        }];
    }
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = CGRectGetHeight(_headImageView.frame)/2;
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
        _headImageView.layer.cornerRadius = 40;
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel*)praiseLabel
{
    if (_praiseLabel == nil) {
        _praiseLabel = [[UILabel alloc] init];
        _praiseLabel.font = [UIFont systemFontOfSize:14.f];
        _praiseLabel.textColor = [UIColor blackColor];
        _praiseLabel.textAlignment = NSTextAlignmentCenter;
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
        _giftLabel.textAlignment = NSTextAlignmentCenter;
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
        _fansLabel.textAlignment = NSTextAlignmentCenter;
        _fansLabel.text = @"粉丝:200";
    }
    return _fansLabel;
}

- (UIButton *)attentionBtn
{
    if (_attentionBtn == nil) {
        _attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _attentionBtn.layer.cornerRadius = 17.5;
        _attentionBtn.backgroundColor = [UIColor clearColor];
        [_attentionBtn.layer addSublayer:self.attentionGl];
        [_attentionBtn addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_attentionBtn addSubview:self.attentionImg];
        [_attentionImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.top.equalTo(_attentionBtn.mas_top).offset(7.5);
            make.right.equalTo(_attentionBtn.mas_centerX).offset(-15);
        }];
        [_attentionImg setImage:[UIImage imageNamed:@"Icons-Plus-white"]];

        [_attentionBtn addSubview:self.attentionLabel];
        [_attentionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@30);
            make.top.equalTo(_attentionBtn.mas_top).offset(2.5);
            make.left.equalTo(_attentionBtn.mas_centerX).offset(-5);
        }];
    }
    return _attentionBtn;
}

- (UIImageView *)attentionImg
{
    if (_attentionImg == nil) {
        _attentionImg = [[UIImageView alloc]init];
    }
    return _attentionImg;
}

- (UILabel *)attentionLabel
{
    if (_attentionLabel == nil) {
        _attentionLabel = [[UILabel alloc] init];
        _attentionLabel.font = [UIFont systemFontOfSize:18.f];
        _attentionLabel.textColor = [UIColor whiteColor];
        _attentionLabel.text = @"关 注";
        _attentionLabel.textAlignment = NSTextAlignmentLeft;
       }
    return _attentionLabel;
}

- (CAGradientLayer *)attentionGl{
    if(_attentionGl == nil){
        _attentionGl = [CAGradientLayer layer];
        _attentionGl.frame = CGRectMake(0,0,120,35);
        _attentionGl.startPoint = CGPointMake(0.76, 0.84);
        _attentionGl.endPoint = CGPointMake(0.26, 0.14);
        _attentionGl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor];
        _attentionGl.locations = @[@(0), @(1.0f)];
        _attentionGl.cornerRadius = 17.5;
    }
    
    return _attentionGl;
}

- (void)_setviewData
{
    extern NSMutableDictionary *anchorInfoDic;
    if (_room) {
        if ([_room.anchor isEqualToString:EMClient.sharedClient.currentUsername]) {
            _nameLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
            _headImageView.image = [UIImage imageNamed:@"default_anchor_avatar"];
        } else {
            NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:_room.roomId];
            _nameLabel.text = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
            _headImageView.image = [UIImage imageNamed:[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_AVATAR]];
        }
    }
}

#pragma Action
- (void)attentionAction
{
    if (!_attention) {
        self.attentionLabel.text = @"已关注";
        self.attentionLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self.attentionImg setImage:[UIImage imageNamed:@"attention"]];
        _attention = true;
        [self.attentionGl removeFromSuperlayer];
    } else {
        self.attentionLabel.text = @"关 注";
        self.attentionLabel.textColor = [UIColor whiteColor];
        [self.attentionImg setImage:[UIImage imageNamed:@"Icons-Plus-white"]];
        _attention = false;
        [self.attentionBtn.layer insertSublayer:self.attentionGl atIndex:0];
    }
}

@end
