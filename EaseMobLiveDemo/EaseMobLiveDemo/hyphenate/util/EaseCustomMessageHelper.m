//
//  EaseCustomMessageHelper.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/3/12.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseCustomMessageHelper.h"
#import "JPGiftCellModel.h"
#import "JPGiftModel.h"
#import "JPGiftShowManager.h"
#import "EaseLiveGiftHelper.h"
#import "EaseBarrageFlyView.h"
#import "EaseHeartFlyView.h"

@interface EaseCustomMessageHelper ()<EMChatManagerDelegate>
{
    NSString* _chatroomId;
    
    long long _curtime;//过滤历史记录
}

@end

@implementation EaseCustomMessageHelper

- (instancetype)initWithCustomMsgImp:(id<EaseCustomMessageHelperDelegate>)customMsgImp roomId:(NSString*)chatroomId
{
    self = [super init];
    if (self) {
        _delegate = customMsgImp;
        _chatroomId = chatroomId;
        _curtime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([message.conversationId isEqualToString:_chatroomId]) {
            if (message.body.type == EMMessageBodyTypeCustom) {
                if (message.timestamp < _curtime) {
                    continue;
                }
                EMCustomMessageBody* body = (EMCustomMessageBody*)message.body;
                if ([body.event isEqualToString:kCustomMsgChatroomBarrage]) {
                    //弹幕消息
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedBarrageSwitch:)]) {
                        [self.delegate didSelectedBarrageSwitch:message];
                    }
                } else if ([body.event isEqualToString:kCustomMsgChatroomPraise]) {
                    //点赞消息
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceivePraiseMessage:)]) {
                        [self.delegate didReceivePraiseMessage:message];
                    }
                } else if ([body.event isEqualToString:kCustomMsgChatroomGift]) {
                    //礼物消息
                    if (self.delegate && [self.delegate respondsToSelector:@selector(userSendGifts:count:)]) {
                        [self.delegate userSendGifts:message count:[(NSString*)[body.ext objectForKey:@"num"] intValue]];
                    }
                }
            }
        }
    }
}

//解析消息内容
+ (NSString*)getMsgContent:(EMMessageBody*)messageBody
{
    NSString *msgContent = nil;
    EMCustomMessageBody *customBody = (EMCustomMessageBody*)messageBody;
    if ([customBody.event isEqualToString:kCustomMsgChatroomBarrage]) {
        msgContent = (NSString*)[customBody.ext objectForKey:@"txt"];
    } else if ([customBody.event isEqualToString:kCustomMsgChatroomPraise]) {
        msgContent = [NSString stringWithFormat:@"给主播点了%ld个赞",(long)[(NSString*)[customBody.ext objectForKey:@"num"] integerValue]];
    } else if ([customBody.event isEqualToString:kCustomMsgChatroomGift]) {
        NSString *giftid = [customBody.ext objectForKey:@"id"];
        int index = [[giftid substringFromIndex:5] intValue];
        NSDictionary *dict = EaseLiveGiftHelper.sharedInstance.giftArray[index-1];
        msgContent = [NSString stringWithFormat:@"赠送了 %@x%@",NSLocalizedString((NSString *)[dict allKeys][0],@""),(NSString*)[customBody.ext objectForKey:@"num"]];
    }
    return msgContent;
}

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
{
    EMMessageBody *body;
    NSMutableDictionary *extDic = [[NSMutableDictionary alloc]init];
    if (customMsgType == customMessageType_praise) {
        [extDic setObject:@"1" forKey:@"num"];
        body = [[EMCustomMessageBody alloc]initWithEvent:kCustomMsgChatroomPraise ext:extDic];
    } else if (customMsgType == customMessageType_gift){
        [extDic setObject:text forKey:@"id"];
        [extDic setObject:[NSString stringWithFormat:@"%ld",(long)num] forKey:@"num"];
        body = [[EMCustomMessageBody alloc]initWithEvent:kCustomMsgChatroomGift ext:extDic];
    } else if (customMsgType == customMessageType_barrage) {
        [extDic setObject:text forKey:@"txt"];
        body = [[EMCustomMessageBody alloc]initWithEvent:kCustomMsgChatroomBarrage ext:extDic];
    }
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:nil];
    message.chatType = messageType;
    [[EMClient sharedClient].chatManager sendMessage:message progress:NULL completion:^(EMMessage *message, EMError *error) {
        aCompletionBlock(message,error);
    }];
}

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
{
    EMMessageBody *body;
    NSMutableDictionary *extDic = [[NSMutableDictionary alloc]init];
    if (customMsgType == customMessageType_praise) {
        [extDic setObject:@"1" forKey:@"num"];
        body = [[EMCustomMessageBody alloc]initWithEvent:kCustomMsgChatroomPraise ext:extDic];
    } else if (customMsgType == customMessageType_gift){
        [extDic setObject:text forKey:@"id"];
        [extDic setObject:[NSString stringWithFormat:@"%ld",(long)num] forKey:@"num"];
        body = [[EMCustomMessageBody alloc]initWithEvent:kCustomMsgChatroomGift ext:extDic];
    } else if (customMsgType == customMessageType_barrage) {
        [extDic setObject:text forKey:@"txt"];
        body = [[EMCustomMessageBody alloc]initWithEvent:kCustomMsgChatroomBarrage ext:extDic];
    }
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:ext];
    message.chatType = messageType;
    [[EMClient sharedClient].chatManager sendMessage:message progress:NULL completion:^(EMMessage *message, EMError *error) {
        aCompletionBlock(message,error);
    }];
}

//有观众送礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count backView:(UIView*)backView
{
    EMCustomMessageBody *msgBody = (EMCustomMessageBody*)msg.body;
    JPGiftCellModel *cellModel = [[JPGiftCellModel alloc]init];
    cellModel.user_icon = [UIImage imageNamed:@"default_anchor_avatar"];
    NSString *giftid = [msgBody.ext objectForKey:@"id"];
    int index = [[giftid substringFromIndex:5] intValue];
    NSDictionary *dict = EaseLiveGiftHelper.sharedInstance.giftArray[index-1];
    cellModel.icon = [UIImage imageNamed:(NSString *)[dict allKeys][0]];
    cellModel.name = NSLocalizedString((NSString *)[dict allKeys][0], @"");
    cellModel.username = msg.from;
    cellModel.count = count;
    [self sendGiftAction:cellModel backView:backView];
}

//礼物动画
- (void)sendGiftAction:(JPGiftCellModel*)cellModel backView:(UIView*)backView
{
    JPGiftModel *giftModel = [[JPGiftModel alloc]init];
    giftModel.userIcon = cellModel.user_icon;
    giftModel.userName = cellModel.username;
    giftModel.giftName = cellModel.name;
    giftModel.giftImage = cellModel.icon;
    //giftModel.giftGifImage = cellModel.icon_gif;
    giftModel.defaultCount = 0;
    giftModel.sendCount = cellModel.count;
    [[JPGiftShowManager sharedManager] showGiftViewWithBackView:backView info:giftModel completeBlock:^(BOOL finished) {
               //结束
        } completeShowGifImageBlock:^(JPGiftModel *giftModel) {
    }];
}

//弹幕动画
- (void)barrageAction:(EMMessage*)msg backView:(UIView*)backView
{
    EaseBarrageFlyView *barrageView = [[EaseBarrageFlyView alloc]initWithMessage:msg];
    [backView addSubview:barrageView];
    [barrageView animateInView:backView];
}

//点赞动画
- (void)praiseAction:(UIView*)backView
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [backView addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), backView.height);
    heart.center = fountainSource;
    [heart animateInView:backView];
}

@end
