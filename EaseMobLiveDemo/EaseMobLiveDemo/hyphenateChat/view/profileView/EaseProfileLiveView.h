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


@end

@interface EaseProfileLiveView : EaseBaseSubView

@property (nonatomic, weak) id<EaseProfileLiveViewDelegate> profileDelegate;

- (instancetype)initWithUsername:(NSString*)username
                      chatroomId:(NSString*)chatroomId
                         isOwner:(BOOL)isOwner;

- (instancetype)initWithUsername:(NSString*)username
                      chatroomId:(NSString*)chatroomId;

@end
