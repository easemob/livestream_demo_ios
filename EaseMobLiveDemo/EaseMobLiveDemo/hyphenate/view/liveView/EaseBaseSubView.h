//
//  EaseBaseSubView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EaseBaseSubView;
@protocol TapBackgroundViewDelegate <NSObject>

- (void)didTapBackgroundView:(EaseBaseSubView*)profileView;

@end

@interface EaseBaseSubView : UIView

@property (nonatomic, weak) id<TapBackgroundViewDelegate> delegate;

- (void)showFromParentView:(UIView*)view;

- (void)removeFromParentView;

@end
