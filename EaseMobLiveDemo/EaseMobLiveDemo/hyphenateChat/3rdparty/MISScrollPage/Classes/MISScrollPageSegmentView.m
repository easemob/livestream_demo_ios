//
//  MISScrollPageSegmentView.m
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageSegmentView.h"
#import "UIView+MISHelper.h"
#import "UIView+MISRedPoint.h"


static CGFloat const xGap = 5.0;
static CGFloat const wGap = 2 * xGap;
static CGFloat const contentSizeXOff = 20.0;

@interface MISScrollPageSegmentView () <UIScrollViewDelegate>

#pragma mark - 属性

/**
 当前的宽度
 */
@property (nonatomic, assign) CGFloat currentWidth;

/**
 当前的序号
 */
@property (nonatomic, assign) NSUInteger currentIndex;

/**
 记录的上次的序号
 */
@property (nonatomic, assign) NSUInteger oldIndex;

#pragma mark - 属性：视图，IOS

/**
 segmentControl
 */
@property (nonatomic) UISegmentedControl* segmentControl;

#pragma mark - 属性：视图

/**
 滚动线条
 */
@property (nonatomic) UIView* scrollLine;

/**
 遮罩视图
 */
@property (nonatomic) UIView* coverLayer;

/**
 滚动视图
 */
@property (nonatomic) UIScrollView* scrollView;

/**
 背景图片
 */
@property (nonatomic) UIImageView* backgroundImageView;

/**
 左边的阴影
 */
@property (nonatomic) UIView* leftShadowView;

/**
 右边的阴影
 */
@property (nonatomic) UIView* rightShadowView;

#pragma mark - 属性： 数值

/**
 颜色渐变是用的
 */
@property (strong, nonatomic) NSArray *deltaRGB;
@property (strong, nonatomic) NSArray *selectedColorRgb;
@property (strong, nonatomic) NSArray *normalColorRgb;


/**
 缓存所有的标题的Label
 */
@property (nonatomic, strong) NSMutableArray *titleViews;

