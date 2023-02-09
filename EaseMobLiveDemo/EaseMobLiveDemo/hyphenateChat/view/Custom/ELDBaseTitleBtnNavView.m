//
//  ELDBaseTitleBtnNavView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/17.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDBaseTitleBtnNavView.h"

#define kButtonHeight 44.0

@interface ELDBaseTitleBtnNavView ()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation ELDBaseTitleBtnNavView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    [self addSubview:self.leftLabel];
    [self addSubview:self.rightButton];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16.0);
        make.centerY.equalTo(self);
        make.right.equalTo(self.rightButton.mas_left);
        make.height.equalTo(@(24.0));
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leftLabel);
        make.size.equalTo(@(kButtonHeight));
        make.right.equalTo(self).offset(-16.0);
    }];
}


- (void)rightButtonAction {
    if (self.rightButtonBlock) {
        self.rightButtonBlock();
    }
}

#pragma mark getter and setter
- (UILabel *)leftLabel {
    if (_leftLabel == nil) {
        _leftLabel = UILabel.new;
        _leftLabel.textColor = COLOR_HEX(0xFFFFFF);
        _leftLabel.font = NFont(20.0);
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.text = NSLocalizedString(@"main.title", nil);
    }
    return _leftLabel;
}

- (UIButton*)rightButton
{
    if (_rightButton == nil) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(0, 0, kButtonHeight, kButtonHeight);
        [_rightButton setImage:[UIImage imageNamed:@"setting_edit"] forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}



@end

#undef kButtonHeight

