//
//  UIView+GradientLayer.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/23.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "UIView+GradientLayer.h"

@implementation UIView (GradientLayer)
//- (CAGradientLayer *)gradientViewStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
//    gradientLayer.locations = @[@0.5, @1.0];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(1.0, 0);
//    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    return gradientLayer;
//}
//

//左右渐变
- (void)addTransitionColorLeftToRight:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addTransitionColor:startColor endColor:endColor startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
}

//斜渐变
- (void)addTransitionColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    [self addTransitionColor:startColor endColor:endColor startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 1)];
}

- (void)addTransitionColor:(UIColor *)startColor
                  endColor:(UIColor *)endColor
                startPoint:(CGPoint)startPoint
                  endPoint:(CGPoint)endPoint {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
    gradientLayer.locations = @[@0, @1];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

@end


