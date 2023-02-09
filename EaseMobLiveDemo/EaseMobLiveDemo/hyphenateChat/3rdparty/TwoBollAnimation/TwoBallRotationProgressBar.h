//
//  TwoBallRotationProgressBar.h
//  TwoBallRotationProgressBar
//
//  Created by HailongHan on 15/8/8.
//  Copyright (c) 2015年 hhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoBallRotationProgressBar : UIView

/**
 *  设置小球的半径
 *
 *  @param radius 半径
 */
- (void)setBallRadius:(CGFloat)radius;

/**
 *  设置俩小球颜色
 *
 *  @param oneColor 第一个小球颜色
 *  @param twoColor 第二个小球颜色
 */
- (void)setOneBallColor:(UIColor *)oneColor twoBallColor:(UIColor *)twoColor;

/**
 *  动画时间
 */
- (void)setAnimatorDuration:(CGFloat)duration;

/**
 *  设置小球移动的轨迹半径距离
 */
- (void)setAnimatorDistance:(CGFloat)distance;

- (void)startAnimator;
- (void)stopAnimator;

@end