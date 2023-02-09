//
//  ALSLoadingView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/25.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLoadingView.h"
@interface ELDLoadingView ()
{
    UIView *line;
}
@end


@implementation ELDLoadingView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    line = [UIView new];
    line.backgroundColor = [UIColor redColor];
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1);
        make.centerX.equalTo(line.superview);
        make.width.mas_equalTo(80);
        make.top.mas_equalTo(100);
    }];
    
    [self performSelector:@selector(addAnimation) withObject:nil afterDelay:0];
}


-(void)addAnimation {
    const CGFloat animationDuration = 0.4; //动画时间
    const CGFloat lineOriginWidth = 80; //进度条的开始宽度
    const CGFloat lineResultWidth = 350; //进度条的结束宽度
    const CGFloat times = (lineResultWidth - lineOriginWidth)/lineOriginWidth; //倍数
    const int count = 6; //数组的个数
    
    NSMutableArray *values = [NSMutableArray array];
    for (int i=0; i<count; i++) {
        [values addObject:[NSNumber numberWithFloat:(times/count*i+1)]];
    }
    
    //显示动画
    CABasicAnimation *anima1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anima1.fromValue = [NSNumber numberWithFloat:0.0f];
    anima1.toValue = [NSNumber numberWithFloat:1.0f];
    anima1.duration = animationDuration;
    anima1.fillMode = kCAFillModeForwards;
    anima1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anima1.removedOnCompletion = NO;
    
    CAKeyframeAnimation *lineRunAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    lineRunAnimation.values = values;
    lineRunAnimation.keyTimes = @[
                                  [NSNumber numberWithFloat:0.0],
                                  [NSNumber numberWithFloat:0.2],
                                  [NSNumber numberWithFloat:0.4],
                                  [NSNumber numberWithFloat:0.6],
                                  [NSNumber numberWithFloat:0.8],
                                  [NSNumber numberWithFloat:1],
                                  ];
    lineRunAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    lineRunAnimation.duration = animationDuration;
    
    //隐藏动画
    CABasicAnimation *anima2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anima2.fromValue = [NSNumber numberWithFloat:1.0f];
    anima2.toValue = [NSNumber numberWithFloat:0.0f];
    anima1.duration = animationDuration;
    anima1.fillMode = kCAFillModeForwards;
    anima1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anima1.removedOnCompletion = NO;
    
    //组动画
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = [NSArray arrayWithObjects:anima1, lineRunAnimation, anima2, nil];
    groupAnimation.duration = animationDuration;
    groupAnimation.repeatCount = MAXFLOAT;
    groupAnimation.autoreverses = NO;
    
    [line.layer addAnimation:groupAnimation forKey:@"lineRunAnimation"];
}

@end
