//
//  MISScrollPageSegmentStyle.m
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageStyle.h"

@implementation MISScrollPageStyle

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化所有的变量
        _IOSSegment = NO;
        _IOSSegmentItemWidth = 0;
        _IOSSegmentNormalColor = UIColor.whiteColor;
        _IOSSegmentTintColor = UIColor.blackColor;
        
        _showCover = NO;
        _showLine = NO;
        _showSegmentViewShadow = NO;
        _scaleTitle = NO;
        _scrollTitle = YES;
        _segmentViewBounces = YES;
        _contentViewBounces = YES;
        _gradualChangeTitleColor = NO;
        _showSegmentViewSeparatorLine = YES;
        _scrollContentView = YES;
        _adjustCoverOrLineWidth = NO;
        _autoAdjustTitlesWidth = NO;
        _animatedContentViewWhenTitleClicked = YES;
        _canSlideToGoBack = YES;
        
        _scrollLineHeight = 2.f;
        _scrollLineColor = [UIColor lightGrayColor];
        _segmentViewBackgroundColor = [UIColor whiteColor];
        _segmentViewBackgroundImage = nil;
        _segmentViewShadowWidth = 20;
        _segmentViewShadowColor = UIColor.whiteColor;
        _segmentViewShadowOpacity = 1.f;
        _segmentViewSeparatorLineColor = [UIColor colorWithRed:0xf0/255.0f green:0xf0/255.0f blue:0xf0/255.0f alpha:1.0];
        _coverBackgroundColor = [UIColor lightGrayColor];
        _animateDuration = 0.3;
        _coverCornerRadius = 14.f;
        _coverHeight = 28.f;
        _titleMargin = 15.f;
        _titleFont = [UIFont systemFontOfSize:14.f];
        _titleBigScale = 1.3f;
        _normalTitleColor = [UIColor lightGrayColor];
        _selectedTitleColor = [UIColor redColor];
        _segmentHeight = 44.f;
    }
    return self;
}

@end
