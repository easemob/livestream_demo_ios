//  内容视图
//  MISScrollPageContentView.m
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageContentView.h"
#import <Masonry/Masonry.h>

//复用标志
static NSString* UICollectionViewCellIdentifier = @"UICollectionViewCellIdentifier";

@interface MISScrollPageContentView () <UICollectionViewDataSource, UICollectionViewDelegate>

#pragma mark - 属性

/**
 横向滚动视图
 */
@property (nonatomic, readwrite) MISScrollPageCollectionView* collectionView;

/**
 layout
 */
@property (nonatomic) UICollectionViewFlowLayout* collectionLayout;

/**
 样式
 */
@property (nonatomic) MISScrollPageStyle* style;

/**
 记录的上次的序号
 */
@property (nonatomic, assign) NSUInteger oldIndex;

/**
 当前的序号
 */
@property (nonatomic, assign) NSUInteger currentIndex;

/**
 记录的上次的X坐标
 */
@property (nonatomic, assign) CGFloat oldOffSetX;

/**
 当这个属性设置为YES的时候 就不用处理 scrollView滚动的计算
 */
@property (assign, nonatomic) BOOL forbidTouchToAdjustPosition;

/**
 子控制器的数组
 */
@property (nonatomic) NSMutableArray* childViewControllers;

/**
 是不是有切换动画,跨越超过俩个页面就没有切换动画了
 */
@property (nonatomic, assign) BOOL changeAnimated;

/**
 当前的显示的视图或者控制器
 */
@property (nonatomic) id<MISScrollPageControllerContentSubViewControllerDelegate> currentChildViewController;

@end

@implementation MISScrollPageContentView

#pragma mark - Getter

- (MISScrollPageCollectionView*)collectionView{
    if(!_collectionView){
        _collectionView = [[MISScrollPageCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionLayout];
        [_collectionView setBackgroundColor:UIColor.clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = YES;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:UICollectionViewCellIdentifier];
        _collectionView.bounces = self.style.isContentViewBounces;
        _collectionView.scrollEnabled = self.style.isScrollContentView;
        _collectionView.canPanToGoBack = self.style.canSlideToGoBack;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout*)collectionLayout{
    if(!_collectionLayout){
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.itemSize = self.bounds.size;
        _collectionLayout.minimumLineSpacing = 0.0;
        _collectionLayout.minimumInteritemSpacing = 0.0;
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _collectionLayout;
}

- (NSMutableArray*)childViewControllers{
    if(!_childViewControllers){
        _childViewControllers = [[NSMutableArray alloc] init];
    }
    return _childViewControllers;
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame style:(MISScrollPageStyle*)style delegate:(id<MISScrollPageContentViewDelegate>)delegate{
    self = [super initWithFrame:frame];
    if(self){
        _style = style;
        _delegate = delegate;
        
        [self prepare];
        [self placeSubViews];
    }
    return self;
}

#pragma mark - 公共方法

- (void)reloadDataWithChildViewControllers:(NSArray*)childViewControllers{
    [self reloadDataWithChildViewControllers:childViewControllers defaultIndex:0];
}

- (void)reloadDataWithChildViewControllers:(NSArray*)childViewControllers defaultIndex:(NSUInteger)defaultIndex{
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        if([obj isKindOfClass:[UIViewController class]]){
            [((UIViewController*)obj).view removeFromSuperview];
        }else if([obj isKindOfClass:[UIView class]]){
            [((UIView*)obj) removeFromSuperview];
        }else{
            NSAssert(NO, @"Must be UIVIewCOntroller or a subclass of UIVIew");
        }
    }];
    [self.childViewControllers removeAllObjects];
    
    [self.childViewControllers addObjectsFromArray:childViewControllers];
    //刷新
    [self.collectionView reloadData];
    
    [self scrollToIndex:defaultIndex animated:NO];
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated{
    _forbidTouchToAdjustPosition = YES;
    
    _oldIndex = _currentIndex;
    _currentIndex = index;
    _changeAnimated = YES;
    
    CGFloat offsetX = index * self.collectionView.bounds.size.width;
    
    if (animated) {
        CGFloat delta = offsetX - self.collectionView.contentOffset.x;
        NSInteger page = fabs(delta)/self.collectionView.bounds.size.width;
        if (page >= 2) {// 需要滚动两页以上的时候, 跳过中间页的动画
            _changeAnimated = NO;
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakself) strongSelf = weakself;
                if (strongSelf) {
                    [strongSelf.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
                }
            });
        }
        else {
            [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
        }
    }
    else {
        [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    }
}

#pragma mark - 私有方法

/**
 准备
 */
- (void)prepare{
    //初始化变量
    _oldIndex = -1;
    _currentIndex = 0;
    _oldOffSetX = 0.0f;
    _forbidTouchToAdjustPosition = NO;
    
    //添加视图
    [self addSubview:self.collectionView];
}

/**
 排列位置
 */
- (void)placeSubViews{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

/**
 滑动

 @param fromIndex 开始的序号
 @param toIndex 结束的序号
 @param progress 进度
 */
- (void)contentViewDidMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollWithProgress:fromIndex:toIndex:)]) {
        [self.delegate scrollWithProgress:progress fromIndex:fromIndex toIndex:toIndex];
    }
}

