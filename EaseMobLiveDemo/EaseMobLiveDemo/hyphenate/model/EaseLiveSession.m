//
//  EaseLiveSession.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseLiveSession.h"

#import "NSDictionary+SafeValue.h"

@implementation EaseLiveSession

- (instancetype)initWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _maxOnlineCount = [parameter safeIntegerValueForKey:@"max_user_count"];
        _praiseCount = [parameter safeIntegerValueForKey:@"praise_count"];
        _giftCount = [parameter safeIntegerValueForKey:@"gift_count"];
        _anchor = [parameter safeStringValueForKey:@"anchor"];
        _status = [EaseLiveSession statusWithValue:[parameter safeStringValueForKey:@"status"]];
        _startTime = [[parameter safeObjectForKey:@"startTime"] doubleValue];
        _endTime = [[parameter safeObjectForKey:@"endTime"] doubleValue];
        _currentUserCount = [parameter safeIntegerValueForKey:@"current_user_count"];
        _totalWatchCount = [parameter safeIntegerValueForKey:@"total_user_count"];
        _mobilepushstream = [parameter safeStringValueForKey:@"mobile_push_url"];
        _mobilepullstream = [parameter safeStringValueForKey:@"mobile_pull_url"];
        _pcpushstream = [parameter safeStringValueForKey:@"pc_push_url"];
        _pcpullstream = [parameter safeStringValueForKey:@"pc_pull_url"];
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


@end
