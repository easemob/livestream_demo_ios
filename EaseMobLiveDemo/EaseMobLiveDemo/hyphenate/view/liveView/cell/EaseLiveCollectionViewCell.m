//
//  EaseCollectionViewCell.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCollectionViewCell.h"

#import "EaseLiveRoom.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Masonry.h"

#define kLabelDefaultHeight 22.f
#define kCellSpace 5.f

@interface EaseLiveCollectionViewCell ()
{
    BOOL isBroadcasting; //房间是否正直播
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UIView *broadcastView;
@property (nonatomic, strong) UIView *liveFooter;
@property (nonatomic, strong) UIView *liveHeader;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIView *studioOccupancy;//直播间正直播

@property (nonatomic, strong) CAGradientLayer *livingGl;
@property (nonatomic, strong) CAGradientLayer *broadcastGl;

@end

@implementation EaseLiveCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.liveImageView];
        [self.liveImageView addSubview:self.liveHeader];
        [self.liveImageView addSubview:self.liveFooter];
        [self.liveImageView addSubview:self.studioOccupancy];//正在直播
        [self.liveImageView addSubview:self.broadcastView];//开播
        [self.liveFooter addSubview:self.textLable];
        [self.liveFooter addSubview:self.numLabel];
        [self.liveFooter addSubview:self.descLabel];
    }
    return self;
}

- (UILabel*)textLable
{
    if (_textLable == nil) {
        _textLable = [[UILabel alloc] init];
        _textLable.frame = CGRectMake(8.f, 0, CGRectGetWidth(self.frame)/2, 14.f);
        _textLable.font = [UIFont systemFontOfSize:15.f];
        _textLable.textColor = [UIColor whiteColor];
        _textLable.textAlignment = NSTextAlignmentLeft;
        _textLable.layer.masksToBounds = YES;
        _textLable.shadowColor = [UIColor blackColor];
        _textLable.shadowOffset = CGSizeMake(1, 1);
        
    }
    return _textLable;
}

- (UILabel*)numLabel
{
    if (_numLabel == nil) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 55.f, 2.f, 15.f, 12.f);
        _numLabel.font = [UIFont systemFontOfSize:14.f];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.textAlignment = NSTextAlignmentLeft;
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.shadowColor = [UIColor blackColor];
        _numLabel.shadowOffset = CGSizeMake(1, 1);
    }
    return _numLabel;
}

- (UILabel *)descLabel
{
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 40.f, 2.f, 35.f, 12.f);
        _descLabel.font = [UIFont systemFontOfSize:10.f];
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.textAlignment = NSTextAlignmentRight;
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.shadowColor = [UIColor blackColor];
        _descLabel.shadowOffset = CGSizeMake(1, 1);
        _descLabel.text = @"正在看";
    }
    return _descLabel;
}

- (UILabel*)statusLabel
{
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:12.f];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.textAlignment = NSTextAlignmentLeft;
        _statusLabel.shadowColor = [UIColor blackColor];
        _statusLabel.shadowOffset = CGSizeMake(1, 1);
        _statusLabel.text = @"正在直播";
    }
    return _statusLabel;
}

- (UIView*)liveFooter
{
    if (_liveFooter == nil) {
        _liveFooter = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kLabelDefaultHeight, CGRectGetWidth(self.frame), kLabelDefaultHeight)];
        _liveFooter.backgroundColor = [UIColor clearColor];
    }
    return _liveFooter;
}

- (UIView*)liveHeader
{
    if (_liveHeader == nil) {
        _liveHeader = [[UIView alloc] initWithFrame:CGRectMake(8.f, 8.f, 75.f, 18.f)];
        _liveHeader.backgroundColor = [UIColor clearColor];
        _liveHeader.layer.cornerRadius = 9;
        [_liveHeader.layer addSublayer:self.livingGl];
        [_liveHeader addSubview:self.headImageView];
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@12.f);
            make.left.equalTo(_liveHeader.mas_left).offset(3.f);
            make.top.equalTo(_liveHeader.mas_top).offset(3.f);
        }];
        [_liveHeader addSubview:self.statusLabel];
        [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60.f);
            make.height.equalTo(@18.f);
            make.left.equalTo(self.headImageView.mas_right).offset(5.f);
            make.top.equalTo(_liveHeader.mas_top);
        }];
    }
    return _liveHeader;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-living"]];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}

- (UIImageView*)liveImageView
{
    if (_liveImageView == nil) {
        _liveImageView = [[UIImageView alloc] init];
        _liveImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _liveImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveImageView.layer.masksToBounds = YES;
        _liveImageView.backgroundColor = RGBACOLOR(200, 200, 200, 1);
    }
    return _liveImageView;
}

