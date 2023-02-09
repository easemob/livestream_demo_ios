//
//  UIView+GradientLayer.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/23.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GradientLayer)
- (void)addTransitionColor:(UIColor *)startColor endColor:(UIColor *)endColor;
- (void)addTransitionColorLeftToRight:(UIColor *)startColor endColor:(UIColor *)endColor;
- (void)addTransitionColor:(UIColor *)startColor
                  endColor:(UIColor *)endColor
                startPoint:(CGPoint)startPoint
                  endPoint:(CGPoint)endPoint;

@end

NS_ASSUME_NONNULL_END