/**
 缓存计算出来的每个标题的宽度
 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

@end

@implementation MISScrollPageSegmentView

#pragma mark - Getter

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = self.style.isSegmentViewBounces;
        _scrollView.pagingEnabled = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    return _backgroundImageView;
}

- (UIView*)leftShadowView{
    if(!_leftShadowView){
        _leftShadowView = [[UIView alloc] init];
    }
    return _leftShadowView;
}

- (UIView*)rightShadowView{
    if(!_rightShadowView){
        _rightShadowView = [[UIView alloc] init];
    }
    return _rightShadowView;
}

- (UIView *)scrollLine {
    if (!self.style.isShowLine) {
        return nil;
    }
    
    if (!_scrollLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = self.style.scrollLineColor;
        _scrollLine = lineView;
    }
    return _scrollLine;
}

- (UIView *)coverLayer {
    if (!self.style.isShowCover) {
        return nil;
    }
    
    if (_coverLayer == nil) {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = self.style.coverBackgroundColor;
        coverView.layer.cornerRadius = self.style.coverCornerRadius;
        coverView.layer.masksToBounds = YES;
        _coverLayer = coverView;
    }
    return _coverLayer;
}

- (NSMutableArray*)titleViews{
    if(!_titleViews){
        _titleViews = [[NSMutableArray alloc] init];
    }
    return _titleViews;
}

- (NSMutableArray*)titleWidths{
    if(!_titleWidths){
        _titleWidths = [[NSMutableArray alloc] init];
    }
    return _titleWidths;
}

- (NSArray *)deltaRGB {
    if (_deltaRGB == nil) {
        NSArray *normalColorRgb = self.normalColorRgb;
        NSArray *selectedColorRgb = self.selectedColorRgb;
        
        NSArray *delta;
        if (normalColorRgb && selectedColorRgb) {
            CGFloat deltaR = [normalColorRgb[0] floatValue] - [selectedColorRgb[0] floatValue];
            CGFloat deltaG = [normalColorRgb[1] floatValue] - [selectedColorRgb[1] floatValue];
            CGFloat deltaB = [normalColorRgb[2] floatValue] - [selectedColorRgb[2] floatValue];
            delta = [NSArray arrayWithObjects:@(deltaR), @(deltaG), @(deltaB), nil];
            _deltaRGB = delta;
            
        }
    }
    return _deltaRGB;
}

- (NSArray *)normalColorRgb {
    if (!_normalColorRgb) {
        NSArray *normalColorRgb = [self getColorRgb:self.style.normalTitleColor];
        NSAssert(normalColorRgb, @"When setting the text color of the normal state, please use the color value of the RGB space");
        _normalColorRgb = normalColorRgb;
        
    }
    return  _normalColorRgb;
}

- (NSArray *)selectedColorRgb {
    if (!_selectedColorRgb) {
        NSArray *selectedColorRgb = [self getColorRgb:self.style.selectedTitleColor];
        NSAssert(selectedColorRgb, @"When setting the text color of the selected state, please use the color value of the RGB space");
        _selectedColorRgb = selectedColorRgb;
    }
    return  _selectedColorRgb;
}

- (UISegmentedControl*)segmentControl{
    if(!_segmentControl){
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[]];
        [_segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame style:(MISScrollPageStyle*)style titles:(NSArray*)titles delegate:(id<MISScrollPageControllerDelegate>)delegate titleTapedBlock:(TitleBtnTapedBlock)titleTapedBlock{
    self = [super initWithFrame:frame];
    if(self){
        _style = style;
        _titles = titles;
        _titleTapedBlock = titleTapedBlock;
        _delegate = delegate;
        
        _currentIndex = 0;
        _oldIndex = 0;
        _currentWidth = frame.size.width;
        
        if(_style.isIOSSegment){
            //用系统的SegmentControl
        }else{
            if(self.style.isShowSegmentViewSeparatorLine){
                CGFloat onePX = 1.0 / UIScreen.mainScreen.scale;
                CALayer* lineLayer = [[CAShapeLayer alloc] init];
                lineLayer.frame = CGRectMake(0, CGRectGetHeight(frame) - onePX, CGRectGetWidth(frame), onePX);
                lineLayer.backgroundColor = self.style.segmentViewSeparatorLineColor.CGColor;
                [self.layer insertSublayer:lineLayer atIndex:0];
            }
            
            if (!self.style.isScrollTitle) {
                // 不能滚动的时候就不要把缩放和遮盖或者滚动条同时使用, 否则显示效果不好
                self.style.scaleTitle = !(self.style.isShowCover || self.style.isShowLine);
            }
        }
        
        self.backgroundColor = self.style.segmentViewBackgroundColor;
        self.backgroundImageView.image = self.style.segmentViewBackgroundImage;
    }
    return self;
}

#pragma mark - 生命周期

- (void)layoutSubviews{
    [super layoutSubviews];
    if(_style.isIOSSegment){
        self.segmentControl.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

#pragma mark - 公共方法

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated{
//    MISLog(@"self.titles.count --- %lu", (unsigned long)self.titles.count);
    NSAssert(selectedIndex >= 0 && selectedIndex < self.titles.count, @"The set selectedIndex is invalid!!");
    
    if (selectedIndex < 0 || selectedIndex >= self.titles.count) {
        return;
    }
    
    _currentIndex = selectedIndex;
    [self adjustUIAnimated:YES whenButtonTaped:NO];
}

- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles{
    [self reloadWithNewTitles:newTitles defaultIndex:0];
}

- (void)reloadWithNewTitles:(NSArray<NSString *> *)newTitles defaultIndex:(NSUInteger)defaultIndex{
    if(_style.isIOSSegment){
    }else{
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    _currentIndex = defaultIndex;
    _oldIndex = defaultIndex;
    self.titleWidths = nil;
    self.titleViews = nil;
    self.titles = nil;
    self.titles = [newTitles copy];
    if (self.titles.count == 0) return;
    
    [self prepare];
    [self placeSubViews];
    [self setSelectedIndex:_currentIndex animated:YES];
}

- (void)adjustTitleOffSetToCurrentIndex:(NSInteger)currentIndex{
    _oldIndex = currentIndex;
    // 重置渐变/缩放效果附近其他item的缩放和颜色
    
    if(_style.isIOSSegment){
        [self.segmentControl setSelectedSegmentIndex:currentIndex];
        return;
    }
    
    __weak __typeof(self) wkSelf = self;
    [self.titleViews enumerateObjectsUsingBlock:^(MISScrollPageSegmentTitleView* titleView, NSUInteger index, BOOL * stop) {
        if (index != currentIndex) {
            titleView.textColor = wkSelf.style.normalTitleColor;
            titleView.currentTransformSx = 1.0;
            titleView.selected = NO;
        }
        else {
            titleView.textColor = wkSelf.style.selectedTitleColor;
            if (wkSelf.style.isScaleTitle) {
                titleView.currentTransformSx = wkSelf.style.titleBigScale;
            }
            titleView.selected = YES;
        }
    }];
    
    if (self.scrollView.contentSize.width != self.scrollView.bounds.size.width + contentSizeXOff) {
        //需要滚动
        //当前的标题视图
        MISScrollPageSegmentTitleView* currentTitleView = (MISScrollPageSegmentTitleView *)self.titleViews[currentIndex];
        
        CGFloat offSetx = currentTitleView.center.x - _currentWidth * 0.5;
        if (offSetx < 0) {
            offSetx = 0;
            
        }
        
        CGFloat maxOffSetX = self.scrollView.contentSize.width - _currentWidth;
        
        if (maxOffSetX < 0) {
            maxOffSetX = 0;
        }
        
        if (offSetx > maxOffSetX) {
            offSetx = maxOffSetX;
        }
        
        [self.scrollView setContentOffset:CGPointMake(offSetx, 0.0) animated:YES];
    }
}

- (void)adjustUIWithProgress:(CGFloat)progress oldIndex:(NSInteger)oldIndex currentIndex:(NSInteger)currentIndex{
    if (oldIndex < 0 || oldIndex >= self.titles.count || currentIndex < 0 || currentIndex >= self.titles.count
        ) {
        //数据不合法，返回
        return;
    }
    
    _oldIndex = currentIndex;
    
    if(_style.isIOSSegment){
        return;
    }
    
    MISScrollPageSegmentTitleView* oldTitleView = (MISScrollPageSegmentTitleView*)self.titleViews[oldIndex];
    MISScrollPageSegmentTitleView*currentTitleView = (MISScrollPageSegmentTitleView *)self.titleViews[currentIndex];
    
    CGFloat xDistance = currentTitleView.mis_x - oldTitleView.mis_x;
    CGFloat wDistance = currentTitleView.mis_w - oldTitleView.mis_w;
    
    if (self.scrollLine) {
        //下划线
        if (self.style.isScrollTitle) {
            self.scrollLine.mis_x = oldTitleView.mis_x + xDistance * progress;
            self.scrollLine.mis_w = oldTitleView.mis_w + wDistance * progress;
        } else {
            if (self.style.isAdjustCoverOrLineWidth) {
                CGFloat oldScrollLineW = [self.titleWidths[oldIndex] floatValue] + wGap;
                CGFloat currentScrollLineW = [self.titleWidths[currentIndex] floatValue] + wGap;
                wDistance = currentScrollLineW - oldScrollLineW;
                
                CGFloat oldScrollLineX = oldTitleView.mis_x + (oldTitleView.mis_w - oldScrollLineW) * 0.5;
                CGFloat currentScrollLineX = currentTitleView.mis_x + (currentTitleView.mis_w - currentScrollLineW) * 0.5;
                xDistance = currentScrollLineX - oldScrollLineX;
                self.scrollLine.mis_x = oldScrollLineX + xDistance * progress;
                self.scrollLine.mis_w = oldScrollLineW + wDistance * progress;
            } else {
                self.scrollLine.mis_x = oldTitleView.mis_x + xDistance * progress;
                self.scrollLine.mis_w = oldTitleView.mis_w + wDistance * progress;
            }
        }
    }
    
    if (self.coverLayer) {
        //遮罩
        if (self.style.isScrollTitle) {
            self.coverLayer.mis_x = oldTitleView.mis_x + xDistance * progress - xGap;
            self.coverLayer.mis_w = oldTitleView.mis_w + wDistance * progress + wGap;
        } else {
            if (self.style.isAdjustCoverOrLineWidth) {
                CGFloat oldCoverW = [self.titleWidths[oldIndex] floatValue] + wGap;
                CGFloat currentCoverW = [self.titleWidths[currentIndex] floatValue] + wGap;
                wDistance = currentCoverW - oldCoverW;
                CGFloat oldCoverX = oldTitleView.mis_x + (oldTitleView.mis_w - oldCoverW) * 0.5;
                CGFloat currentCoverX = currentTitleView.mis_x + (currentTitleView.mis_w - currentCoverW) * 0.5;
                xDistance = currentCoverX - oldCoverX;
                self.coverLayer.mis_x = oldCoverX + xDistance * progress;
                self.coverLayer.mis_w = oldCoverW + wDistance * progress;
            } else {
                self.coverLayer.mis_x = oldTitleView.mis_x + xDistance * progress;
                self.coverLayer.mis_w = oldTitleView.mis_w + wDistance * progress;
            }
        }
    }
    
    if (self.style.isGradualChangeTitleColor) {
        //剪标
        oldTitleView.textColor = [UIColor colorWithRed:[self.selectedColorRgb[0] floatValue] + [self.deltaRGB[0] floatValue] * progress green:[self.selectedColorRgb[1] floatValue] + [self.deltaRGB[1] floatValue] * progress blue:[self.selectedColorRgb[2] floatValue] + [self.deltaRGB[2] floatValue] * progress alpha:1.0];
        currentTitleView.textColor = [UIColor colorWithRed:[self.normalColorRgb[0] floatValue] - [self.deltaRGB[0] floatValue] * progress green:[self.normalColorRgb[1] floatValue] - [self.deltaRGB[1] floatValue] * progress blue:[self.normalColorRgb[2] floatValue] - [self.deltaRGB[2] floatValue] * progress alpha:1.0];
    }
    
    if (!self.style.isScaleTitle) {
        //标题不缩放，返回，下面是缩放标题的
        return;
    }
    
    CGFloat deltaScale = self.style.titleBigScale - 1.0;
    oldTitleView.currentTransformSx = self.style.titleBigScale - deltaScale * progress;
    currentTitleView.currentTransformSx = 1.0 + deltaScale * progress;
}

#pragma mark - 私有方法

/**
 准备
 */
