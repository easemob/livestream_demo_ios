//
//  EaseLiveCastView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/26.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseLiveHeaderListView.h"

@class EasePublishModel;
@interface EaseLiveCastView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(EasePublishModel*)model;

@property (nonatomic, weak) id<EaseLiveHeaderListViewDelegate> delegate;

@end
