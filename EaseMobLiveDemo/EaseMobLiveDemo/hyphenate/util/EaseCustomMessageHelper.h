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

@interface EaseCustomMessageHelper : NSObject

+ (instancetype)sharedInstance;

//发送自定义消息
- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(EMChatType)messageType
            customMsgType:(customMessageType)msgType
               completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

//有观众送礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count backView:(UIView*)backView;

//礼物动画
- (void)sendGiftAction:(JPGiftCellModel*)cellModel backView:(UIView*)backView;

//弹幕动画
- (void)barrageAction:(EMMessage*)msg backView:(UIView*)backView;

//点赞动画
- (void)praiseAction:(UIView*)backView;

@end

NS_ASSUME_NONNULL_END
