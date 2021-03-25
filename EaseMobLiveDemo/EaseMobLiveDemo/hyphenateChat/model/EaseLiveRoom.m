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
        //_chatroomId = [parameter safeStringValueForKey:@"chatroom_id"];
        _chatroomId = [parameter safeStringValueForKey:@"id"];
        //_title = [parameter safeStringValueForKey:@"title"];
        _title = [parameter safeStringValueForKey:@"name"];
        _desc = [parameter safeStringValueForKey:@"description"];
        _custom = [parameter safeObjectForKey:@"ext"];
        _created = [[parameter safeObjectForKey:@"created"] doubleValue];
        _showId = [parameter safeStringValueForKey:@"showid"];
        _needPassword = [[parameter safeObjectForKey:@"need_password"] boolValue];
        _password = [parameter safeStringValueForKey:@"password"];
        //_coverPictureUrl = [parameter safeStringValueForKey:@"cover_picture_url"];
        _coverPictureUrl = [parameter safeStringValueForKey:@"cover"];
        _session = [[EaseLiveSession alloc] initWithParameter:parameter];
        
        _status = [[parameter safeStringValueForKey:@"status"] isEqualToString:@"offline"] ? offline : ongoing;
        _anchor = [parameter safeStringValueForKey:@"owner"];
        _currentUserCount = [parameter safeIntegerValueForKey:@"affiliations_count"];
        _currentMemberList = [self memberList:[parameter safeObjectForKey:@"affiliations"]];
        _liveroomExt = [parameter safeObjectForKey:@"ext"];
        _liveroomType = [parameter safeStringValueForKey:@"video_type"];
        _channel = [parameter safeStringValueForKey:@"channel"];
    }
    return self;
}

- (NSArray*)memberList:(id)memberList
{
    if (memberList == nil)
        return nil;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSDictionary *str in memberList) {
        if (str && [str isKindOfClass:[NSDictionary class]]) {
            NSString * member = [str objectForKey:@"member"];
            [array addObject:member];
        }
    }
    return [array copy];
}

- (NSDictionary*)parameters
{
    return nil;
}

@end
