//
//  EaseLiveRoom.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EaseLiveSession.h"

typedef enum {
    offline,
    ongoing
} EaseLiveStatus;

@interface EaseLiveRoom : NSObject

/*
 *  直播聊天室ID
 */
@property (nonatomic, strong, readonly) NSString *roomId;

/*
 *  直播聊天室对应的底层聊天室ID
 */
@property (nonatomic, strong, readonly) NSString *chatroomId;

/*
 *  直播聊天室房间名称
 */
@property (nonatomic, copy) NSString *title;

/*
 *  直播聊天室房间描述
 */
@property (nonatomic, copy) NSString *desc;

/*
 *  用户自定义字段
 */
@property (nonatomic, copy) NSDictionary *custom;

/*
 *  直播聊天室创建Unix时间戳
 */
@property (nonatomic, assign, readonly) NSTimeInterval created;

/*
 *  当前直播房间关联的直播场次ID
 */
@property (nonatomic, strong, readonly) NSString *showId;

/*
 *  计入聊天室是否需要密码
 */
@property (nonatomic, assign) BOOL needPassword;

/*
 *  密码
 */
@property (nonatomic, copy) NSString *password;

/*
 *  聊天室封面图片URL
 */
@property (nonatomic, copy) NSString *coverPictureUrl;

/*
 *  直播场次
 */
@property (nonatomic, strong) EaseLiveSession *session;

/*
 *  直播间状态
 */
@property (nonatomic) EaseLiveStatus status;

/*
 *  直播间类型
 */
@property (nonatomic, copy) NSString *liveroomType;

/*
 *  直播间主播
 */
@property (nonatomic, copy) NSString *anchor;

/*
 *  直播间观众人数
 */
@property (nonatomic, assign) NSInteger currentUserCount;

/*
 *  直播间当前观众列表
 */
@property (nonatomic, copy) NSArray *currentMemberList;

/*
 *  直播间扩展
 */
@property (nonatomic, copy) NSDictionary *liveroomExt;

/*
 *  直播间频道channel
 */
@property (nonatomic, copy) NSString *channel;


- (instancetype)initWithParameter:(NSDictionary*)parameter;

@end
