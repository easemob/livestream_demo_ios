//
//  MISScrollPageContentView.h
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageCollectionView.h"
#import "MISScrollPageCollectionView.h"
#import "MISScrollPageStyle.h"
#import "MISScrollPageControllerDelegate.h"

/**
 内容也得代理
 */
@protocol MISScrollPageContentViewDelegate <MISScrollPageControllerDelegate>

@optional

- (void)scrollWithProgress:(CGFloat)progress fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (void)scrolToIndex:(NSUInteger)index;

@end

@interface MISScrollPageContentView : UIView

#pragma mark - 属性

/**
  横向滚动视图
 */
@property (nonatomic, readonly) MISScrollPageCollectionView* collectionView;

/**
 代理类
 */
@property (nonatomic, weak) id<MISScrollPageContentViewDelegate> delegate;

#pragma mark - 初始化

/**
 初始化

 @param frame frame
 @param style 样式
 @param delegate 代理
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame style:(MISScrollPageStyle*)style delegate:(id<MISScrollPageContentViewDelegate>)delegate;

#pragma mark - 公共方法

/**
 重新加载

 @param childViewControllers 自控制器的数组
 */
- (void)reloadDataWithChildViewControllers:(NSArray*)childViewControllers;

/**
 重新加载

 @param childViewControllers 子控制器的数组
 @param defaultIndex 默认显示的序号
 */
- (void)reloadDataWithChildViewControllers:(NSArray*)childViewControllers defaultIndex:(NSUInteger)defaultIndex;

/**
 滚动到位置

 @param index 序号
 @param animated 是不是有动画
 */
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

@end
