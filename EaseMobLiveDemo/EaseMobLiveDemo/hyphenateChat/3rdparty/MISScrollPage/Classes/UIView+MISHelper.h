//
//  UIView+MISHelper.h
//  TJJXT
//
//  Created by CM on 16/7/14.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MISHelper)

#pragma mark - 属性

/**
 *  X坐标
 */
@property (assign, nonatomic) CGFloat mis_x;

/**
 *  Y坐标
 */
@property (assign, nonatomic) CGFloat mis_y;

/**
 *  宽度
 */
@property (assign, nonatomic) CGFloat mis_w;

/**
 *  高度
 */
@property (assign, nonatomic) CGFloat mis_h;

/**
 *  X坐标的中间
 */
@property (assign, nonatomic) CGFloat mis_centerX;

/**
 *  Y左边的中间
 */
@property (assign, nonatomic) CGFloat mis_centerY;

/**
 *  中心
 */
@property (assign, nonatomic) CGPoint mis_center;

/**
 *  底部的Y坐标
 */
@property (assign, nonatomic) CGFloat mis_bottomY;

/**
 *  右边的X坐标
 */
@property (assign, nonatomic) CGFloat mis_rightX;

/**
 *  大小
 */
@property (assign, nonatomic) CGSize mis_size;

/**
 *  位置
 */
@property (assign, nonatomic) CGPoint mis_origin;

#pragma mark - 属性：corner

/**
 *  横线的layer
 */
@property (nonatomic) CAShapeLayer* mis_maskLayer;

#pragma mark - 属性：border

/**
 边框的宽度
 */
@property (nonatomic) CGFloat mis_borderWidth;

/**
 边框的颜色
 */
@property (nonatomic) UIColor* mis_borderColor;

#pragma mark - 公共方法：初始化

/**
 *  初始化
 *
 *  @param color 颜色
 *
 *  @return 实例
 */
+ (instancetype)viewWithColor:(UIColor*)color;

#pragma mark - 公共方法：animation

/**
 *  动画选项
 *
 *  @param curve
 *
 *  @return 
 */
+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;

#pragma mark - 公共方法：layer

/**
 设置圆角

 @param radius 圆角半径
 */
- (void)mis_setRoundCornerWithRadius:(CGFloat)radius;

/**
 设置圆角

 @param radius 圆角半径
 @param corners 设置的圆角的位置
 */
- (void)mis_setRoundCornerWithRadius:(CGFloat)radius roundingCorners:(UIRectCorner)corners;

@end