/**
 调整位置

 @param index 序号
 */
- (void)adjustSegmentTitleOffsetToCurrentIndex:(NSInteger)index {
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrolToIndex:)]) {
        [self.delegate scrolToIndex:index];
    }
}

#pragma mark - 私有方法：子视图生命周期相关

/**
 将要显示

 @param index 序号
 */
- (void)willAppearWithIndex:(NSUInteger)index{
    id<MISScrollPageControllerContentSubViewControllerDelegate> controller = [self.childViewControllers objectAtIndex:index];
    if (controller) {
        if ([controller respondsToSelector:@selector(viewWillAppearForIndex:)]) {
            [controller viewWillAppearForIndex:index];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewController:willAppearForIndex:)]) {
            [_delegate scrollPageController:nil childViewController:_currentChildViewController willAppearForIndex:index];
        }
    }
}

/**
 已经显示

 @param index 序号
 */
- (void)didAppearWithIndex:(NSUInteger)index{
    id<MISScrollPageControllerContentSubViewControllerDelegate> controller = [self.childViewControllers objectAtIndex:index];
    if (controller) {
        if ([controller respondsToSelector:@selector(viewDidAppearForIndex:)]) {
            [controller viewDidAppearForIndex:index];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewController:didAppearForIndex:)]) {
            [_delegate scrollPageController:nil childViewController:_currentChildViewController didAppearForIndex:index];
        }
    }
}

/**
 将要消失

 @param index  序号
 */
- (void)willDisappearWithIndex:(NSInteger)index{
    id<MISScrollPageControllerContentSubViewControllerDelegate> controller = [self.childViewControllers objectAtIndex:index];
    if (controller) {
        if ([controller respondsToSelector:@selector(viewWillDisappearForIndex:)]) {
            [controller viewWillDisappearForIndex:index];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewController:willDisappearForIndex:)]) {
            [_delegate scrollPageController:nil childViewController:_currentChildViewController willDisappearForIndex:index];
        }
    }
}

/**
 已经消失

 @param index 序号
 */