- (void)prepare{
    self.clipsToBounds = YES;
    
    if(_style.isIOSSegment){
        //IOS系统的segmentControl
        [self.segmentControl setBackgroundColor:_style.IOSSegmentNormalColor];
        [self.segmentControl setTintColor:_style.IOSSegmentTintColor];
        [self addSubview:self.segmentControl];
    }else{
        //自定义
        if(!self.scrollView.superview){
            [self addSubview:self.scrollView];
        }
        
        if(self.style.isShowSegmentViewShadow){
            [self addSubview:self.leftShadowView];
            [self addSubview:self.rightShadowView];
        }
        
        [self addScrollLineOrCover];
    }
    
    [self prepareTitles];
}

/**
 排列子视图
 */
- (void)placeSubViews{
    if (self.titles.count == 0) {
        return;
    }
    
    if(_style.isIOSSegment){
        
    }else{
        [self setUpShadowView];
        
        [self setUpTitleViewsPosition];
        
        [self setupScrollLineAndCover];
        
        if (self.style.isScrollTitle) {
            // 设置滚动区域
            MISScrollPageSegmentTitleView* lastTitleView = (MISScrollPageSegmentTitleView*)self.titleViews.lastObject;
            
            if (lastTitleView) {
                self.scrollView.contentSize = CGSizeMake(lastTitleView.mis_rightX + contentSizeXOff, 0.0);
            }
        }
    }
}

