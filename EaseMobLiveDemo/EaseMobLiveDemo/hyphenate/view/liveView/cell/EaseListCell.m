//
//  EaseListCell.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/22.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseListCell.h"

@interface EaseListCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation EaseListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headImageView];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.contentLabel];
        _timeLabel.hidden = YES;
    }
    return self;
}

#pragma mark - getter

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.f, 9.f, 36.f, 36.f)];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.cornerRadius = _headImageView.width/2;
        _headImageView.backgroundColor = kDefaultSystemLightGrayColor;
    }
    return _headImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10.f, 10.f, self.width - CGRectGetMaxX(_headImageView.frame) - _timeLabel.width, 18.f)];
        _nameLabel.textColor = kDefaultSystemTextColor;
        _nameLabel.font = [UIFont systemFontOfSize:16.f];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)contentLabel
{
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10.f, _nameLabel.bottom, self.width - CGRectGetMaxX(_headImageView.frame), 18.f)];
        _contentLabel.textColor = kDefaultSystemTextColor;
        _contentLabel.font = [UIFont systemFontOfSize:16.f];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _contentLabel;
}

- (UILabel*)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 100 - 12.f, 10.f, 100.f, 14.f)];
        _timeLabel.textColor = kDefaultSystemTextGrayColor;
        _timeLabel.font = [UIFont systemFontOfSize:12.f];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

#pragma mark - setting

- (void)setName:(NSString *)name
{
    _nameLabel.text = name;
}

- (void)setContent:(NSString*)content
{
    _contentLabel.text = content;
}

- (void)setHeadImage:(UIImage *)headImage
{
    _headImageView.image = headImage;
}

- (void)setTime:(NSString *)time
{
    _timeLabel.hidden = NO;
    _timeLabel.text = time;
}

@end
