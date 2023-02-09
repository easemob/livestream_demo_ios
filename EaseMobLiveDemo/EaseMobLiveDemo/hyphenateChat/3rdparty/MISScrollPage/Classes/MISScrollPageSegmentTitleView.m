//  单个的标题的视图
//  MISScrollPageSegmentTitleView.m
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageSegmentTitleView.h"

@interface MISScrollPageSegmentTitleView ()

#pragma mark - 属性

/**
 标题的size
 */
@property (nonatomic) CGSize titleSize;

/**
 标题Label
 */
@property (nonatomic) UILabel* label;

@end

@implementation MISScrollPageSegmentTitleView

#pragma mark - Getter

- (UILabel*)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

#pragma mark - Setter

- (void)setCurrentTransformSx:(CGFloat)currentTransformSx{
    _currentTransformSx = currentTransformSx;
    self.transform = CGAffineTransformMakeScale(currentTransformSx, currentTransformSx);
}

- (void)setText:(NSString *)text{
    _text = text;
    self.label.text = text;
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.label.font} context:nil];
    _titleSize = bounds.size;
}

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.label.textColor = textColor;
}

- (void)setFont:(UIFont *)font{
    _font = font;
    self.label.font = font;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

#pragma mark - 生命周期

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
}

#pragma mark - 私有方法

/**
 准备工作
 */
- (void)prepare{
    self.currentTransformSx = 1.0;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

#pragma mark - 公共方法

- (CGFloat)titleViewWidth {
    return _titleSize.width;
}

- (void)adjustSubviewFrame{
}

@end
