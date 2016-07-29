//
//  EaseCollectionViewCell.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCollectionViewCell.h"

#import "EasePublishModel.h"

#define kLabelDefaultHeight 30.f
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
        [self addSubview:self.liveImageView];
        [self.liveImageView addSubview:self.liveFooter];
        
        //[self.liveFooter addSubview:self.headImageView];
        [self.liveFooter addSubview:self.textLable];
        [self.liveFooter addSubview:self.numLabel];
    }
    return self;
}

- (UILabel*)textLable
{
    if (_textLable == nil) {
        _textLable = [[UILabel alloc] init];
        _textLable.frame = CGRectMake(10.f, 0, CGRectGetWidth(self.frame)/2 - 10.f, kLabelDefaultHeight);
        _textLable.font = [UIFont systemFontOfSize:15];
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
        _numLabel.frame = CGRectMake(CGRectGetWidth(self.frame)/2 - 10.f, 0, CGRectGetWidth(self.frame)/2, kLabelDefaultHeight);
        _numLabel.font = [UIFont systemFontOfSize:15];
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
    }
    return _liveImageView;
}

- (void)setModel:(EasePublishModel *)model
{
    _textLable.text = model.name;
    _liveImageView.image = [UIImage imageNamed:model.headImageName];
    _numLabel.text = model.number;
}

@end
