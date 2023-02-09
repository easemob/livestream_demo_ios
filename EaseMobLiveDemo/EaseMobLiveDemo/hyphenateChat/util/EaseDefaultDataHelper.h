//
//  EaseDefaultDataHelper.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/26.
//  Copyright © 2020 zmw. All rights reserved.
//

#define kBROADCASTING_CURRENT_ANCHOR @"broadcastingCurrentAnchor" //当前直播间的主播
#define kBROADCASTING_CURRENT_ANCHOR_NICKNAME @"broadcastingCurrentAnchorNickname" //当前直播间主播昵称
#define kBROADCASTING_CURRENT_ANCHOR_AVATAR @"broadcastingCurrentAnchorAvatar"  //当前直播间主播头像

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseDefaultDataHelper : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *defaultNickname;//当前登录的默认昵称

@property (nonatomic, strong) NSString *currentRoomId;//当前所在的直播间id

@property (nonatomic, assign) BOOL isInitiativeLogin;//是否主动登陆

@property (nonatomic, strong) NSString *praiseStatisticstCount;//点赞统计
@property (nonatomic, strong) NSMutableDictionary *giftStatisticsCount;//礼物统计
@property (nonatomic, strong) NSMutableArray *rewardCount;//打赏人列表
@property (nonatomic, strong) NSString *giftNumbers;//礼物份数
@property (nonatomic, strong) NSString *totalGifts;//礼物总数合计


+ (instancetype)shared;

- (void)archive;

@end

NS_ASSUME_NONNULL_END
