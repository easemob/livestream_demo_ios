//  datasource和delegate
//  MISScrollPageControllerDelegate.h
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageSegmentTitleView.h"

/*------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------*/

/**
 DataSource
 */
@protocol MISScrollPageControllerDataSource <NSObject>

@required

/**
 显示的子控制器的个数，跟title的个数是一样的

 @return 个数
 */
- (NSUInteger)numberOfChildViewControllers;

/**
 内容的子视图数组

 @return 数组
 */
- (NSArray*)childViewControllersOfContentView;

/**
 SegmentVIew的标题的数组

 @return 数组
 */
- (NSArray*)titlesOfSegmentView;

@end

/*------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------*/

/**
 内容的子视图的代理，生命周期
 */
@protocol MISScrollPageControllerContentSubViewControllerDelegate <NSObject>

@optional

/**
 是不是已经加载过了
 
 @return BOOL
 */
- (BOOL)hasAlreadyLoaded;

/**
 加载

 @param index 序号
 */
- (void)viewDidLoadedForIndex:(NSUInteger)index;


/**
 将要显示

 @param index 序号
 */
- (void)viewWillAppearForIndex:(NSUInteger)index;

/**
 已经显示

 @param index 序号
 */
- (void)viewDidAppearForIndex:(NSUInteger)index;

/**
 将要消失

 @param index 序号
 */
- (void)viewWillDisappearForIndex:(NSUInteger)index;

/**
 已经消失
 
 @param index 序号
 */
- (void)viewDidDisappearForIndex:(NSUInteger)index;


@end

/*------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------------------------------------------------*/

/**
 Delegate
 */
@protocol MISScrollPageControllerDelegate <NSObject>

@optional

/**
 生成了一个TItleVIew

 @param titleView 视图
 @param index 序号
 */
- (void)generatedTitleView:(MISScrollPageSegmentTitleView*)titleView forIndex:(NSUInteger)index;

/**
 自控制室视图

 @param childViewController 视图
 @param index 序号
 */
- (void)childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController forIndex:(NSUInteger)index;

/**
 将要显示自控制器

 @param pageController 实例
 @param childViewController 自控制器
 @param index 序号
 */
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController willAppearForIndex:(NSUInteger)index;

/**
 已经显示

 @param pageController 实例
 @param childViewController 子控制器
 @param index 序号
 */
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index;

/**
 将要消失

 @param pageController 实例
 @param childViewController 自控制器
 @param index 序号
 */
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController willDisappearForIndex:(NSUInteger)index;

/**
 已经消失

 @param pageController 实例
 @param childViewController 子控制期
 @param index 序号
 */
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didDisappearForIndex:(NSUInteger)index;

@end

@interface MISScrollPageControllerDelegate : NSObject

@end
