//
//  UIView+MISRedPoint.h
//  MISScrollPage
//
//  Created by liu on 2020/3/12.
//

#import <UIKit/UIKit.h>

@class MISRedDot,MISRedDotConfig;

@interface UIView (MISRedPoint)
@property (nonatomic,  strong) MISRedDot *MIS_redDot;
@end

@interface MISRedDot : UIView
+ (instancetype)defaultDot;
+ (instancetype)redDotWithConfig:(MISRedDotConfig *)config;
@end

@interface MISRedDotConfig : NSObject

/** Size of red dot. */
@property (nonatomic,  assign) CGSize  size;

/** Radius of red dot. */
@property (nonatomic,  assign) CGFloat  radius;

/** Default is 'redColor'. */
@property (nonatomic,  strong) UIColor *color;

/** Right space in superview. */
@property (nonatomic,  assign) CGFloat  offsetX;

/** Top space in superview. */
@property (nonatomic,  assign) CGFloat  offsetY;

@end

