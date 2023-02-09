//
//  EaseCustomMessageHelper.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/12.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger{
    customMessageType_praise,//点赞
    customMessageType_gift,//礼物
    customMessageType_barrage,//弹幕
}customMessageType;


NS_ASSUME_NONNULL_BEGIN

@class EMChatMessage;
@protocol EaseCustomMessageHelperDelegate <NSObject>

@optional

//观众点赞消息
- (void)didReceivePraiseMessage:(EMChatMessage *)message;

//弹幕消息
- (void)didSelectedBarrageSwitch:(EMChatMessage*)msg;

//观众刷礼物
- (void)steamerReceiveGiftId:(NSString *)giftId giftNum:(NSInteger )giftNum fromUser:(NSString *)userId ;

@end

@interface EaseCustomMessageHelper : NSObject


/// create a EaseCustomMessageHelper Instance
/// @param customMsgImp a delegate which implment EaseCustomMessageHelperDelegate
/// @param chatId a chatroom Id
- (instancetype)initWithCustomMsgImp:(id<EaseCustomMessageHelperDelegate>)customMsgImp chatId:(NSString*)chatId;

/*
 send custom message (gift,like,Barrage)
 @param text                 Message content
 @param num                  Number of message content
 @param messageType          chat type
 @param customMsgType        custom message type
 @param aCompletionBlock     send completion callback
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(EMChatType)messageType
            customMsgType:(customMessageType)customMsgType
               completion:(void (^)(EMChatMessage *message, EMError *error))aCompletionBlock;

/*
 send custom message (gift,like,Barrage) (with extended parameters)
 @param text                 Message content
 @param num                  Number of message content
 @param messageType          chat type
 @param customMsgType        custom message type
 @param ext              message extension
 @param aCompletionBlock     send completion callback
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(EMChatType)messageType
            customMsgType:(customMessageType)customMsgType
                      ext:(NSDictionary*)ext
               completion:(void (^)(EMChatMessage *message, EMError *error))aCompletionBlock;

/*
 send user custom message (Other custom message body events)
 
@param event                custom message body event
@param customMsgBodyExt     custom message body event parameters
@param to                   message receiver
@param messageType          chat type
@param aCompletionBlock     send completion callback
*/
- (void)sendUserCustomMessage:(NSString*)event
             customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                  messageType:(EMChatType)messageType
                   completion:(void (^)(EMChatMessage *message, EMError *error))aCompletionBlock;

/*
 send user custom message (Other custom message body events) (extension parameters)
 
@param event                custom message body event
@param customMsgBodyExt     custom message body event parameters
@param to                   message receiver
@param messageType          chat type
@param ext                  message extension
@param aCompletionBlock     send completion callback
*/
- (void)sendUserCustomMessage:(NSString*)event
             customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                  messageType:(EMChatType)messageType
                          ext:(NSDictionary*)ext
                   completion:(void (^)(EMChatMessage *message, EMError *error))aCompletionBlock;


@end

NS_ASSUME_NONNULL_END

