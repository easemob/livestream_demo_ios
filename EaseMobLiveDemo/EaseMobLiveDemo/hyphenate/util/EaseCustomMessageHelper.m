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

static EaseCustomMessageHelper *sharedInstance;

@interface EaseCustomMessageHelper ()

@end

@implementation EaseCustomMessageHelper

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EaseCustomMessageHelper alloc]init];
    });
    
    return sharedInstance;
}

- (void)sendCustomMessage:(NSString*)text
                              num:(NSInteger)num
                               to:(NSString*)toUser
                      messageType:(EMChatType)messageType
                    customMsgType:(customMessageType)msgType
                       completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;
{
    EMMessageBody *body;
    NSMutableDictionary *extDic = [[NSMutableDictionary alloc]init];
    if (msgType == customMessageType_praise) {
        [extDic setObject:@"1" forKey:@"num"];
        body = [[EMCustomMessageBody alloc]initWithEvent:@"chatroom_like" ext:extDic];
    } else if (msgType == customMessageType_gift){
        [extDic setObject:text forKey:@"id"];
        [extDic setObject:[NSString stringWithFormat:@"%ld",(long)num] forKey:@"num"];
        body = [[EMCustomMessageBody alloc]initWithEvent:@"chatroom_gift" ext:extDic];
    } else if (msgType == customMessageType_barrage) {
        [extDic setObject:text forKey:@"txt"];
        body = [[EMCustomMessageBody alloc]initWithEvent:@"chatroom_barrage" ext:extDic];
    }
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:nil];
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
    cellModel.count = &(count);
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
    giftModel.sendCount = *(cellModel.count);
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
