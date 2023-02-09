//  标题滚动视图
//  MISScrollPageSegmentView.h
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageStyle.h"
#import "MISScrollPageSegmentTitleView.h"
#import "MISScrollPageControllerDelegate.h"


/**
 标题按钮点击的回调

 @param titleView 标题视图
 @param index 位置
 */
typedef void(^TitleBtnTapedBlock)(MISScrollPageSegmentTitleView *titleView, NSInteger index);

@interface MISScrollPageSegmentView : UIView

#pragma mark - 属性

/**
 所有的标题的数组
 */
@property (nonatomic) NSArray* titles;

/**
 样式
 */
@property (nonatomic) MISScrollPageStyle* style;

/**
 代理
 */
@property (nonatomic, weak) id<MISScrollPageControllerDelegate> delegate;

/**
 标题点击的回调
 */
@property (nonatomic, copy) TitleBtnTapedBlock titleTapedBlock;

#pragma mark - 初始化

/**
 初始化

 @param frame frame
 @param style 样式
 @param titles 标题的数组
 @param parentViewController 父控制器
 @param delegate 代理
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame style:(MISScrollPageStyle*)style titles:(NSArray*)titles delegate:(id<MISScrollPageControllerDelegate>)delegate titleTapedBlock:(TitleBtnTapedBlock)titleTapedBlock;

#pragma mark - 公共方法

/**
 切换下标的时候根据progress同步设置UI

 @param progress 进度
 @param oldIndex 就得序号
 @param currentIndex 当前的序号
 */
- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex;

/**
 让选中的标题居中

 @param currentIndex 当前的序号
 */
- (void)adjustTitleOffSetToCurrentIndex:(NSInteger)currentIndex;

/**
 选中item

 @param selectedIndex 要选中的序号
 @param animated 是不是要动画
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

/**
 重新刷新标题的内容

 @param newTitles 标题的数组
 */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles;

/**
 重新刷新标题的内容
 
 @param newTitles 标题的数组
 @param defaultIndex 默认的显示的序号
 */
- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles defaultIndex:(NSUInteger)defaultIndex;

/**
 重新绘制标题小红点
 
 @param isShow 是否显示小红点
 @param titleIndex 标题位置
 */
- (void)reloadTitleRedPointWithISShow:(BOOL)isShow withTitleIndex:(NSInteger)titleIndex;


@end
