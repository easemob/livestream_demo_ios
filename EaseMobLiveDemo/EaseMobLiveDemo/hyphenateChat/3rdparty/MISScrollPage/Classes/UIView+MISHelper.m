//  UIView的帮助类扩展
//  UIView+MISHelper.m
//  TJJXT
//
//  Created by CM on 16/7/14.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "UIView+MISHelper.h"
#import <objc/runtime.h>

@implementation UIView (MISHelper)

#pragma mark - corner

@dynamic mis_maskLayer;

static char MISMaskLayerKey;

#pragma mark - 添加属性的Setter和Getter

- (CAShapeLayer*)mis_maskLayer{
    return objc_getAssociatedObject(self, &MISMaskLayerKey);
}

- (void)setMis_maskLayer:(CAShapeLayer *)mis_maskLayer{
    objc_setAssociatedObject(self, &MISMaskLayerKey, mis_maskLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Setter and Getter

- (void)setMis_x:(CGFloat)mis_x
{
    CGRect frame = self.frame;
    frame.origin.x = mis_x;
    self.frame = frame;
}

- (CGFloat)mis_x
{
    return self.frame.origin.x;
}

- (void)setMis_y:(CGFloat)mis_y
{
    CGRect frame = self.frame;
    frame.origin.y = mis_y;
    self.frame = frame;
}

- (CGFloat)mis_y
{
    return self.frame.origin.y;
}

- (void)setMis_w:(CGFloat)mis_w
{
    CGRect frame = self.frame;
    frame.size.width = mis_w;
    self.frame = frame;
}

- (CGFloat)mis_w
{
    return self.frame.size.width;
}

- (void)setMis_h:(CGFloat)mis_h
{
    CGRect frame = self.frame;
    frame.size.height = mis_h;
    self.frame = frame;
}

- (CGFloat)mis_h
{
    return self.frame.size.height;
}

- (void)setMis_centerX:(CGFloat)mis_centerX
{
    self.mis_center = CGPointMake(mis_centerX, self.mis_centerY);
}

- (CGFloat)mis_centerX
{
    return self.center.x;
}

- (void)setMis_centerY:(CGFloat)mis_centerY
{
    self.mis_center = CGPointMake(self.mis_centerX, mis_centerY);
}

- (CGFloat)mis_centerY
{
    return self.center.y;
}

- (void)setMis_center:(CGPoint)mis_center
{
    self.center = mis_center;
}

- (CGPoint)mis_center
{
    return self.center;
}

- (void)setMis_bottomY:(CGFloat)mis_bottomY
{
    self.mis_y = mis_bottomY - self.mis_h;
}

- (CGFloat)mis_bottomY
{
    return self.mis_y + self.mis_h;
}

- (void)setMis_rightX:(CGFloat)mis_rightX
{
    self.mis_x = mis_rightX - self.mis_w;
}

- (CGFloat)mis_rightX
{
    return self.mis_x + self.mis_w;
}

- (void)setMis_size:(CGSize)mis_size
{
    CGRect frame = self.frame;
    frame.size = mis_size;
    self.frame = frame;
}

- (CGSize)mis_size
{
    return self.frame.size;
}

- (void)setMis_origin:(CGPoint)mis_origin
{
    CGRect frame = self.frame;
    frame.origin = mis_origin;
    self.frame = frame;
}

- (CGPoint)mis_origin
{
    return self.frame.origin;
}

#pragma mark - 属性：border

- (CGFloat)mis_borderWidth{
    return self.layer.borderWidth;
}

- (void)setMis_borderWidth:(CGFloat)mis_borderWidth{
    self.layer.borderWidth = mis_borderWidth;
}

- (UIColor*)mis_borderColor{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setMis_borderColor:(UIColor *)mis_borderColor{
    self.layer.borderColor = mis_borderColor.CGColor;
}

#pragma mark - 公共方法：初始化

/**
 *  初始化
 *
 *  @param color 颜色
 *
 *  @return 实例
 */
+ (instancetype)viewWithColor:(UIColor*)color
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = color;
    return view;
}

#pragma mark - 公共方法：animation

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
    case UIViewAnimationCurveEaseInOut:
        return UIViewAnimationOptionCurveEaseInOut;
        break;
    case UIViewAnimationCurveEaseIn:
        return UIViewAnimationOptionCurveEaseIn;
        break;
    case UIViewAnimationCurveEaseOut:
        return UIViewAnimationOptionCurveEaseOut;
        break;
    case UIViewAnimationCurveLinear:
        return UIViewAnimationOptionCurveLinear;
        break;
    }
    return kNilOptions;
}

#pragma mark - 公共方法：layer

- (void)mis_setRoundCornerWithRadius:(CGFloat)radius{
    self.layer.cornerRadius = radius;
}

- (void)mis_setRoundCornerWithRadius:(CGFloat)radius roundingCorners:(UIRectCorner)corners{
    if (!self.mis_maskLayer) {
        self.mis_maskLayer = [[CAShapeLayer alloc] init];
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    self.mis_maskLayer.frame = self.bounds;
    self.mis_maskLayer.path = maskPath.CGPath;
    self.layer.mask = self.mis_maskLayer;
}

@end
