//
//  ELDGifCountDownView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/29.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDGiftCountDownView.h"
#import "ELDLivingCountdownView.h"

@interface ELDGiftCountDownView ()
@property (nonatomic, strong) ELDLivingCountdownView *countDownView;
@property (nonatomic, strong) UIImageView *coverImageView;

@end



@implementation ELDGiftCountDownView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutView];
    }
    return self;
}

- (void)placeAndLayoutView {
    [self addSubview:self.coverImageView];
    [self addSubview:self.countDownView];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
}

#pragma mark public method
- (void)startCountDown {
    [self.countDownView startCountDown];
}

#pragma mark getter and setter
- (ELDLivingCountdownView *)countDownView {
    if (_countDownView == nil) {
        _countDownView = [[ELDLivingCountdownView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        _countDownView.hasUnit = YES;
        
        ELD_WS
        _countDownView.CountDownFinishBlock = ^{
            if (weakSelf.countDownFinishBlock) {
                weakSelf.countDownFinishBlock();
            }
        };
        
    }
    return _countDownView;
}

- (UIImageView *)coverImageView {
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_coverImageView setImage:ImageWithName(@"gift_cover")];
    }
    return _coverImageView;
}


@end
