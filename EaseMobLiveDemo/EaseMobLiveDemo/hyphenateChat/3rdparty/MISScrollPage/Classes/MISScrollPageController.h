//
//  MISScrollPageController.h
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageSegmentView.h"
#import "MISScrollPageControllerDelegate.h"
#import "MISScrollPageStyle.h"
#import "MISScrollPageContentView.h"


@interface MISScrollPageController : NSObject

#pragma mark - 属性

/**
 数据源
 */
@property (nonatomic, weak) id<MISScrollPageControllerDataSource> dataSource;

/**
 代理
 */
@property (nonatomic, weak) id<MISScrollPageControllerDelegate> delegate;

/**
 样式
 */
@property (nonatomic) MISScrollPageStyle* style;

/**
将要显示的索引
 */
@property (nonatomic, copy)void (^didScrollBlock)(NSInteger reloadIndex);

#pragma mark - 初始化

/**
 初始化

 @param style 样式
 @param dataSource 数据源
 @param delegate 代理
 @return 实例
 */
+ (instancetype)scrollPageControllerWithStyle:(MISScrollPageStyle*)style dataSource:(id<MISScrollPageControllerDataSource>)dataSource delegate:(id<MISScrollPageControllerDelegate>)delegate;

/**
 初始化
 
 @param style 样式
 @param dataSource 数据源
 @param delegate 代理
 @return 实例
 */
- (instancetype)initWithStyle:(MISScrollPageStyle*)style dataSource:(id<MISScrollPageControllerDataSource>)dataSource delegate:(id<MISScrollPageControllerDelegate>)delegate;

#pragma mark - 公共方法：得到对应的视图

/**
 得到SegmentVIew

 @param frame frame
 @return 实例，得到唯一的实例
 */
- (MISScrollPageSegmentView*)segmentViewWithFrame:(CGRect)frame;

/**
 得到contentVIew

 @param frame frame
 @return 实例，唯一
 */
- (MISScrollPageContentView*)contentViewWithFrame:(CGRect)frame;

#pragma mark - 公共方法

/**
 刷新
 */
- (void)reloadData;

/**
 刷新

 @param defaultIndex 默认显示的序号
 */
- (void)reloadDataWithDefaultIndex:(NSUInteger)defaultIndex;

/**
 无titles collection
 
 @param defaultIndex 默认显示的序号
 */
- (void)reloadDataNOTitlesWithDefaultIndex:(NSUInteger)defaultIndex;

/**
 内容是不是能滚动

 @param canScroll 能否滚动
 */
- (void)setContentViewCanScroll:(BOOL)canScroll;

/**
 滚动到对应的序号

 @param index 序号
 @param animated 是否需要动画
 */
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;



@end
