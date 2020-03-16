//
//  EaseChatView.h
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

- (void)didReceivePraiseMessage:(EMMessage *)message;

- (void)didSelectUserWithMessage:(EMMessage*)message;

//- (void)didSelectAdminButton:(BOOL)isOwner;

- (void)didSelectGiftButton:(BOOL)isOwner;//礼物

- (void)didSelectedExitButton;

- (void)didSelectedBarrageSwitch:(EMMessage*)msg;

- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count;//观众送礼物

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


- (void)sendMessageAtWithUsername:(NSString*)username;

- (void)sendGiftAction:(NSString *)giftId num:(NSInteger)num completion:(void (^)(BOOL success))aCompletion;

@end
