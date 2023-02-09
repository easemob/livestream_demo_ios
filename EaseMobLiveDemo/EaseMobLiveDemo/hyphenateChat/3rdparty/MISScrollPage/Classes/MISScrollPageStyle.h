//  顶部的SegmentView的样式
//  MISScrollPageStyle.h
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

@interface MISScrollPageStyle : NSObject

#pragma mark - 属性，IOS系统的segmentControl的相关的样式

/**
 是不是显示的是IOS系统的segmentControl，默认是NO
 */
@property (nonatomic, assign, getter=isIOSSegment) BOOL IOSSegment;

/**
 每个item的宽度，设置为0的话，会自适应，否则为设定的宽度，默认为0
 */
@property (nonatomic, assign) CGFloat IOSSegmentItemWidth;

/**
 系统的segmentControl的常规的颜色，默认是白色
 */
@property (nonatomic) UIColor* IOSSegmentNormalColor;

/**
 系统的segmentControl的常规的颜色，默认是蓝色
 */
@property (nonatomic) UIColor* IOSSegmentTintColor;

#pragma mark - 属性，自定义的segmentView的相关样式

/**
 是不是显示遮盖视图，默认为NO
 */
@property (nonatomic, assign, getter=isShowCover) BOOL showCover;

/**
 是不是显示下面的横线，默认为NO
 */
@property (nonatomic, assign, getter=isShowLine) BOOL showLine;

/**
 是不是显示SegmentView 底部的分割线,默认是 YES
 */
@property (nonatomic, assign, getter=isShowSegmentViewSeparatorLine) BOOL showSegmentViewSeparatorLine;

/**
 是不是显示左右的阴影， 默认为NO
 */
@property (nonatomic, assign, getter=isShowSegmentViewShadow) BOOL showSegmentViewShadow;

/**
 是不是缩放标题，默认为NO
 */
@property (nonatomic, assign, getter=isScaleTitle) BOOL scaleTitle;

/**
 是不是滚动标题，默认为YES，设置为NO的时候，所有的标题会平分宽度，效果跟UISegment相似
 */
@property (nonatomic, assign, getter=isScrollTitle) BOOL scrollTitle;

/**
 segmentView是不是有弹性效果，默认为YES
 */
@property (nonatomic, assign, getter=isSegmentViewBounces) BOOL segmentViewBounces;

/**
 contentViw是不是有弹性效果，默认为YES
 */
@property (nonatomic, assign, getter=isContentViewBounces) BOOL contentViewBounces;

/**
 标题是不是有颜色渐变的效果，默认为NO
 */
@property (nonatomic, assign, getter=isGradualChangeTitleColor) BOOL gradualChangeTitleColor;

/**
 内容是不是能够滑动，默认为YES
 */
@property (nonatomic, assign, getter=isScrollContentView) BOOL scrollContentView;

/**
 点击标题切换的时候，内容页面是不是有滑动动画，但是设置为YES的时候，当跳过两个以上的页面的时候也是没有动画的，默认为YES
 */
@property (nonatomic, assign, getter=isAnimatedContentViewWhenTitleClicked) BOOL animatedContentViewWhenTitleClicked;

/**
 当设置scrollTitle为NO的时候，标题会平分宽度，如果希望在滚动的时候遮罩或者线条跟随标题的宽度变化，就设置为YES，默认为NO
 */
@property (nonatomic, assign, getter=isAdjustCoverOrLineWidth) BOOL adjustCoverOrLineWidth;

/**
 是不是自动调整标题的宽度，当设置为YES的时候，如果所有的标题的宽度之和小于SegmentVIew的宽度，会自动调整title的位置，默认为NO
 */
@property (nonatomic, assign, getter=isAutoAdjustTitlesWidth) BOOL autoAdjustTitlesWidth;

/**
 是不是在开始滑动的时候就调整标题栏，默认为NO
 */
@property (nonatomic, assign, getter=isAdjustTitleWhenBeginDrag) BOOL adjustTitleWhenBeginDrag;

/**
 能不能滑动返回，默认为YES
 */
@property (nonatomic, assign) BOOL canSlideToGoBack;

#pragma mark - 属性

/**
 滚动的线条的高度，默认为2
 */
@property (nonatomic, assign) CGFloat scrollLineHeight;

/**
 滚动的线条的颜色，默认为lightGrayColor
 */
@property (nonatomic) UIColor* scrollLineColor;

/**
 segmentView的背景色，默认white
 */
@property (nonatomic) UIColor* segmentViewBackgroundColor;

/**
 SegmentView 的底部的分割线颜色，默认的是0xf0f0f0
 */
@property (nonatomic) UIColor* segmentViewSeparatorLineColor;

/**
 SegmentVIew的背景图片，默认为nil
 */
@property (nonatomic) UIImage* segmentViewBackgroundImage;

/**
 阴影的宽度，默认为20
 */
@property (nonatomic) CGFloat segmentViewShadowWidth;

/**
 segmentView的阴影的颜色，默认为White
 */
@property (nonatomic) UIColor* segmentViewShadowColor;

/**
 segment阴影Opacity，默认为1
 */
@property (nonatomic) CGFloat segmentViewShadowOpacity;

/**
 遮罩的背景颜色，默认为lightGrayColor
 */
@property (nonatomic) UIColor* coverBackgroundColor;

/**
 标题动画的时间,默认为0.3
 */
@property (nonatomic, assign) NSTimeInterval animateDuration;

/**
 遮罩的圆角半径，默认为14
 */
@property (nonatomic, assign) CGFloat coverCornerRadius;

/**
 遮罩的高度，默认为28
 */
@property (nonatomic, assign) CGFloat coverHeight;

/**
 标题之间的间隙，默认为15
 */
@property (nonatomic, assign) CGFloat titleMargin;

/**
 标题的字体，默认为14
 */
@property (nonatomic) UIFont* titleFont;

/**
 标题的最大的缩放倍数，默认为1.3
 */
@property (nonatomic, assign) CGFloat titleBigScale;

/**
 普通状态的标题的颜色，默认为lightGrayColor
 */
@property (nonatomic) UIColor* normalTitleColor;

/**
 选中状态的标题的颜色，默认为redColor
 */
@property (nonatomic) UIColor* selectedTitleColor;

/**
 segmentVIew的高度，默认为44.0
 */
@property (nonatomic, assign) CGFloat segmentHeight;

@end
