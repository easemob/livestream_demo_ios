//
//  EaseGiftFlyView.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/13.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseGiftFlyView.h"

#define kLabelDefaultWidth 100.f
#define kLabelDefaultHeight 25.f

@interface EaseGiftFlyView ()
{
    EMMessage *_message;
}

@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *giftLabel;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UIImageView *giftImageView;
@property(nonatomic,strong) UIView *bgView;

@end

@implementation EaseGiftFlyView

-(instancetype)initWithMessage:(EMMessage*)messge
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(-200, 80, 200, 80)];
        
        CGRect frame = self.frame;
        int flag = arc4random()%2;
        if(flag == 0) {
            frame.origin.y = 60;
            self.frame = frame;
        } else {
            frame.origin.y = 140;
            self.frame = frame;
        }
        
        _message = messge;
        [self addSubview:self.bgView];
        [self.bgView addSubview:self.headImageView];
        [self.bgView addSubview:self.nameLabel];
        [self.bgView addSubview:self.giftLabel];
        [self addSubview:self.giftImageView];
    }
    return self;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 5, 0, kLabelDefaultWidth, kLabelDefaultHeight)];
        if (_message) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_message.from attributes:nil];
            NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:12.0f]};
            [string addAttributes:attributes range:NSMakeRange(0, string.length)];
            _nameLabel.attributedText = string;
        }
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

- (UILabel*)giftLabel
{
    if (_giftLabel == nil) {
        _giftLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 5, CGRectGetMaxY(self.nameLabel.frame), kLabelDefaultWidth, kLabelDefaultHeight)];
        _giftLabel.textColor = RGBACOLOR(30, 167, 252, 1);
        _giftLabel.text = @"送了一件神秘大礼";
        _giftLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _giftLabel;
}

- (UIView*)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 200, 50)];
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = CGRectGetHeight(_bgView.frame)/2;
        _bgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
    }
    return _bgView;
}

- (UIImageView*)giftImageView
{
    if (_giftImageView == nil) {
        _giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLabel.frame), CGRectGetMinY(self.bgView.frame), CGRectGetHeight(self.bgView.frame), CGRectGetHeight(self.bgView.frame))];
        _giftImageView.image = [UIImage imageNamed:@"live_gift_default"];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftImageView;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.bgView.frame), CGRectGetHeight(self.bgView.frame))];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.cornerRadius = CGRectGetHeight(self.bgView.frame)/2;
        _headImageView.image = [UIImage imageNamed:@"live_default_user"];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

- (void)animateInView:(UIView *)view
{
    self.alpha = 0;
    __weak typeof(self) weakSelf = self;
    
    dispatch_block_t animateStepOneBlock = ^{
        CGRect frame = weakSelf.frame;
        frame.origin.x = 0;
        weakSelf.frame = frame;
        weakSelf.alpha = 1;
    };
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        animateStepOneBlock();
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.alpha = 0.f;
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
        }];
    }];
}

@end