/**
 添加线条或者遮罩
 */
- (void)addScrollLineOrCover{
    if (self.style.isShowLine) {
        if(!self.scrollLine.superview){
            [self.scrollView addSubview:self.scrollLine];
        }
    }
    
    if (self.style.isShowCover) {
        if(!self.coverLayer.superview){
            [self.scrollView insertSubview:self.coverLayer atIndex:0];
        }
    }
}

/**
 准备标题
 */
- (void)prepareTitles{
    if (self.titles.count == 0) {
        return;
    }
    __weak __typeof(self) weakSelf = self;
    if(_style.isIOSSegment){
        [self.segmentControl removeAllSegments];
        [self.titles enumerateObjectsUsingBlock:^(NSString* title, NSUInteger index, BOOL * stop) {
//            [weakSelf.segmentControl setTitle:title forSegmentAtIndex:index];
            [weakSelf.segmentControl insertSegmentWithTitle:title atIndex:index animated:NO];
            [weakSelf.segmentControl setWidth:weakSelf.style.IOSSegmentItemWidth forSegmentAtIndex:index];
        }];
    }else{
        [self.titles enumerateObjectsUsingBlock:^(NSString* title, NSUInteger index, BOOL * stop) {
            MISScrollPageSegmentTitleView *titleView = [[MISScrollPageSegmentTitleView alloc] initWithFrame:CGRectZero];
            titleView.tag = index;
            
            titleView.font = weakSelf.style.titleFont;
            titleView.text = title;
            titleView.textColor = weakSelf.style.normalTitleColor;
            
            titleView.MIS_redDot = [MISRedDot redDotWithConfig:({
                MISRedDotConfig *config = [[MISRedDotConfig alloc] init];
                config.offsetY = 2;
                config.offsetX = -2;
                config;
            })];
            titleView.MIS_redDot.hidden = YES;
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(generatedTitleView:forIndex:)]) {
                [weakSelf.delegate generatedTitleView:titleView forIndex:index];
            }
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(titleViewTaped:)];
            [titleView addGestureRecognizer:tapGes];
            
            CGFloat titleViewWidth = [titleView titleViewWidth];
            [weakSelf.titleWidths addObject:@(titleViewWidth)];
            [weakSelf.titleViews addObject:titleView];
            [weakSelf.scrollView addSubview:titleView];
        }];
    }
}

