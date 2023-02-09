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

@property (nonatomic, strong) UIImageView *iconImageView;
//@property (nonatomic, strong) UIImageView *liveWatcherCountBgImageView;
@property (nonatomic, strong) UIView *liveWatcherCountBgView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UIView *broadcastView;
@property (nonatomic, strong) UIView *liveFooterView;
@property (nonatomic, strong) UIView *liveHeaderView;
@property (nonatomic, strong) UILabel *roomTitleLabel;
@property (nonatomic, strong) UILabel *liveroomNameLabel;
@property (nonatomic, strong) UILabel *watchCountLabel;
@property (nonatomic, strong) UILabel *liveStreamerNameLabel;

@property (nonatomic, strong) UIView *studioOccupancy;//直播间正直播

@property (nonatomic, strong) CAGradientLayer *broadcastGl;

@property (nonatomic, strong) UIImageView *liveStreamerImageView;

@end

@implementation EaseLiveCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.liveImageView];
    }
    return self;
}

#pragma mark public method
- (void)setLiveRoom:(EaseLiveRoom*)room liveBehavior:(kTabbarItemBehavior)liveBehavior
{
    self.liveStreamerNameLabel.text = room.anchor;
    self.liveroomNameLabel.text = room.title;
    
    if (room.coverPictureUrl.length > 0) {
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:room.coverPictureUrl];
        if (!image) {
            __weak typeof(self) weakSelf = self;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:room.coverPictureUrl]
              options:SDWebImageDownloaderUseNSURLCache
             progress:NULL
            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                UIImage *backimage = nil;
                NSString *key = nil;
                if (image) {
                    backimage = image;
                    key = room.coverPictureUrl;
                } else {
                    backimage = [UIImage imageNamed:@"default_back_image"];
                    key = @"default_back_image";
                }
                [[SDImageCache sharedImageCache] storeImage:backimage forKey:key toDisk:NO completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.liveImageView.image = backimage;
                    });
                }];
            }];
        } else {
            _liveImageView.image = image;
        }
    } else {
        _liveImageView.image = [UIImage imageNamed:@"default_back_image"];
    }
    
    self.watchCountLabel.text  = [NSString stringWithFormat:@"%ld",(long)room.currentUserCount];

    CGFloat countLabelWidth = [self.watchCountLabel.text sizeWithAttributes:@{
        NSFontAttributeName:self.watchCountLabel.font}].width;

    CGRect frame = self.liveWatcherCountBgView.frame;
    frame.size.width = countLabelWidth + 5.0 + 6.0 + 8.0 + 4.0;
    self.liveWatcherCountBgView.frame = frame;
    
    [self.liveWatcherCountBgView addTransitionColor:[UIColor colorWithRed:255.0/255.0 green:0 blue:0 alpha:1] endColor:[UIColor colorWithRed:128.0/255.0 green:0 blue:255.0/255.0 alpha:1] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
    
    //判断房间状态
    if (liveBehavior == kTabbarItemTag_Live) {
        self.studioOccupancy.hidden = YES;
        self.broadcastView.hidden = YES;
    } else if (liveBehavior == kTabbarItemTag_Broadcast) {
        self.liveHeaderView.hidden = YES;
        if (room.status == ongoing) {
            self.studioOccupancy.hidden = NO;
            self.broadcastView.hidden = YES;
            self.liveFooterView.hidden = NO;
            self.userInteractionEnabled = YES;
        } else if (room.status == offline) {
            self.studioOccupancy.hidden = YES;
            self.broadcastView.hidden = NO;
            self.liveFooterView.hidden = YES;
            self.userInteractionEnabled = YES;
        }
    }
}




#pragma mark getter and setter
- (UILabel*)roomTitleLabel
{
    if (_roomTitleLabel == nil) {
        _roomTitleLabel = [[UILabel alloc] init];
        _roomTitleLabel.frame = CGRectMake(8.f, 0, CGRectGetWidth(self.frame)/2, 14.f);
        _roomTitleLabel.font = [UIFont systemFontOfSize:10.f];
        _roomTitleLabel.textColor = [UIColor whiteColor];
        _roomTitleLabel.textAlignment = NSTextAlignmentLeft;
        _roomTitleLabel.layer.masksToBounds = YES;
        _roomTitleLabel.shadowColor = [UIColor blackColor];
        _roomTitleLabel.shadowOffset = CGSizeMake(1, 1);
    }
    return _roomTitleLabel;
}

- (UILabel*)liveroomNameLabel
{
    if (_liveroomNameLabel == nil) {
        _liveroomNameLabel = [[UILabel alloc] init];
        _liveroomNameLabel.font = NFont(14.0f);
        _liveroomNameLabel.textColor = [UIColor whiteColor];
        _liveroomNameLabel.textAlignment = NSTextAlignmentLeft;
        _liveroomNameLabel.backgroundColor = [UIColor clearColor];
        _liveroomNameLabel.text = @"Chats Casually";
    }
    return _liveroomNameLabel;
}

