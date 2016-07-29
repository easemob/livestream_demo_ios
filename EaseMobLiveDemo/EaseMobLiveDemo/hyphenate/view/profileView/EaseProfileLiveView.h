//
//  EaseProfileLiveView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseBaseSubView.h"

@protocol EaseProfileLiveViewDelegate <NSObject>

- (void)didSelectReplyWithUsername:(NSString*)username;

- (void)didSelectMessageWithUsername:(NSString*)username;

@end

@interface EaseProfileLiveView : EaseBaseSubView

@property (nonatomic, weak) id<EaseProfileLiveViewDelegate> delegate;

- (instancetype)initWithUsername:(NSString*)username;

@end