/**
 摆放阴影位置
 */
- (void)setUpShadowView{
    if(_leftShadowView && _leftShadowView.superview && self.style.isShowSegmentViewShadow){
        _leftShadowView.frame = CGRectMake(-self.style.segmentViewShadowWidth, 0, self.style.segmentViewShadowWidth, self.mis_h);
        _leftShadowView.clipsToBounds = NO;
        _leftShadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_leftShadowView.bounds].CGPath;
        _leftShadowView.layer.shadowRadius = self.style.segmentViewShadowWidth / 4.f;
        _leftShadowView.layer.shadowColor = self.style.segmentViewShadowColor.CGColor;
        _leftShadowView.layer.shadowOffset = CGSizeMake(self.style.segmentViewShadowWidth / 2, 0);
        _leftShadowView.layer.shadowOpacity = self.style.segmentViewShadowOpacity;
    }
    if(_rightShadowView && _rightShadowView.superview && self.style.isShowSegmentViewShadow){
        _rightShadowView.frame = CGRectMake(self.mis_w, 0, self.style.segmentViewShadowWidth, self.mis_h);
        _rightShadowView.clipsToBounds = NO;
        _rightShadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_leftShadowView.bounds].CGPath;
        _rightShadowView.layer.shadowRadius = self.style.segmentViewShadowWidth / 4.f;
        _rightShadowView.layer.shadowColor = self.style.segmentViewShadowColor.CGColor;
        _rightShadowView.layer.shadowOffset = CGSizeMake(-self.style.segmentViewShadowWidth / 2.f, 0);
        _rightShadowView.layer.shadowOpacity = self.style.segmentViewShadowOpacity;
    }
}

/**
 设置所有的标题的位置
 */
