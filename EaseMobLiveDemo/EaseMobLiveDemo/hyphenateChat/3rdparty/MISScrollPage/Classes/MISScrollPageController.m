//  滚动翻页控制器
//  MISScrollPageController.m
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageController.h"

@interface MISScrollPageController () <MISScrollPageContentViewDelegate>

#pragma mark - 属性

/**
 标题滚动视图
 */
@property (nonatomic) MISScrollPageSegmentView* segmentView;

/**
 内容视图
 */
@property (nonatomic) MISScrollPageContentView* contentView;

/**
 标题的数组
 */
@property (nonatomic) NSArray* titles;

/**
 内容的子视图
 */
@property (nonatomic) NSArray* contentChildViewControllers;

@end

@implementation MISScrollPageController

#pragma mark - 初始化

+ (instancetype)scrollPageControllerWithStyle:(MISScrollPageStyle*)style dataSource:(id<MISScrollPageControllerDataSource>)dataSource delegate:(id<MISScrollPageControllerDelegate>)delegate{
    MISScrollPageController* pageController = [[MISScrollPageController alloc] initWithStyle:style dataSource:dataSource delegate:delegate];
    return pageController;
}

- (instancetype)initWithStyle:(MISScrollPageStyle*)style dataSource:(id<MISScrollPageControllerDataSource>)dataSource delegate:(id<MISScrollPageControllerDelegate>)delegate{
    self = [super init];
    if(self){
        _dataSource = dataSource;
        _delegate = delegate;
        _style = style;
    }
    return self;
}

#pragma mark - 公共方法：得到对应的视图

- (MISScrollPageSegmentView*)segmentViewWithFrame:(CGRect)frame{
    if(!_segmentView){
        __weak __typeof(self) wkSelf = self;
        _segmentView = [[MISScrollPageSegmentView alloc] initWithFrame:frame style:_style titles:@[] delegate:_delegate titleTapedBlock:^(MISScrollPageSegmentTitleView *titleView, NSInteger index) {
            __strong __typeof(self) ssSelf = wkSelf;
            if(ssSelf.contentView){
                [ssSelf.contentView scrollToIndex:index animated:YES];
            }
        }];
    }
    return _segmentView;
}

- (MISScrollPageContentView*)contentViewWithFrame:(CGRect)frame{
    if(!_contentView){
        _contentView = [[MISScrollPageContentView alloc] initWithFrame:frame style:_style delegate:self];
    }
    return _contentView;
}

#pragma mark - 公共方法

- (void)reloadData{
    [self reloadDataWithDefaultIndex:0];
}

- (void)reloadDataWithDefaultIndex:(NSUInteger)defaultIndex{
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titlesOfSegmentView)]){
        _titles = [self.dataSource titlesOfSegmentView];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(childViewControllersOfContentView)]){
        _contentChildViewControllers = [self.dataSource childViewControllersOfContentView];
    }
    
    if(!_titles){
        return;
    }
    
    if(!_contentChildViewControllers){
        return;
    }
    
    if(_titles.count != _contentChildViewControllers.count){
        return;
    }
    
    if(defaultIndex >= _titles.count){
        //数据不合法
        return;
    }

    if(!_segmentView){
        return;
    }
    
    if(!_contentView){
        return;
    }
    
    if ([_titles count] > 0) {
        [_segmentView reloadWithNewTitles:_titles defaultIndex:defaultIndex];
    }
    
    [_contentView reloadDataWithChildViewControllers:_contentChildViewControllers defaultIndex:defaultIndex];
}


/**
 无titles collection
 
 @param defaultIndex 默认显示的序号
 */
- (void)reloadDataNOTitlesWithDefaultIndex:(NSUInteger)defaultIndex {
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(titlesOfSegmentView)]){
        _titles = [self.dataSource titlesOfSegmentView];
    }
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(childViewControllersOfContentView)]){
        _contentChildViewControllers = [self.dataSource childViewControllersOfContentView];
    }
    
    if(!_contentChildViewControllers){
        return;
    }

    
    if(!_contentView){
        return;
    }
    
    if ([_titles count] > 0) {
        [_segmentView reloadWithNewTitles:_titles defaultIndex:defaultIndex];
    }
    
    [_contentView reloadDataWithChildViewControllers:_contentChildViewControllers defaultIndex:defaultIndex];
}


- (void)setContentViewCanScroll:(BOOL)canScroll{
    if(_contentView){
        _contentView.collectionView.scrollEnabled = canScroll;
    }
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated{
    if(_segmentView){
        [_segmentView setSelectedIndex:index animated:animated];
    }
    if(_contentView){
        [_contentView scrollToIndex:index animated:animated];
    }
}

#pragma mark - MISScrollPageContentViewDelegate

- (void)scrollWithProgress:(CGFloat)progress fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex{
    if(_segmentView){
        [_segmentView adjustUIWithProgress:progress oldIndex:fromIndex currentIndex:toIndex];
    }else {
        if (self.didScrollBlock) {
            self.didScrollBlock(toIndex);
        }
    }
}

- (void)scrolToIndex:(NSUInteger)index{
    if(_segmentView){
        [_segmentView adjustTitleOffSetToCurrentIndex:index];
    }
}

@end
