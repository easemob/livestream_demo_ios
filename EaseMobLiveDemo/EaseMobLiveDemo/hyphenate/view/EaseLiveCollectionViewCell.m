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
@property (nonatomic, strong) UILabel *liveLable;
@property (nonatomic, strong) UILabel *textLable;
@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation EaseLiveCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headImageView];
//        [self.headImageView addSubview:self.liveImageView];
        [self.headImageView addSubview:self.liveLable];
        [self.headImageView addSubview:self.textLable];
        [self.headImageView addSubview:self.numLabel];
    }
    return self;
}

- (UILabel*)textLable
{
    if (_textLable == nil) {
        _textLable = [[UILabel alloc] init];
        _textLable.frame = CGRectMake(5, CGRectGetHeight(self.frame) - kLabelDefaultHeight - kCellSpace, CGRectGetWidth(self.frame) - 60, kLabelDefaultHeight);
        _textLable.font = [UIFont systemFontOfSize:15];
        _textLable.textColor = [UIColor blackColor];
        _textLable.backgroundColor = [UIColor whiteColor];
        _textLable.textAlignment = NSTextAlignmentCenter;
        _textLable.layer.cornerRadius = CGRectGetHeight(_textLable.frame)/2;
        _textLable.layer.masksToBounds = YES;
        
    }
    return _textLable;
}

- (UILabel*)numLabel
{
    if (_numLabel == nil) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - 50, CGRectGetHeight(self.frame) - kLabelDefaultHeight - kCellSpace, 50, kLabelDefaultHeight);
        _numLabel.font = [UIFont systemFontOfSize:15];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.textAlignment = NSTextAlignmentRight;
        _numLabel.backgroundColor = [UIColor clearColor];
        _numLabel.shadowColor = [UIColor blackColor];
        _numLabel.shadowOffset = CGSizeMake(1, 1);
    }
    return _numLabel;
}

- (UILabel*)liveLable
{
    if (_liveLable == nil) {
        _liveLable = [[UILabel alloc] init];
        _liveLable.frame = CGRectMake(CGRectGetWidth(self.frame)  - 44 - kCellSpace, kCellSpace, 44, 30);
        _liveLable.font = [UIFont fontWithName:kEaseDefaultIconFont size:40];
        _liveLable.text = kEaseLiveLabel;
    }
    return _liveLable;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}

- (UIImageView*)liveImageView
{
    if (_liveImageView == nil) {
        _liveImageView = [[UIImageView alloc] init];
        _liveImageView.frame = CGRectMake(CGRectGetWidth(self.frame)  - 44 - kCellSpace, kCellSpace, 44, 26);
        _liveImageView.contentMode = UIViewContentModeScaleAspectFill;
        _liveImageView.image = [UIImage imageNamed:@"explore_tag_live_big"];
        _liveImageView.layer.masksToBounds = YES;
    }
    return _liveImageView;
}

- (void)setModel:(EasePublishModel *)model
{
    
    CGRect rect;
    NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:15.0f]};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:model.name attributes:attributes];
    
    rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, kLabelDefaultHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (rect.size.width + 20 > CGRectGetWidth(self.frame) - 60) {
        rect.size.width = CGRectGetWidth(self.frame) - 60;
    }
    _textLable.attributedText = string;
    
    _textLable.frame = CGRectMake(5, CGRectGetHeight(self.frame) - kLabelDefaultHeight - kCellSpace, rect.size.width + 20, kLabelDefaultHeight);
    _numLabel.text = model.number;
    _headImageView.image = [UIImage imageNamed:model.headImageName];
}

@end