- (UILabel *)liveStreamerNameLabel
{
    if (_liveStreamerNameLabel == nil) {
        _liveStreamerNameLabel = [[UILabel alloc] init];
        _liveStreamerNameLabel.font = NFont(10.f);
        _liveStreamerNameLabel.textColor = [UIColor whiteColor];
        _liveStreamerNameLabel.textAlignment = NSTextAlignmentLeft;
        _liveStreamerNameLabel.text = @"Paulo Apollo";
    }
    return _liveStreamerNameLabel;
}

- (UILabel*)watchCountLabel
{
    if (_watchCountLabel == nil) {
        _watchCountLabel = [[UILabel alloc] init];
        _watchCountLabel.font = NFont(12.f);
        _watchCountLabel.textColor = [UIColor whiteColor];
        _watchCountLabel.textAlignment = NSTextAlignmentLeft;
        _watchCountLabel.text = @"32K";
    }
    return _watchCountLabel;
}

- (UIView*)liveFooterView
{
    if (_liveFooterView == nil) {
        _liveFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width  , 60.0)];
        _liveFooterView.backgroundColor = [UIColor clearColor];

        [_liveFooterView addTransitionColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] endColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];

        
        [_liveFooterView addSubview:self.liveroomNameLabel];
        [_liveFooterView addSubview:self.liveStreamerImageView];
        [_liveFooterView addSubview:self.liveStreamerNameLabel];

        [self.liveStreamerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.liveFooterView).offset(-kEaseLiveDemoPadding);
            make.left.equalTo(_liveFooterView).offset(kEaseLiveDemoPadding);
        }];

        [self.liveStreamerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.liveStreamerImageView);
            make.left.equalTo(self.liveStreamerImageView.mas_right).offset(kEaseLiveDemoPadding * 0.5);
            make.width.equalTo(@100.0);
            make.height.equalTo(@12);
        }];
        
        [self.liveroomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.liveStreamerImageView.mas_top).offset(-2.0);
            make.left.equalTo(self.liveStreamerImageView);
            make.right.equalTo(_liveFooterView).offset(-kEaseLiveDemoPadding);
        }];
        
    }
    return _liveFooterView;
}


- (UIView*)liveHeaderView
{
    if (_liveHeaderView == nil) {
        _liveHeaderView = [[UIView alloc] init];
        _liveHeaderView.backgroundColor = [UIColor clearColor];
        [_liveHeaderView addSubview:self.liveWatcherCountBgView];
    
        [self.liveWatcherCountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_liveHeaderView).offset(7.0);
            make.left.equalTo(_liveHeaderView).offset(7.0);
            make.height.equalTo(@(14.0));
        }];
        
       
    }
    return _liveHeaderView;
}

- (UIImageView*)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Live_watch"]];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}


//- (UIImageView *)liveWatcherCountBgImageView {
//    if (_liveWatcherCountBgImageView == nil) {
//        _liveWatcherCountBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiveStreamer_watch_bg"]];
//        _liveWatcherCountBgImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _liveWatcherCountBgImageView.layer.masksToBounds = YES;
//    }
//    return _liveWatcherCountBgImageView;
//}

- (UIView *)liveWatcherCountBgView {
    if (_liveWatcherCountBgView == nil) {
        _liveWatcherCountBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 14.0)];
        _liveWatcherCountBgView.layer.cornerRadius = 14.0 * 0.5;
        _liveWatcherCountBgView.clipsToBounds = YES;
        
        [_liveWatcherCountBgView addSubview:self.iconImageView];
        [_liveWatcherCountBgView addSubview:self.watchCountLabel];

        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_liveWatcherCountBgView);
            make.size.equalTo(@6.0);
            make.left.equalTo(_liveWatcherCountBgView).offset(5.f);
        }];
        
        [self.watchCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_liveWatcherCountBgView);
            make.left.equalTo(self.iconImageView.mas_right).offset(4.f);
            make.right.equalTo(_liveWatcherCountBgView).offset(-7.0);
        }];
        
    }
    return _liveWatcherCountBgView;
}

- (UIImageView*)liveImageView {
    if (_liveImageView == nil) {
        _liveImageView = [[UIImageView alloc] init];
        _liveImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _liveImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveImageView.layer.cornerRadius = 16.0f;
        _liveImageView.layer.masksToBounds = YES;
        _liveImageView.backgroundColor = RGBACOLOR(200, 200, 200, 1);
        
        [_liveImageView addSubview:self.liveHeaderView];
        [_liveImageView addSubview:self.liveFooterView];
        

        [self.liveHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_liveImageView);
            make.left.right.equalTo(_liveImageView);
            make.height.equalTo(@(30.0));
        }];
        
        [self.liveFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_liveImageView);
            make.left.equalTo(_liveImageView);
            make.right.equalTo(_liveImageView);
            make.height.equalTo(@(56.0));
        }];
        
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
        broadcastLabel.text = @"start live";
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
        broadcastingTag.text = @"The anchor is liveing cannot choose";
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

- (UIImageView *)liveStreamerImageView {
    if (_liveStreamerImageView == nil) {
        _liveStreamerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiveStreamer"]];
        _liveStreamerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveStreamerImageView.layer.masksToBounds = YES;
    }
    return _liveStreamerImageView;
}

@end