- (void)didDisappearWithIndex:(NSUInteger)index{
    id<MISScrollPageControllerContentSubViewControllerDelegate> controller = [self.childViewControllers objectAtIndex:index];
    if (controller) {
        if ([controller respondsToSelector:@selector(viewDidDisappearForIndex:)]) {
            [controller viewDidDisappearForIndex:index];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(scrollPageController:childViewController:didDisappearForIndex:)]) {
            [_delegate scrollPageController:nil childViewController:_currentChildViewController didDisappearForIndex:index];
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:UICollectionViewCellIdentifier forIndexPath:indexPath];
    // 移除subviews 避免重用内容显示错误
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentChildViewController = [self.childViewControllers objectAtIndex:indexPath.row];
    if(_currentChildViewController && [_currentChildViewController conformsToProtocol:@protocol(MISScrollPageControllerContentSubViewControllerDelegate)]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(childViewController:forIndex:)]){
            [self.delegate childViewController:_currentChildViewController forIndex:indexPath.row];
        }
        
        //添加到父容器
        
        if([_currentChildViewController isKindOfClass:[UIViewController class]]){
            ((UIViewController*)_currentChildViewController).view.frame = self.bounds;
            [cell.contentView addSubview:((UIViewController*)_currentChildViewController).view];
        }else if([_currentChildViewController isKindOfClass:[UIView class]]){
            ((UIView*)_currentChildViewController).frame = self.bounds;
            [cell.contentView addSubview:((UIView*)_currentChildViewController)];
        }else{
            NSAssert(NO, @"Must be UIVIewCOntroller or a subclass of UIVIew");
        }
        
        BOOL isFirstLoaded = NO;
        if([_currentChildViewController respondsToSelector:@selector(hasAlreadyLoaded)]){
            isFirstLoaded = ![_currentChildViewController hasAlreadyLoaded];
        }
        
        if (self.forbidTouchToAdjustPosition && !_changeAnimated) {
            [self willAppearWithIndex:_currentIndex];
            if (isFirstLoaded) {
                // viewDidLoad
                if ([_currentChildViewController respondsToSelector:@selector(viewDidLoadedForIndex:)]) {
                    [_currentChildViewController viewDidLoadedForIndex:indexPath.row];
                }
            }
            [self didAppearWithIndex:_currentIndex];
            
        }
        else {
            [self willAppearWithIndex:indexPath.row];
            if (isFirstLoaded) {
                // viewDidLoad
                if ([_currentChildViewController respondsToSelector:@selector(viewDidLoadedForIndex:)]) {
                    [_currentChildViewController viewDidLoadedForIndex:indexPath.row];
                }
            }
            [self willDisappearWithIndex:_oldIndex];
            
        }
        
    }else{
        //子控制器或者视图必须遵循MISScrollPageControllerContentSubViewControllerDelegate这个协议
        NSAssert(NO, @"Subcontrollers or views must follow the MISScrollPageControllerContentSubViewControllerDelegate protocol");
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_currentIndex == indexPath.row) {// 没有滚动完成
        [self didAppearWithIndex:_oldIndex];
        [self didDisappearWithIndex:indexPath.row];
    }
    else {
        if (_oldIndex == indexPath.row) {
            // 滚动完成
            if (self.forbidTouchToAdjustPosition && !_changeAnimated) {
                [self willDisappearWithIndex:_oldIndex];
                [self didDisappearWithIndex:_oldIndex];
            }
            else {
                [self didAppearWithIndex:_currentIndex];
                [self didDisappearWithIndex:indexPath.row];
            }
        }
        else {
            // 滚动没有完成又快速的反向打开了另一页
            [self didAppearWithIndex:_oldIndex];
            [self didDisappearWithIndex:indexPath.row];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.forbidTouchToAdjustPosition || // 点击标题滚动
        scrollView.contentOffset.x <= 0 || // first or last
        scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width) {
        return;
    }
    
    CGFloat tempProgress = scrollView.contentOffset.x / self.bounds.size.width;
    NSInteger tempIndex = tempProgress;
    
    CGFloat progress = tempProgress - floor(tempProgress);
    CGFloat deltaX = scrollView.contentOffset.x - _oldOffSetX;
    
    if (deltaX > 0) {// 向右
        if (progress == 0.0) {
            return;
        }
        self.currentIndex = tempIndex+1;
        self.oldIndex = tempIndex;
    }
    else if (deltaX < 0) {
        progress = 1.0 - progress;
        self.oldIndex = tempIndex+1;
        self.currentIndex = tempIndex;
    }
    else {
        return;
    }
    
    [self contentViewDidMoveFromIndex:_oldIndex toIndex:_currentIndex progress:progress];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = (scrollView.contentOffset.x / self.bounds.size.width);
    [self contentViewDidMoveFromIndex:currentIndex toIndex:currentIndex progress:1.0];
    
    // 调整title
    [self adjustSegmentTitleOffsetToCurrentIndex:currentIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _oldOffSetX = scrollView.contentOffset.x;
    self.forbidTouchToAdjustPosition = NO;
}

@end
