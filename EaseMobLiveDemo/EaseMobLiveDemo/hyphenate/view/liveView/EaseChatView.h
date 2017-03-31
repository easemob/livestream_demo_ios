//
//  EaseChatView.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMMessage;
@class EaseLiveRoom;
@protocol EaseChatViewDelegate <NSObject>

@optional

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight;

- (void)didReceiveGiftWithCMDMessage:(EMMessage*)message;

- (void)didReceiveBarrageWithCMDMessage:(EMMessage*)message;

- (void)didReceivePraiseWithCMDMessage:(EMMessage *)message;

- (void)didSelectUserWithMessage:(EMMessage*)message;

- (void)didSelectChangeCameraButton;

- (void)didSelectAdminButton:(BOOL)isOwner;

@end

@interface EaseChatView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId;

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
                    isPublish:(BOOL)isPublish;

- (instancetype)initWithFrame:(CGRect)frame
                         room:(EaseLiveRoom*)room
                    isPublish:(BOOL)isPublish;

@property (nonatomic, weak) id<EaseChatViewDelegate> delegate;

- (void)joinChatroomWithIsCount:(BOOL)aIsCount
                     completion:(void (^)(BOOL success))aCompletion;

- (void)leaveChatroomWithIsCount:(BOOL)aIsCount
                      completion:(void (^)(BOOL success))aCompletion;

- (void)sendGiftWithId:(NSString*)giftId;

- (void)sendMessageAtWithUsername:(NSString*)username;

@end
