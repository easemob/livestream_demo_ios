//
//  EaseLiveSession.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseLiveSession.h"

#import "NSDictionary+SafeValue.h"

/*
 show_id 只读， 直播场次ID，对用户不可见
 room_id 只读， 直播场次ID 对应的直播聊天室ID
 anchor String类型，当前直播场次的主播
 start_time Long类型，本场次开始的Unix时间戳
 end_time Long类型，本场次结束的Unix时间戳
 status String类型， 当前直播场次的状态。有如下取值: not_start, ongoing, completed, closed, unknown
 pcpullstream String类型， PC端拉流地址
 pcpushstream String类型，PC端推流地址
 mobilepullstream String类型，移动端拉流地址
 mobilepushstream String类型，移动端推流地址
 created 只读 Long类型，直播场次创建的Unix时间戳
 
 praise_count Int类型， 当前直播场次赞赏总数
 
 gift_count Int类型， 当前直播场次礼物总数
 maxonlinecount Int类型 当前直播场次最大在线人数
 totalwatchcount Int类型，当前直播场次总观看人数
 */

@implementation EaseLiveSession

- (instancetype)initWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _maxOnlineCount = [parameter safeIntegerValueForKey:@"max_online_count"];
        _praiseCount = [parameter safeIntegerValueForKey:@"praise_count"];
        _giftCount = [parameter safeIntegerValueForKey:@"gift_count"];
        _anchor = [parameter safeStringValueForKey:@"anchor"];
        _status = [EaseLiveSession statusWithValue:[parameter safeStringValueForKey:@"status"]];
        _liveUrl = [parameter safeStringValueForKey:@"live_url"];
        _startTime = [[parameter safeObjectForKey:@"startTime"] doubleValue];
        _endTime = [[parameter safeObjectForKey:@"endTime"] doubleValue];
        _currentUserCount = [parameter safeIntegerValueForKey:@"current_user_count"];
        _totalWatchCount = [parameter safeIntegerValueForKey:@"total_user_count"];
        _mobilepushstream = [parameter safeStringValueForKey:@"mobile_push_url"];
        if (_mobilepushstream.length == 0) {
            _mobilepushstream = [parameter safeStringValueForKey:@"mobile_pull_stream"];
        }
        _mobilepullstream = [parameter safeStringValueForKey:@"mobile_pull_url"];
        if (_mobilepullstream.length == 0) {
            _mobilepullstream = [parameter safeStringValueForKey:@"mobile_push_stream"];
        }
        _pcpushstream = [parameter safeStringValueForKey:@"pc_push_url"];
        if (_pcpushstream.length == 0) {
            _pcpushstream = [parameter safeStringValueForKey:@"pc_push_stream"];
        }
        _pcpullstream = [parameter safeStringValueForKey:@"pc_pull_url"];
        if (_pcpullstream.length == 0) {
            _pcpullstream = [parameter safeStringValueForKey:@"pc_pull_stream"];
        }
    }
    return self;
}

+ (EaseLiveSessionStatus)statusWithValue:(NSString*)value
{
    if (value.length > 0) {
        if ([value isEqualToString:@"not_start"]) {
            return EaseLiveSessionNotStart;
        }
        
        if ([value isEqualToString:@"ongoing"]) {
            return EaseLiveSessionOngoing;
        }
        
        if ([value isEqualToString:@"completed"]) {
            return EaseLiveSessionCompleted;
        }
        
        if ([value isEqualToString:@"closed"]) {
            return EaseLiveSessionClosed;
        }
    }
    
    return EaseLiveSessionUnknown;
}

+ (NSString*)valueWithStatus:(EaseLiveSessionStatus)status
{
    NSString *value = nil;
    switch (status) {
        case EaseLiveSessionClosed:
            value = @"closed";
            break;
        case EaseLiveSessionOngoing:
            value = @"ongoing";
            break;
        case EaseLiveSessionNotStart:
            value = @"not_start";
            break;
        case EaseLiveSessionCompleted:
            value = @"completed";
            break;
        default:
            value = @"unknown";
            break;
    }
    return value;
}


- (NSDictionary*)parameters
{
    return nil;
}

@end
