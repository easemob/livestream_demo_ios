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
#import "EaseDefaultDataHelper.h"

@interface EaseLiveCastView ()
{
    EaseLiveRoom *_room;
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
//@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *praiseLabel;
@property (nonatomic, strong) UILabel *giftLabel;

@end

extern NSArray<NSString*> *nickNameArray;
extern NSMutableDictionary *anchorInfoDic;

@implementation EaseLiveCastView

- (instancetype)initWithFrame:(CGRect)frame room:(EaseLiveRoom*)room
{
    self = [super initWithFrame:frame];
    if (self) {
        _room = room;
        self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.25];
        self.layer.cornerRadius = frame.size.height / 2;
        [self addSubview:self.headImageView];
        [self addSubview:self.nameLabel];
        if ([_room.anchor isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self addSubview:self.praiseLabel];
            [self addSubview:self.giftLabel];
        }
        [self _setviewData];
        //[self addSubview:self.numberLabel];
    }
    return self;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(2, 2, self.height - 4, self.height - 4);
        _headImageView.image = [UIImage imageNamed:@"Logo"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = (self.height - 4)/2;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHeadImage)];
        _headImageView.userInteractionEnabled = YES;
        [_headImageView addGestureRecognizer:tap];
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(_headImageView.width + 10.f, self.height / 4, self.width - (_headImageView.width + 10.f), self.height/2);
        _nameLabel.font = [UIFont systemFontOfSize:14.f];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)praiseLabel
{
    if (_praiseLabel == nil) {
        _praiseLabel = [[UILabel alloc] init];
        _praiseLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.height + 5, self.width / 2, self.height / 2);
        _praiseLabel.font = [UIFont systemFontOfSize:12.f];
        _praiseLabel.textColor = [UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:1.0];
        _praiseLabel.text = [NSString stringWithFormat:@"赞:%d",[EaseDefaultDataHelper.shared.praiseStatisticstCount intValue]];
        _praiseLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _praiseLabel;
}

- (UILabel*)giftLabel
{
    if (_giftLabel == nil) {
        _giftLabel = [[UILabel alloc] init];
        _giftLabel.frame = CGRectMake(self.frame.origin.x + _praiseLabel.width, self.frame.origin.y + self.height + 5, self.width / 2, self.height / 2);
        _giftLabel.font = [UIFont systemFontOfSize:12.f];
        _giftLabel.textColor = [UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:1.0];
        _giftLabel.text = [NSString stringWithFormat:@"礼物:%d",[EaseDefaultDataHelper.shared.giftNumbers intValue]];
        _giftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _giftLabel;
}

- (void)_setviewData
{
    extern NSArray<NSString*>*nickNameArray;
    if (_room) {
        if ([_room.anchor isEqualToString:EMClient.sharedClient.currentUsername]) {
            if (![EaseDefaultDataHelper.shared.defaultNickname isEqualToString:@""]) {
                _nameLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
            } else {
                int random = (arc4random() % 100);
                EaseDefaultDataHelper.shared.defaultNickname = nickNameArray[random];
                [EaseDefaultDataHelper.shared archive];
                _nameLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
            }
        } else {
            NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:_room.roomId];
            if (anchorInfo && [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] && ![[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] isEqualToString:@""]) {
                _nameLabel.text = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
            } else {
                anchorInfo = [[NSMutableDictionary alloc]initWithCapacity:3];
                [anchorInfo setObject:_room.anchor forKey:kBROADCASTING_CURRENT_ANCHOR];//当前房间主播
                int random = (arc4random() % 100);
                NSString *randomNickname = nickNameArray[random];
                _nameLabel.text = randomNickname;
                [anchorInfo setObject:_nameLabel.text forKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];//当前房间主播昵称
                random = (arc4random() % 7) + 1;
                [anchorInfo setObject:[NSString stringWithFormat:@"avatat_%d",random] forKey:kBROADCASTING_CURRENT_ANCHOR_AVATAR];//当前房间主播头像
                [anchorInfoDic setObject:anchorInfo forKey:_room.roomId];
            }
        }
    }
}

/*
- (UILabel*)numberLabel
{
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.frame = CGRectMake(_headImageView.width + 10.f, self.height/2, self.width - (_headImageView.width + 10.f), self.height/2);
        _numberLabel.font = [UIFont systemFontOfSize:12.f];
        _numberLabel.textColor = [UIColor whiteColor];
    }
    return _numberLabel;
}*/

#pragma mark - action
- (void)didSelectHeadImage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAnchorCard:)]) {
        [self.delegate didClickAnchorCard:_room];
    }
}

#pragma mark - public

- (void)setNumberOfPraise:(NSInteger)number
{
    _praiseLabel.text = [NSString stringWithFormat:@"赞：%ld",(long)number];
}

- (void)setNumberOfGift:(NSInteger)number
{
    _giftLabel.text = [NSString stringWithFormat:@"礼物：%ld",(long)number];
}

@end
