//
//  MISDatePickerSheet.h
//  Eduapp
//
//  Created by maokebing on 12-8-16.
//  Copyright (c) 2012年 eduapp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MISDatePickerSheet : UIView

/**
 *  最小时间
 */
@property (nonatomic) NSDate* minDate;

/**
 *  最大时间
 */
@property (nonatomic) NSDate* maxDate;

/**
 *  当前时间
 */
@property (nonatomic) NSDate* date;

/**
 *  设置确认后的回调
 */
@property (nonatomic, copy) void(^dateBlock)(NSDate* date);

/**
 *  初始化
 *
 *  @param mode 见-UIDatePickerMode
 *
 *  @return 实例
 */
- (id)initWithDatePickerMode:(UIDatePickerMode)mode;

/**
 *  显示
 */
- (void)show;

@end