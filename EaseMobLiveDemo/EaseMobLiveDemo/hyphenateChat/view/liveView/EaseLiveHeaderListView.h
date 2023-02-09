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

- (void)didClickAnchorCard:(EMUserInfo*)userInfo;

- (void)didSelectMemberListButton:(BOOL)isOwner currentMemberList:(NSMutableArray*)currentMemberList;

- (void)willCloseChatroom;

@end

@class EasePublishModel;
@class EaseLiveRoom;
@class EaseLiveCastView;
@interface EaseLiveHeaderListView : UIView

@property (nonatomic, strong) EaseLiveCastView *liveCastView;

- (instancetype)initWithFrame:(CGRect)frame
                     chatroom:(EMChatroom*)aChatroom
                    isPublish:(BOOL)isPublish;

@property (nonatomic, weak) id<EaseLiveHeaderListViewDelegate> delegate;

- (void)updateHeaderViewWithChatroom:(EMChatroom*)aChatroom;

- (void)setLiveCastDelegate;

- (void)stopTimer;

@end
