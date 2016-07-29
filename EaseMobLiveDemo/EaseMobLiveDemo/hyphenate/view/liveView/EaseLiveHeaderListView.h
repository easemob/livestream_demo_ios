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

@interface EaseLiveHeaderListView : UIView

@property (nonatomic, weak) id<EaseLiveHeaderListViewDelegate> delegate;

- (void)loadHeaderListWithChatroomId:(NSString*)chatroomId;

- (void)joinChatroomWithUsername:(NSString*)username;

- (void)leaveChatroomWithUsername:(NSString*)username;

@end