- (void)setUpTitleViewsPosition{
    __block CGFloat titleX = 0.0;
    CGFloat titleY = 0.0;
    __block CGFloat titleW = 0.0;
    //每个标题视图的高度
    CGFloat titleH = self.mis_h - self.style.scrollLineHeight;
    
    if(!self.style.isScrollTitle){
        //所有的标题不能滚动，平分宽度
        titleW = self.scrollView.mis_w / self.titles.count;
        //遍历视图数组
        [self.titleViews enumerateObjectsUsingBlock:^(MISScrollPageSegmentTitleView* titleView, NSUInteger index, BOOL* stop) {
            titleX = index * titleW;
            
            titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
        }];
    }else{
        //所有的标题可以滚动
        //上一个标题的最右边的X坐标，一开始只有间距
        __block float lastLableMaxX = self.style.titleMargin;
        float addedMargin = 0.0f;
        
        if (self.style.isAutoAdjustTitlesWidth) {
            
            float allTitlesWidth = self.style.titleMargin;
            for (int i = 0; i < self.titleWidths.count; i++) {
                allTitlesWidth = allTitlesWidth + [self.titleWidths[i] floatValue] + self.style.titleMargin;
            }
            
            addedMargin = allTitlesWidth < self.scrollView.bounds.size.width ? (self.scrollView.bounds.size.width - allTitlesWidth) / self.titleWidths.count : 0 ;
        }
        
        //遍历视图数组
        __weak __typeof(self) weakSelf = self;
        [self.titleViews enumerateObjectsUsingBlock:^(MISScrollPageSegmentTitleView* titleView, NSUInteger index, BOOL* stop) {
            titleW = [weakSelf.titleWidths[index] floatValue];
            titleX = lastLableMaxX + addedMargin / 2;
            
            lastLableMaxX += (titleW + addedMargin + weakSelf.style.titleMargin);
            
            titleView.frame = CGRectMake(titleX, titleY, titleW, titleH);
        }];
    }
    
    MISScrollPageSegmentTitleView* currentTitleView = (MISScrollPageSegmentTitleView*)self.titleViews[_currentIndex];
    currentTitleView.currentTransformSx = 1.0;
    if (currentTitleView) {
        // 缩放, 设置初始的label的transform
        if (self.style.isScaleTitle) {
            currentTitleView.currentTransformSx = self.style.titleBigScale;
        }
        // 设置初始状态文字的颜色
        currentTitleView.textColor = self.style.selectedTitleColor;
    }
}

/**
 设置线条或者遮罩的位置
 */
- (void)setupScrollLineAndCover{
    MISScrollPageSegmentTitleView* defaultTitleView = (MISScrollPageSegmentTitleView*)self.titleViews[_currentIndex];
    CGFloat coverX = defaultTitleView.mis_x;
    CGFloat coverW = defaultTitleView.mis_w;
    CGFloat coverH = self.style.coverHeight;
    CGFloat coverY = (self.mis_h - coverH) * 0.5;
    
    if(self.scrollLine){
        //显示线条
        if(self.style.isShowLine){
            self.scrollLine.frame = CGRectMake(coverX , self.mis_h - self.style.scrollLineHeight, coverW , self.style.scrollLineHeight);
        }else{
            if (self.style.isAdjustCoverOrLineWidth) {
                coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                coverX = (defaultTitleView.mis_w - coverW) * 0.5;
            }
            
            self.scrollLine.frame = CGRectMake(coverX , self.mis_h - self.style.scrollLineHeight, coverW , self.style.scrollLineHeight);
        }
    }
    
    if(self.coverLayer){
        if(self.style.isShowLine){
            self.coverLayer.frame = CGRectMake(coverX - xGap, coverY, coverW + wGap, coverH);
        }else{
            if (self.style.isAdjustCoverOrLineWidth) {
                coverW = [self.titleWidths[_currentIndex] floatValue] + wGap;
                coverX = (defaultTitleView.mis_w - coverW) * 0.5;
            }
            
            self.coverLayer.frame = CGRectMake(coverX, coverY, coverW, coverH);
        }
    }
}

/**
 刷新视图

 @param animated 是不是要动画
 @param taped 是不是主动点击的按钮
 */
