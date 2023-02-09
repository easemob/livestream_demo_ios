//
//  MISScrollPageSegmentTitleView.h
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//


@interface MISScrollPageSegmentTitleView : UIView

#pragma mark - 属性

/**
 当前的Scale
 */
@property (nonatomic, assign) CGFloat currentTransformSx;

/**
 显示文本
 */
@property (strong, nonatomic) NSString *text;

/**
 文本的颜色
 */
@property (strong, nonatomic) UIColor *textColor;

/**
 字体
 */
@property (strong, nonatomic) UIFont *font;

/**
 选中
 */
@property (assign, nonatomic, getter=isSelected) BOOL selected;

/**
 标题的Label
 */
@property (strong, nonatomic, readonly) UILabel *label;

#pragma mark - 公共方法

/**
 标题视图的宽度

 @return 宽度
 */
- (CGFloat)titleViewWidth;

/**
 重新排列子视图位置
 */
- (void)adjustSubviewFrame;

@end
