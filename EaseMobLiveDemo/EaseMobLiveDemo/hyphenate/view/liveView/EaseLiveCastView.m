//
//  EaseLiveCastView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/26.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveCastView.h"

#import "EasePublishModel.h"

@interface EaseLiveCastView ()
{
    EasePublishModel *_model;
}

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation EaseLiveCastView

- (instancetype)initWithFrame:(CGRect)frame model:(EasePublishModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self addSubview:self.headImageView];
        [self addSubview:self.nameLabel];
    }
    return self;
}


- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(0, 0, self.height, self.height);
        _headImageView.image = [UIImage imageNamed:@"1"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = CGRectGetHeight(_headImageView.frame)/2;
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
        _nameLabel.frame = CGRectMake(_headImageView.width + 10.f, 0.f, self.width - (_headImageView.width + 10.f), self.height);
        _nameLabel.font = [UIFont systemFontOfSize:15.f];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.shadowColor = RGBACOLOR(0xb8, 0xb8, 0xb8, 1);
        _nameLabel.shadowOffset = CGSizeMake(0, 1);
        _nameLabel.layer.shadowRadius = 1.f;
        if (_model) {
            _nameLabel.text = _model.name;
        }
    }
    return _nameLabel;
}

#pragma mark - action
- (void)didSelectHeadImage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeaderWithUsername:)]) {
        [self.delegate didSelectHeaderWithUsername:_model.name];
    }
}

@end