- (void)adjustUIAnimated:(BOOL)animated whenButtonTaped:(BOOL)taped{
    if (_currentIndex == _oldIndex && taped) {
        //点击同一个按钮直接返回
        return;
    }
    MISScrollPageSegmentTitleView* currentTitleView = nil;
    if(_style.isIOSSegment){
        //系统的segmentControl
        [self.segmentControl setSelectedSegmentIndex:_currentIndex];
    }else{
        //记录的上一次的标题视图
        MISScrollPageSegmentTitleView* oldTitleView = (MISScrollPageSegmentTitleView*)self.titleViews[_oldIndex];
        //当前的标题视图
        currentTitleView = (MISScrollPageSegmentTitleView *)self.titleViews[_currentIndex];
        
        //动画时间
        CGFloat animateDuration = animated ? self.style.animateDuration : 0.0;
        
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:animateDuration animations:^{
            oldTitleView.textColor = weakSelf.style.normalTitleColor;
            currentTitleView.textColor = weakSelf.style.selectedTitleColor;
            oldTitleView.selected = NO;
            currentTitleView.selected = YES;
            if (weakSelf.style.isScaleTitle) {
                oldTitleView.currentTransformSx = 1.0;
                currentTitleView.currentTransformSx = weakSelf.style.titleBigScale;
            }
            
            if (weakSelf.scrollLine) {
                if (weakSelf.style.isScrollTitle) {
                    weakSelf.scrollLine.mis_x = currentTitleView.mis_x;
                    weakSelf.scrollLine.mis_w = currentTitleView.mis_w;
                } else {
                    if (weakSelf.style.isAdjustCoverOrLineWidth) {
                        CGFloat scrollLineW = [weakSelf.titleWidths[weakSelf.currentIndex] floatValue] + wGap;
                        CGFloat scrollLineX = currentTitleView.mis_x + (currentTitleView.mis_w - scrollLineW) * 0.5;
                        weakSelf.scrollLine.mis_x = scrollLineX;
                        weakSelf.scrollLine.mis_w = scrollLineW;
                    } else {
                        weakSelf.scrollLine.mis_x = currentTitleView.mis_x;
                        weakSelf.scrollLine.mis_w = currentTitleView.mis_w;
                    }
                }
            }
            
            if (weakSelf.coverLayer) {
                if (weakSelf.style.isScrollTitle) {
                    weakSelf.coverLayer.mis_x = currentTitleView.mis_x - xGap;
                    weakSelf.coverLayer.mis_w = currentTitleView.mis_w + wGap;
                } else {
                    if (weakSelf.style.isAdjustCoverOrLineWidth) {
                        CGFloat coverW = [weakSelf.titleWidths[weakSelf.currentIndex] floatValue] + wGap;
                        CGFloat coverX = currentTitleView.mis_x + (currentTitleView.mis_w - coverW) * 0.5;
                        weakSelf.coverLayer.mis_x = coverX;
                        weakSelf.coverLayer.mis_w = coverW;
                    } else {
                        weakSelf.coverLayer.mis_x = currentTitleView.mis_x;
                        weakSelf.coverLayer.mis_w = currentTitleView.mis_w;
                    }
                }
            }
        } completion:^(BOOL finished) {
            [self adjustTitleOffSetToCurrentIndex:weakSelf.currentIndex];
        }];
    }
    
    
    
    //
    _oldIndex = _currentIndex;
    
    if(taped){
        //按钮点击，调用回调
        if (self.titleTapedBlock) {
            self.titleTapedBlock(currentTitleView, _currentIndex);
        }
    }
    
}


/**
 获取到颜色的RGB数组

 @param color 颜色
 @return 数组
 */
- (NSArray*)getColorRgb:(UIColor*)color {
    CGFloat numOfcomponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *rgbComponents;
    if (numOfcomponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        rgbComponents = [NSArray arrayWithObjects:@(components[0]), @(components[1]), @(components[2]), nil];
    }
    return rgbComponents;
}

#pragma mark - 事件

/**
 title点击事件响应

 @param gesture 手势
 */
- (void)titleViewTaped:(UITapGestureRecognizer*)gesture{
    MISScrollPageSegmentTitleView* currentLabel = (MISScrollPageSegmentTitleView *)gesture.view;
    if (!currentLabel) {
        return;
    }
    _currentIndex = currentLabel.tag;
    [self adjustUIAnimated:YES whenButtonTaped:YES];
}

/**
 segmentControl切换

 @param segmentControl 实例
 */
- (void)segmentControlValueChanged:(UISegmentedControl*)segmentControl{
    _currentIndex = segmentControl.selectedSegmentIndex;
    [self adjustUIAnimated:YES whenButtonTaped:YES];
}


/**
 重新绘制标题小红点

 @param isShow 是否显示小红点
 @param titleIndex 标题位置
 */
- (void)reloadTitleRedPointWithISShow:(BOOL)isShow withTitleIndex:(NSInteger)titleIndex {
    if (titleIndex > self.titleViews.count - 1) {
        return;
    }
    
    MISScrollPageSegmentTitleView *titleView = self.titleViews[titleIndex];
    titleView.MIS_redDot.hidden = !isShow;
}

@end
