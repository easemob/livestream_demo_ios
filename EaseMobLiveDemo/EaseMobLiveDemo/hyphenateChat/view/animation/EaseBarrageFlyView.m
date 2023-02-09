//
//  EaseBarrageFlyView.m
//
//  Created by EaseMob on 16/6/13.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseBarrageFlyView.h"

#define kLabelDefaultMinWidth 60.5f
#define kLabelDefaultMaxWidth [[UIScreen mainScreen] bounds].size.width - 10.5
#define kLabelDefaultHeight 21.f

@interface EaseBarrageFlyView ()
{
    EMChatMessage *_message;
}

@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *giftLabel;
@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UIView *bgView;

@end

@implementation EaseBarrageFlyView

-(instancetype)initWithMessage:(EMChatMessage*)messge
{
    self = [super init];
    if (self) {
        int flag = arc4random()%140 + 80;
        [self setFrame:CGRectMake(0, flag, kLabelDefaultMaxWidth, 80)];
        
        _message = messge;
        //[self addSubview:self.bgView];
        //[self.bgView addSubview:self.headImageView];
        //[self.bgView addSubview:self.nameLabel];
        //[self.bgView addSubview:self.giftLabel];
        [self addSubview:self.giftLabel];
    }
    return self;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 5, 0, kLabelDefaultMinWidth, kLabelDefaultHeight)];
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
        CGFloat width = kLabelDefaultMinWidth;
        EMCustomMessageBody *body = (EMCustomMessageBody*)_message.body;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],};
        CGSize textSize = [[body.customExt objectForKey:@"txt"] boundingRectWithSize:CGSizeMake(kLabelDefaultMaxWidth, kLabelDefaultHeight) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
        if (textSize.width >= kLabelDefaultMaxWidth) {
            width = kLabelDefaultMaxWidth;
        } else if (textSize.width < 50.0){
            width = kLabelDefaultMinWidth;
        } else {
            width = textSize.width + 10.5;
        }
        _giftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, kLabelDefaultHeight)];
        _giftLabel.textAlignment = NSTextAlignmentCenter;
        _giftLabel.textColor = [UIColor whiteColor];
        _giftLabel.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2].CGColor;
        _giftLabel.layer.cornerRadius = 10.5;
        _giftLabel.text = [body.customExt objectForKey:@"txt"];
        _giftLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _giftLabel;
}

- (UIView*)bgView
{
    if (_bgView == nil) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 200, 50)];
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = CGRectGetHeight(_bgView.frame)/2;
        _bgView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    }
    return _bgView;
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
    CGRect frame = self.frame;
    frame.origin.x = CGRectGetMaxX(view.frame) + CGRectGetWidth(_giftLabel.frame);
    self.frame = frame;
    
    self.alpha = 1;
    __weak typeof(self) weakSelf = self;
    
    dispatch_block_t animateStepOneBlock = ^{
        CGRect frame = weakSelf.frame;
        frame.origin.x = -CGRectGetWidth(_giftLabel.frame);
        weakSelf.frame = frame;
        weakSelf.alpha = 1;
    };
    
    [UIView animateWithDuration:5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        animateStepOneBlock();
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
