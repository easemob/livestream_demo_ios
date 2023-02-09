//  检测开始滑动的CollectionVIew
//  MISScrollPageCollectionView.m
//  TJJXT
//
//  Created by 敏梵 on 2016/11/19.
//  Copyright © 2016年 Eduapp. All rights reserved.
//

#import "MISScrollPageCollectionView.h"

@implementation MISScrollPageCollectionView

#pragma mark - 重写父类

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:self];
        CGPoint location = [gestureRecognizer locationInView:self];
        if (velocity.x > 0.0f && self.contentOffset.x <= 0 && location.x <= 50  && self.canPanToGoBack) {
            return NO;
        }
        return YES;
    }
    return NO;
}

@end
