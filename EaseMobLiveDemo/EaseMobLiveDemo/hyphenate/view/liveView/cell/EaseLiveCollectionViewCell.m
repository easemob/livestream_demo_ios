//
//  EaseCollectionViewCell.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCollectionViewCell.h"

#import "EaseLiveRoom.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kLabelDefaultHeight 22.f
#define kCellSpace 5.f

@interface EaseLiveCollectionViewCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UIView *liveFooter;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation EaseLiveCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.liveImageView];
        [self.liveImageView addSubview:self.liveFooter];
        [self.liveFooter addSubview:self.textLable];
        [self.liveFooter addSubview:self.numLabel];
    }
    return self;
}

- (UILabel*)textLable
{
    if (_textLable == nil) {
        _textLable = [[UILabel alloc] init];
        _textLable.frame = CGRectMake(8.f, 0, CGRectGetWidth(self.frame)/2, 14.f);
        _textLable.font = [UIFont systemFontOfSize:14.f];
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
        _numLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 50.f, 2.f, 42.f, 12.f);
        _numLabel.font = [UIFont systemFontOfSize:12];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.textAlignment = NSTextAlignmentRight;
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.shadowColor = [UIColor blackColor];
        _numLabel.shadowOffset = CGSizeMake(1, 1);
    }
    return _numLabel;
}

- (UIView*)liveFooter
{
    if (_liveFooter == nil) {
        _liveFooter = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kLabelDefaultHeight, CGRectGetWidth(self.frame), kLabelDefaultHeight)];
        _liveFooter.backgroundColor = [UIColor clearColor];
    }
    return _liveFooter;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(7.f, 6.f, 36.f, 36.f);
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

- (void)setLiveRoom:(EaseLiveRoom*)room
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
    _numLabel.text = [NSString stringWithFormat:@"%ld",(long)room.session.currentUserCount];
}


@end
