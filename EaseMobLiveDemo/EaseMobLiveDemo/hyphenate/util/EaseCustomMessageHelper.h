//
//  EaseCustomMessageHelper.h
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/3/12.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JPGiftCellModel.h"

typedef enum : NSInteger{
    customMessageType_praise,//点赞
    customMessageType_gift,//礼物
    customMessageType_barrage,//弹幕
}customMessageType;

NS_ASSUME_NONNULL_BEGIN

@class EMMessage;
@protocol EaseCustomMessageHelperDelegate <NSObject>

@optional

//观众点赞消息
- (void)didReceivePraiseMessage:(EMMessage *)message;
//弹幕消息
- (void)didSelectedBarrageSwitch:(EMMessage*)msg;
//观众刷礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count;//观众送礼物

@end

@interface EaseCustomMessageHelper : NSObject

- (instancetype)initWithCustomMsgImp:(id<EaseCustomMessageHelperDelegate>)customMsgImp roomId:(NSString*)chatroomId;

//解析消息内容
+ (NSString*)getMsgContent:(EMMessageBody*)messageBody;

/*
 发送自定义消息
 @param text                 消息内容
 @param num                  消息内容数量
 @param messageType          聊天类型
 @param customMsgType        自定义消息类型
 @param aCompletionBlock     发送完成回调block
*/
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(EMChatType)messageType
            customMsgType:(customMessageType)customMsgType
               completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

/*
 发送自定义消息（有扩展参数）
 @param text             消息内容
 @param num              消息内容数量
 @param messageType      聊天类型
 @param customMsgType    自定义消息类型
 @param ext              消息扩展
 @param aCompletionBlock 发送完成回调block
*/
- (void)sendCustomMessage:(NSString*)text
                              num:(NSInteger)num
                               to:(NSString*)toUser
                      messageType:(EMChatType)messageType
                    customMsgType:(customMessageType)customMsgType
                            ext:(NSDictionary*)ext
                       completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

/*
 @param msg             接收的消息
 @param count           礼物数量
 @param backView        展示在哪个页面
 */
//有观众送礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count backView:(UIView*)backView;

//礼物动画
- (void)sendGiftAction:(JPGiftCellModel*)cellModel backView:(UIView*)backView;

/*
 @param msg             接收的消息
 @param backView        展示在哪个页面
 */
//弹幕动画
- (void)barrageAction:(EMMessage*)msg backView:(UIView*)backView;

/*
 @param backView        展示在哪个页面
 */
//点赞动画
- (void)praiseAction:(UIView*)backView;

@end

NS_ASSUME_NONNULL_END

