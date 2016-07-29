//
//  EaseTagView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseTagView.h"

@interface EaseTagView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation EaseTagView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString*)name
                    imageName:(NSString*)imageName
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:self.imageView];
        if (_imageView.image == nil) {
            _imageView.backgroundColor = RGBACOLOR(222, 222, 222, 1);
            _imageView.layer.cornerRadius = _imageView.width/2;
        }
        self.nameLabel.text = name;
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (UIImageView*)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        CGFloat width = self.height - 40.f;
        _imageView.frame = CGRectMake((self.width - width)/2, 0, width, width);
        _imageView.layer.masksToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(0, _imageView.bottom + 5, self.width, 20.f);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
    }
    return _nameLabel;
}

#pragma mark - public

- (void)setNameColor:(UIColor *)color
{
    if (color) {
        _nameLabel.textColor = color;
    }
}

@end

@interface EaseEndTagView ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation EaseEndTagView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString*)name
                         text:(NSString*)text
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nameLabel.text = name;
        [self addSubview:self.nameLabel];
        self.textLabel.text = text;
        [self addSubview:self.textLabel];
    }
    return self;
}

- (UILabel*)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(0, 0, self.width, self.height/2 - 5);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
    }
    return _nameLabel;
}

- (UILabel*)textLabel
{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.frame = CGRectMake(0, _nameLabel.bottom, self.width, self.height/2 - 5);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:18.f];
    }
    return _textLabel;
}

- (void)setTextColor:(UIColor*)color
{
    if (color) {
        _textLabel.textColor = color;
    }
}

- (void)setNameColor:(UIColor *)color
{
    if (color) {
        _nameLabel.textColor = color;
    }
}

@end