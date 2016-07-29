//
//  EaseGiftCell.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseGiftCell.h"

@interface EaseGiftCell ()

@property (nonatomic, strong) UIImageView *giftImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation EaseGiftCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.giftImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.priceLabel];
    }
    return self;
}

- (UIImageView*)giftImageView
{
    if (_giftImageView == nil) {
        _giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        _giftImageView.layer.masksToBounds = YES;
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _giftImageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _giftImageView.bottom, self.width, (self.height - self.width)/2)];
        _nameLabel.textColor = kDefaultSystemTextColor;
        _nameLabel.font = [UIFont systemFontOfSize:14.f];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel*)priceLabel
{
    if (_priceLabel == nil) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _nameLabel.bottom, self.width, (self.height - self.width)/2)];
        _priceLabel.textColor = kDefaultSystemTextColor;
        _priceLabel.font = [UIFont systemFontOfSize:14.f];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _priceLabel;
}

#pragma mark - public

- (void)setGiftWithImageName:(NSString*)imageName
                        name:(NSString*)name
                       price:(NSString*)price
{
    if (imageName.length > 0) {
        _giftImageView.image = [UIImage imageNamed:imageName];
    }
    
    if (name.length > 0) {
        _nameLabel.text = name;
    }
    
    if (price.length > 0) {
        _priceLabel.text = price;
    }
}

@end
