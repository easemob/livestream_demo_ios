//
//  EaseLiveSession.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EaseLiveSessionNotStart,
    EaseLiveSessionOngoing,
    EaseLiveSessionCompleted,
    EaseLiveSessionClosed,
    EaseLiveSessionUnknown,
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

@property (nonatomic, copy) NSString *anchor;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) NSTimeInterval endTime;

@property (nonatomic, assign) EaseLiveSessionStatus status;

@property (nonatomic, copy) NSString *pcpullstream;

@property (nonatomic, copy) NSString *pcpushstream;

@property (nonatomic, copy) NSString *mobilepullstream;

@property (nonatomic, copy) NSString *mobilepushstream;

@property (nonatomic, copy) NSString *liveUrl;

@property (nonatomic, assign, readonly) NSTimeInterval created;

@property (nonatomic, assign) NSInteger praiseCount;

@property (nonatomic, assign) NSInteger giftCount;

@property (nonatomic, assign) NSInteger maxOnlineCount;

@property (nonatomic, assign) NSInteger totalWatchCount;

@property (nonatomic, assign) NSInteger currentUserCount;

- (instancetype)initWithParameter:(NSDictionary*)parameter;

- (NSDictionary*)parameters;

+ (EaseLiveSessionStatus)statusWithValue:(NSString*)value;

+ (NSString*)valueWithStatus:(EaseLiveSessionStatus)status;

@end

