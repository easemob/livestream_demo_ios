//
//  ACDNoDataPromptView.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDNoDataPlaceHolderView.h"
#import <Masonry/Masonry.h>

@interface ELDNoDataPlaceHolderView ()

@property (nonatomic,strong) UIImageView *noDataImageView;
@property (nonatomic,strong) UILabel *prompt;


@end

@implementation ELDNoDataPlaceHolderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self placeAndLayoutSubviews];
    }
    
    return self;
}

- (void)placeAndLayoutSubviews{
    [self addSubview:self.noDataImageView];
    [self addSubview:self.prompt];
    
    
    [self.noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5.0);
        make.centerX.equalTo(self);
    }];
    
    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.noDataImageView.mas_bottom).offset(30.0);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(14.0);
        make.bottom.equalTo(self);
    }];
}

#pragma mark getter and setter
- (UIImageView *)noDataImageView {
    if (_noDataImageView == nil) {
        _noDataImageView = UIImageView.new;
        _noDataImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _noDataImageView;
}

- (UILabel *)prompt {
    if (_prompt == nil) {
        _prompt = UILabel.new;
        _prompt.textColor = COLOR_HEX(0xC9C9C9);
        _prompt.font = NFont(14.0);
        _prompt.textAlignment = NSTextAlignmentCenter;
        _prompt.text = @"no data";
    }
    return _prompt;
}

@end



