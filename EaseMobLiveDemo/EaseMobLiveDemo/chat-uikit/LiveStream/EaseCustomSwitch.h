//
//  EaseCustomSwitch.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/2.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseCustomSwitch : UIView
/**
 开关状态改变
 */
@property (nonatomic, strong) void (^changeStateBlock)(BOOL isOn);

/**
 自定义init方法
 @param textFont 文字大小/字体
 @param onText 开启状态按钮的文字
 @param offText 关闭状态按钮的文字
 @param bgOnColor 开启状态Switch轨道的颜色
 @param bgOffColor 关闭状态Switch轨道的颜色
 @param btnOnColor 开启状态按钮的颜色
 @param btnOffColor 关闭状态按钮的颜色
 @param textOnColor 开启状态文字颜色
 @param textOffColor 关闭状态文字颜色
 @return 对象实例
 */
- (instancetype)initWithTextFont:(UIFont *)textFont OnText:(NSString *)onText offText:(NSString *)offText onBackGroundColor:(UIColor *)bgOnColor offBackGroundColor:(UIColor *)bgOffColor onButtonColor:(UIColor *)btnOnColor offButtonColor:(UIColor *)btnOffColor onTextColor:(UIColor *)textOnColor andOffTextColor:(UIColor *)textOffColor isOn:(BOOL)isOn frame:(CGRect)frame;


- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
