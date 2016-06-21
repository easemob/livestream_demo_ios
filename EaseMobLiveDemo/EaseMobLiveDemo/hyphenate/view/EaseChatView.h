//
//  EaseChatView.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMMessage;
@protocol EaseChatViewDelegate <NSObject>

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight;

- (void)didReceiveGiftWithCMDMessage:(EMMessage*)message;

- (void)didReceiveBarrageWithCMDMessage:(EMMessage*)message;

- (void)didPressPrintScreenButton;

@end

@interface EaseChatView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId;

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
                    isPublish:(BOOL)isPublish;

@property (nonatomic, weak) id<EaseChatViewDelegate> delegate;

- (BOOL)joinChatroom;

- (BOOL)leaveChatroom;

@end