- (UIView*)broadcastView
{
    if (_broadcastView == nil) {
        _broadcastView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width / 2.f - 55, self.frame.size.height / 2.f - 17.5, 110.f, 35.f)];
        _broadcastView.layer.cornerRadius = 17;
        [_broadcastView.layer addSublayer:self.broadcastGl];
        _broadcastView.backgroundColor = [UIColor clearColor];
        UIImageView *broadcastImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-broadcast"]];
        broadcastImg.contentMode = UIViewContentModeScaleAspectFill;
        broadcastImg.layer.masksToBounds = YES;
        [_broadcastView addSubview:broadcastImg];
        [broadcastImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@13.f);
            make.height.equalTo(@15.f);
            make.left.equalTo(_broadcastView.mas_left).offset(10.f);
            make.top.equalTo(_broadcastView.mas_top).offset(10.f);
        }];
        UILabel *broadcastLabel = [[UILabel alloc]init];
        broadcastLabel.text = @"立即开播";
        broadcastLabel.textColor = [UIColor whiteColor];
        broadcastLabel.font = [UIFont systemFontOfSize:16.f];
        [_broadcastView addSubview:broadcastLabel];
        [broadcastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@70);
            make.height.equalTo(@20);
            make.right.equalTo(_broadcastView.mas_right).offset(-7.5);
            make.top.equalTo(_broadcastView.mas_top).offset(7.5);
        }];
    }
    return _broadcastView;
}

- (UIView *)studioOccupancy
{
    if (_studioOccupancy == nil) {
        _studioOccupancy = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _studioOccupancy.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.34];
        UILabel *broadcastingTag = [[UILabel alloc]init];
        broadcastingTag.text = @"主播在播不能选择";
        broadcastingTag.lineBreakMode = NSLineBreakByTruncatingTail;
        broadcastingTag.numberOfLines = 2;
        broadcastingTag.font = [UIFont systemFontOfSize:12.f];
        broadcastingTag.textColor = [UIColor whiteColor];
        broadcastingTag.textAlignment = NSTextAlignmentCenter;
        broadcastingTag.layer.borderWidth = 2;
        broadcastingTag.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor;
        broadcastingTag.layer.cornerRadius = 12.5;
        [_studioOccupancy addSubview:broadcastingTag];
        [broadcastingTag mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@40);
            make.center.equalTo(_studioOccupancy);
        }];
    }
    return _studioOccupancy;
}

- (CAGradientLayer *)livingGl{
    if(_livingGl == nil){
        _livingGl = [CAGradientLayer layer];
        _livingGl.frame = CGRectMake(0,0,_liveHeader.frame.size.width,_liveHeader.frame.size.height);
        _livingGl.startPoint = CGPointMake(0.76, 0.84);
        _livingGl.endPoint = CGPointMake(0.26, 0.14);
        _livingGl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor];
        _livingGl.locations = @[@(0), @(1.0f)];
        _livingGl.cornerRadius = 9;
    }
    
    return _livingGl;
}

- (CAGradientLayer *)broadcastGl{
    if(_broadcastGl == nil){
        _broadcastGl = [CAGradientLayer layer];
        _broadcastGl.frame = CGRectMake(0,0,_broadcastView.frame.size.width,_broadcastView.frame.size.height);
        _broadcastGl.startPoint = CGPointMake(0.76, 0.84);
        _broadcastGl.endPoint = CGPointMake(0.26, 0.1);
        _broadcastGl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:208/255.0 blue:130/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:239/255.0 blue:240/255.0 alpha:1.0].CGColor];
        _broadcastGl.locations = @[@(0), @(1.0f)];
        _broadcastGl.cornerRadius = 17;
    }
    return _broadcastGl;
}

- (void)setLiveRoom:(EaseLiveRoom*)room liveBehavior:(kTabbarItemBehavior)liveBehavior
{
    _textLable.text = room.title;
    if (room.coverPictureUrl.length > 0) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:room.coverPictureUrl];
        if (image) {
            _liveImageView.image = image;
        } else {
            _liveImageView.image = [UIImage imageNamed:@"default_image"];
        }
    } else {
        _liveImageView.image = [UIImage imageNamed:@"default_image"];
    }
    _numLabel.text = [NSString stringWithFormat:@"%ld",(long)room.currentUserCount];
    //判断房间状态
    if (liveBehavior == kTabbarItemTag_Live) {
        self.studioOccupancy.hidden = YES;
        self.broadcastView.hidden = YES;
    } else if (liveBehavior == kTabbarItemTag_Broadcast) {
        self.liveHeader.hidden = YES;
        if (room.status == ongoing) {
            self.studioOccupancy.hidden = NO;
            self.broadcastView.hidden = YES;
            self.liveFooter.hidden = NO;
            self.userInteractionEnabled = NO;
        } else if (room.status == offline) {
            self.studioOccupancy.hidden = YES;
            self.broadcastView.hidden = NO;
            self.liveFooter.hidden = YES;
            self.userInteractionEnabled = YES;
        }
    }
}

@end
