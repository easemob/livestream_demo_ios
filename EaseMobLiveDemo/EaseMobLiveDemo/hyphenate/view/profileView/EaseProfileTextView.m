//
//  EaseProfileTextView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseProfileTextView.h"

@interface EaseProfileTextView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation EaseProfileTextView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString*)name
                       number:(NSString*)number
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nameLabel];
        _nameLabel.text = name;
        [self addSubview:self.numberLabel];
        _numberLabel.text = number;
    }
    return self;
}

#pragma mark - getter

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 0, self.width/2 - 5.f, self.height)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = RGBACOLOR(147, 147, 147, 1);
    }
    return _nameLabel;
}

- (UILabel*)numberLabel
{
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.width, 0, self.width/2, self.height)];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.textColor = kDefaultSystemTextColor;
    }
    return _numberLabel;
}

#pragma mark - public

- (void)setNumberColor:(UIColor*)color
{
    _numberLabel.textColor = color;
}

- (void)setNameColor:(UIColor*)color
{
    _nameLabel.textColor = color;
}

@end
