//
//  EaseLiveRoom.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseLiveRoom.h"

#import "NSDictionary+SafeValue.h"

@implementation EaseLiveRoom

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [[EaseLiveSession alloc] init];
    }
    return self;
}

- (instancetype)initWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _roomId = [parameter safeStringValueForKey:@"id"];
        if (_roomId.length == 0) {
            _roomId = [parameter safeObjectForKey:@"liveroom_id"];
        }
        _chatroomId = [parameter safeStringValueForKey:@"chatroom_id"];
        _title = [parameter safeStringValueForKey:@"title"];
        _desc = [parameter safeStringValueForKey:@"desc"];
        _custom = [parameter safeStringValueForKey:@"custom"];
        _created = [[parameter safeObjectForKey:@"created"] doubleValue];
        _showId = [parameter safeStringValueForKey:@"show_id"];
        _needPassword = [[parameter safeObjectForKey:@"need_password"] boolValue];
        _password = [parameter safeStringValueForKey:@"password"];
        _coverPictureUrl = [parameter safeStringValueForKey:@"cover_picture_url"];
        _session = [[EaseLiveSession alloc] initWithParameter:parameter];
    }
    return self;
}

- (NSDictionary*)parameters
{
    return nil;
}

@end
