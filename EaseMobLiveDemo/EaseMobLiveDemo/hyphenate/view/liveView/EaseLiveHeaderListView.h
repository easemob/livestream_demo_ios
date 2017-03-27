//
//  EaseLiveHeaderListView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/15.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EaseLiveHeaderListViewDelegate <NSObject>

- (void)didSelectHeaderWithUsername:(NSString*)username;

@end

@class EasePublishModel;
@class EaseLiveRoom;
@interface EaseLiveHeaderListView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(EasePublishModel*)model;

- (instancetype)initWithFrame:(CGRect)frame room:(EaseLiveRoom*)room;

@property (nonatomic, weak) id<EaseLiveHeaderListViewDelegate> delegate;

- (void)loadHeaderListWithChatroomId:(NSString*)chatroomId;

- (void)joinChatroomWithUsername:(NSString*)username;

- (void)leaveChatroomWithUsername:(NSString*)username;

@end
