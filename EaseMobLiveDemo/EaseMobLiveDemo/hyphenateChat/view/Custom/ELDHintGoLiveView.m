//
//  ELDHintGoLiveView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/28.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDHintGoLiveView.h"
#import <Masonry/Masonry.h>

@interface ELDHintGoLiveView ()
@property (nonatomic,strong) UIImageView *hintImageView;
@property (nonatomic,strong) UILabel *prompt;

@end

@implementation ELDHintGoLiveView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self placeAndLayoutSubviews];
    }
    
    return self;
}

- (void)placeAndLayoutSubviews{
    [self addSubview:self.prompt];
    [self addSubview:self.hintImageView];

    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5.0);
        make.left.right.equalTo(self);
    }];
    
    [self.hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.prompt.mas_bottom).offset(16.0);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self);
    }];

}

#pragma mark getter and setter
- (UIImageView *)hintImageView {
    if (_hintImageView == nil) {
        _hintImageView = UIImageView.new;
        [_hintImageView setImage:ImageWithName(@"hintLive")];
        _hintImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _hintImageView;
}

- (UILabel *)prompt {
    if (_prompt == nil) {
        _prompt = UILabel.new;
        _prompt.textColor = COLOR_HEX(0xFFFFFF);
        _prompt.font = NFont(18.0);
        _prompt.textAlignment = NSTextAlignmentCenter;
        _prompt.text = NSLocalizedString(@"main.startLive", nil);
    }
    return _prompt;
}

@end



