//
//  EaseLiveSession.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EaseLiveSessionUnknown,
    EaseLiveSessionNotStart,
    EaseLiveSessionOngoing,
    EaseLiveSessionCompleted,
    EaseLiveSessionClosed
} EaseLiveSessionStatus;

@interface EaseLiveSession : NSObject

/*
 *  直播聊天室ID
 */
@property (nonatomic, strong, readonly) NSString *roomId;

/*
 *  直播场次ID
 */
@property (nonatomic, strong, readonly) NSString *showId;

/*
 *  当前直播场次的主播
 */
@property (nonatomic, copy) NSString *anchor;
/*
 *  本场次开始的Unix时间戳
 */
@property (nonatomic, assign) NSTimeInterval startTime;

/*
 *  本场次结束的Unix时间戳
 */
@property (nonatomic, assign) NSTimeInterval endTime;

/*
 *  当前直播场次的状态
 */
@property (nonatomic, assign) EaseLiveSessionStatus status;

/*
 *  PC端拉流地址
 */
@property (nonatomic, copy) NSString *pcpullstream;

/*
 *  PC端推流地址
 */
@property (nonatomic, copy) NSString *pcpushstream;

/*
 *  移动端拉流地址
 */
@property (nonatomic, copy) NSString *mobilepullstream;

/*
 *  移动端推流地址
 */
@property (nonatomic, copy) NSString *mobilepushstream;

/*
 *  直播场次创建的Unix时间戳
 */
@property (nonatomic, assign, readonly) NSTimeInterval created;

/*
 *  当前直播场次赞赏总数
 */
@property (nonatomic, assign) NSInteger praiseCount;

/*
 *  当前直播场次礼物总数
 */
@property (nonatomic, assign) NSInteger giftCount;

/*
 *  当前直播场次最大在线人数
 */
@property (nonatomic, assign) NSInteger maxOnlineCount;

/*
 *  当前直播场次总观看人数
 */
@property (nonatomic, assign) NSInteger totalWatchCount;

/*
 *  当前在线人数
 */
@property (nonatomic, assign) NSInteger currentUserCount;

- (instancetype)initWithParameter:(NSDictionary*)parameter;

+ (EaseLiveSessionStatus)statusWithValue:(NSString*)value;

+ (NSString*)valueWithStatus:(EaseLiveSessionStatus)status;

@end

