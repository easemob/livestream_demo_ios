//
//  EaseHttpManager.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/13.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseHttpManager.h"

#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+SafeValue.h"

#define kAppKeyForDomain [EMClient sharedClient].options.appkey.length > 0 ? [[EMClient sharedClient].options.appkey stringByReplacingOccurrencesOfString:@"#" withString:@"/"] : @""

/*
 POST request   设置管理员
 */
#define kPostRequestSetAdminUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@/admin",kDefaultDomain, kAppKeyForDomain, id]

/*
 DELETE request 取消管理员
 */
#define kDeleteRequestCancelAdminUrl(id, imUser) [NSString stringWithFormat:@"%@/%@/liverooms/%@/admin/%@", kDefaultDomain, kAppKeyForDomain, id, imUser]

/*
 GET request    (分页)获取某直播间的主播列表
 */
#define kGetRequestGetAnchorsUrl(id, pageNum, pageSize) [NSString stringWithFormat:@"%@/%@/liverooms/%@/anchors?pagenum=%@&pagesize=%@", kDefaultDomain, kAppKeyForDomain, id, pageNum, pageSize]

/*
 DELETE request 将用户踢出直播间
 */
#define kDeleteRequestKickMemberUrl(id, member) [NSString stringWithFormat:@"%@/%@/liverooms/%@/members/%@", kDefaultDomain, kAppKeyForDomain, id, member]

/*  live-room-manage    */
/*
 POST request   创建直播间
 */
#define kPostRequestCreateLiveroomsUrl [NSString stringWithFormat:@"%@/%@/liverooms?status=ongoing", kDefaultDomain, kAppKeyForDomain]  //创建直播间

/*
 DELETE/PUT request 删除直播间
 */
#define kRequestLiveroomsUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@", kDefaultDomain, kAppKeyForDomain, id]

/*
 GET/PUT request   获取直播间状态
 */
#define kRequestStatusLiveroomsUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@/status", kDefaultDomain, kAppKeyForDomain, id]

/*
 Post request   创建新的直播场次
 */
#define kPostRequestCreateLiveSessionUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@/liveshows?status=ongoing", kDefaultDomain, kAppKeyForDomain, id]

/*
 GET request    (分页)获取当前appKey下的直播房间列表
 */
#define kGetRequestGetLiveroomsPagingUrl(pageNum, pageSize) [NSString stringWithFormat:@"%@/%@/liverooms?pagenum=%ld&pagesize=%ld", kDefaultDomain, kAppKeyForDomain, pageNum, pageSize]

/*
 GET request    获取appkey下的正在直播的直播聊天室列表
 */
#define kGetRequestGetLiveroomsOngoingUrl(limit, cursor) [NSString stringWithFormat:@"%@/%@/liverooms?ongoing=true&limit=%ld&cursor=%@", kDefaultDomain, kAppKeyForDomain, limit, cursor]

/*
 GET request    获取某个具体直播房间的详情
 */
#define kGetRequestGetLiveroomsUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@", kDefaultDomain, kAppKeyForDomain, id]

/*
 GET request    获取某个直播房间当前直播场次的实时数据(直播状态，在线人数，总观看人数)
 */
#define kGetRequestCurrentLiveroomsUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@/current", kDefaultDomain, kAppKeyForDomain, id]

/*
 POST request   上传文件
 */
#define kPostRequestUploadFileUrl [NSString stringWithFormat:@"%@/%@/chatfiles", kDefaultDomain, kAppKeyForDomain]

/*
 GET/PUT request    统计数量
 */
#define kRequestCountUrl(id) [NSString stringWithFormat:@"%@/%@/liverooms/%@/counters", kDefaultDomain, kAppKeyForDomain, id]

/*
 GET request    获取一个主播关联的直播聊天室列表
 */
#define kGetRequestGetLiveRoomListUrl(username, pageNum, pageSize) [NSString stringWithFormat:@"%@/%@/liverooms/anchors/%@/joined_liveroom_list?pagenum=%ld&pagesize=%ld", kDefaultDomain, kAppKeyForDomain, username, pageNum, pageSize]


#define kHttpRequestTimeout 60.f
#define kHttpRequestMaxOperation 5

#define kDefaultDomain @"http://a1.easemob.com"

static EaseHttpManager *sharedInstance = nil;

@interface EaseHttpManager ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation EaseHttpManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionManager = [[AFHTTPSessionManager alloc] init];
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        [_sessionManager setSecurityPolicy:securityPolicy];
        [_sessionManager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"content-type"];
        [_sessionManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [_sessionManager.requestSerializer setTimeoutInterval:kHttpRequestTimeout];
        [_sessionManager.operationQueue setMaxConcurrentOperationCount:kHttpRequestMaxOperation];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

#pragma mark - public

- (void)createLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (aRoom) {
        if (aRoom.title.length > 0) {
            [parameters setObject:aRoom.title forKey:@"title"];
        }
        
        if (aRoom.desc.length > 0) {
            [parameters setObject:aRoom.desc forKey:@"desc"];
        }
        
        if (aRoom.session.anchor.length > 0) {
            [parameters setObject:aRoom.session.anchor forKey:@"anchor"];
        }
        
        if (aRoom.coverPictureUrl.length > 0) {
            [parameters setObject:aRoom.coverPictureUrl forKey:@"cover_picture_url"];
        }
        
        if (aRoom.custom.length > 0) {
            [parameters setObject:aRoom.custom forKey:@"custom"];
        }
        
        if (aRoom.needPassword) {
            [parameters setObject:@(YES) forKey:@"need_password"];
            if (aRoom.password.length > 0) {
                [parameters setObject:aRoom.password forKey:@"password"];
            }
        }
//        [parameters setObject:@"ongoing" forKey:@"status"];
    }
    
    [self _doPostRequestWithPath:kPostRequestCreateLiveroomsUrl parameters:parameters completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            EaseLiveRoom *room = nil;
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        [parameters addEntriesFromDictionary:data];
                    }
                    room = [[EaseLiveRoom alloc] initWithParameter:parameters];
                    ret = YES;
                }
            }
            aCompletion(room, ret);
        }
    }];
}

- (void)modifyLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *liveroom = [NSMutableDictionary dictionary];
    if (aRoom) {
        if (aRoom.title.length > 0) {
            [liveroom setObject:aRoom.title forKey:@"title"];
        }
        
        if (aRoom.desc.length > 0) {
            [liveroom setObject:aRoom.desc forKey:@"desc"];
        }
        
        if (aRoom.custom.length > 0) {
            [liveroom setObject:aRoom.custom forKey:@"custom"];
        }
        
        if (aRoom.coverPictureUrl.length > 0) {
            [liveroom setObject:aRoom.coverPictureUrl forKey:@"cover_picture_url"];
        }
        
        if (aRoom.needPassword) {
            [liveroom setObject:@(YES) forKey:@"need_password"];
            if (aRoom.password.length > 0) {
                [liveroom setObject:aRoom.password forKey:@"password"];
            }
        }
    }
    [parameters setObject:liveroom forKey:@"liveroom"];
    
    [self _doPutRequestWithPath:kRequestLiveroomsUrl(aRoom.roomId) parameters:parameters completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            EaseLiveRoom *room = nil;
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    room = [[EaseLiveRoom alloc] initWithParameter:@{@"liveroom_id":aRoom.roomId,@"chatroom_id":aRoom.chatroomId}];
                    ret = YES;
                }
            }
            aCompletion(room, ret);
        }
    }];
}

- (void)getLiveRoomWithRoomId:(NSString*)aRoomId
                   completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion
{
    [self _doGetRequestWithPath:kGetRequestGetLiveroomsUrl(aRoomId) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            EaseLiveRoom *room = nil;
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        room = [[EaseLiveRoom alloc] initWithParameter:data];
                        ret = YES;
                    }
                }
            }
            aCompletion(room, ret);
        }
    }];
}

- (void)deleteLiveRoomWithRoomId:(NSString*)aRoomId
                      completion:(void (^)(BOOL success))aCompletion
{
    [self _doDeleteRequestWithPath:kRequestLiveroomsUrl(aRoomId) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        if ([[data safeObjectForKey:@"result"] boolValue]) {
                            ret = YES;
                        }
                    }
                }
            }
            aCompletion(ret);
        }
    }];
}

- (void)fetchLiveRoomsWithPage:(NSInteger)aPage
                      pagesize:(NSInteger)aPageSize
                    completion:(void (^)(NSArray *roomList, NSError *error))aCompletion
{
    [self _doGetRequestWithPath:kGetRequestGetLiveroomsPagingUrl((long)aPage, (long)aPageSize) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            NSMutableArray *result = nil;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    if ([responseObject objectForKey:@"data"]) {
                        NSArray *data = [responseObject objectForKey:@"data"];
                        result = [[NSMutableArray alloc] init];
                        if ([data count] > 0) {
                            for (NSDictionary *dic in data) {
                                if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                                    EaseLiveRoom *room = [[EaseLiveRoom alloc] initWithParameter:dic];
                                    [result addObject:room];
                                }
                            }
                        }
                    }
                }
            }
            aCompletion(result, error);
        }
    }];
}

- (void)fetchLiveRoomsOngoingWithCursor:(NSString*)aCursor
                                  limit:(NSInteger)aLimit
                             completion:(void (^)(EMCursorResult *result, BOOL success))aCompletion
{
    NSString *cursor = @"";
    if (aCursor.length > 0) {
        cursor = [aCursor copy];
    }
    [self _doGetRequestWithPath:kGetRequestGetLiveroomsOngoingUrl((long)aLimit, cursor) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            NSMutableArray *array = nil;
            NSString *cursor = nil;
            EMCursorResult *result = nil;
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    if ([responseObject objectForKey:@"data"]) {
                        NSArray *data = [responseObject objectForKey:@"data"];
                        array = [[NSMutableArray alloc] init];
                        if ([data count] > 0) {
                            for (NSDictionary *dic in data) {
                                if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                                    EaseLiveRoom *room = [[EaseLiveRoom alloc] initWithParameter:dic];
                                    [array addObject:room];
                                }
                            }
                        }
                    }
                    cursor = [responseObject objectForKey:@"cursor"];
                    result = [EMCursorResult cursorResultWithList:array andCursor:cursor];
                    ret = YES;
                }
            }
            aCompletion(result, ret);
        }
    }];
}

- (void)getLiveRoomStatusWithRoomId:(NSString*)aRoomId
                         completion:(void (^)(EaseLiveSessionStatus status, BOOL success))aCompletion
{
    [self _doGetRequestWithPath:kRequestStatusLiveroomsUrl(aRoomId) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            EaseLiveSessionStatus status = EaseLiveSessionNotStart;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        NSString *statusStr = [data objectForKey:@"status"];
                        if (statusStr.length > 0) {
                            status = [EaseLiveSession statusWithValue:statusStr];
                            ret = YES;
                        }
                    }
                }
            }
            aCompletion(status, ret);
        }
    }];
}

- (void)modifyLiveRoomStatusWithRoomId:(NSString*)aRoomId
                                status:(EaseLiveSessionStatus)aStatus
                            completion:(void (^)(BOOL success))aCompletion
{
    NSString *value = [EaseLiveSession valueWithStatus:aStatus];
    [self _doPutRequestWithPath:kRequestStatusLiveroomsUrl(aRoomId) parameters:@{@"status":value} completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            if (!error) {
                ret = YES;
            } else {
                NSString *errorDesc = [[NSString alloc] initWithData:[error.userInfo objectForKey:@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
                NSLog(@"%@",errorDesc);
            }
            aCompletion(ret);
        }
    }];
}

- (void)createLiveSessionWithRoom:(EaseLiveRoom*)aRoom
                       completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (aRoom) {
        if (aRoom.session.anchor.length > 0) {
            [parameters setObject:aRoom.session.anchor forKey:@"anchor"];
        }
        
        if (aRoom.title.length > 0) {
            [parameters setObject:aRoom.title forKey:@"title"];
        }
        
        if (aRoom.desc.length > 0) {
            [parameters setObject:aRoom.desc forKey:@"desc"];
        }
        
        if (aRoom.custom.length > 0) {
            [parameters setObject:aRoom.custom forKey:@"custom"];
        }
        
        if (aRoom.coverPictureUrl.length > 0) {
            [parameters setObject:aRoom.coverPictureUrl forKey:@"cover_picture_url"];
        }
        
        if (aRoom.needPassword) {
            [parameters setObject:@(YES) forKey:@"need_password"];
            if (aRoom.password.length > 0) {
                [parameters setObject:aRoom.password forKey:@"password"];
            }
        }
//        [parameters setObject:@"ongoing" forKey:@"status"];
    }
    
    [self _doPostRequestWithPath:kPostRequestCreateLiveSessionUrl(aRoom.roomId) parameters:parameters completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            EaseLiveRoom *room = nil;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject safeObjectForKey:@"data"];
                    if (data) {
                        [parameters addEntriesFromDictionary:[responseObject safeObjectForKey:@"data"]];
                    }
                    if (aRoom.chatroomId.length > 0) {
                        [parameters setObject:aRoom.chatroomId forKey:@"chatroom_id"];
                    }
                    if (aRoom.roomId.length > 0) {
                        [parameters setObject:aRoom.roomId forKey:@"liveroom_id"];
                    }
                    room = [[EaseLiveRoom alloc] initWithParameter:parameters];
                    ret = YES;
                }
            }
            aCompletion(room, ret);
        }
    }];
}

- (void)uploadFileWithData:(NSData*)aData
                completion:(void (^)(NSString *url, BOOL success))aCompletion
{
    [self _doUploadRequestWithPath:kPostRequestUploadFileUrl parameters:nil data:aData completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            NSString *imagePath = nil;
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSArray *entities = [responseObject safeObjectForKey:@"entities"];
                    NSString *uuid = @"";
                    if ([entities count] > 0) {
                        uuid = [[entities objectAtIndex:0] safeStringValueForKey:@"uuid"];
                    }
                    imagePath = [NSString stringWithFormat:@"%@/%@",[responseObject safeStringValueForKey:@"uri"] ,uuid];
                    ret = YES;
                }
            }
            aCompletion(imagePath, ret);
        }
    }];
}

- (void)savePraiseCountToServerWithRoomId:(NSString*)aRoomId
                                    count:(NSInteger)aCount
                               completion:(void (^)(NSInteger count, BOOL success))aCompletion
{
    [self _doPutCountWithRoomId:aRoomId
                           type:@"praise"
                          count:aCount
                     completion:aCompletion];
}

- (void)getPraiseCountToServerWithRoomId:(NSString*)aRoomId
                              completion:(void (^)(NSInteger count, BOOL success))aCompletion
{
    [self _doGetCountWithRoomId:aRoomId
                           type:@"praise"
                     completion:aCompletion];
}

- (void)saveGiftCountToServerWithRoomId:(NSString*)aRoomId
                                  count:(NSInteger)aCount
                             completion:(void (^)(NSInteger count, BOOL success))aCompletion
{
    [self _doPutCountWithRoomId:aRoomId
                           type:@"gift"
                          count:aCount
                     completion:aCompletion];
}

- (void)getGiftCountToServerWithRoomId:(NSString *)aRoomId
                            completion:(void (^)(NSInteger count, BOOL success))aCompletion
{
    [self _doGetCountWithRoomId:aRoomId
                           type:@"gift"
                     completion:aCompletion];
}

- (void)getLiveRoomListWithUsername:(NSString*)aUsername
                               page:(NSInteger)aPage
                           pagesize:(NSInteger)aPageSize
                         completion:(void (^)(NSArray *roomList, BOOL success))aCompletion
{
    [self _doGetRequestWithPath:kGetRequestGetLiveRoomListUrl(aUsername, (long)aPage, (long)aPageSize) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            NSArray *roomList = nil;
            BOOL ret = NO;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSArray *data = [responseObject objectForKey:@"data"];
                    if (data && [data isKindOfClass:[NSArray class]]) {
                        roomList = [NSArray arrayWithArray:data];
                        ret = YES;
                    }
                }
            }
            aCompletion(roomList, ret);
        }
    }];
}

- (void)setAdminForLiveRoomWithRoomId:(NSString*)aRoomId
                             username:(NSString*)aUsername
                             completion:(void (^)(BOOL success))aCompletion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (aUsername.length > 0) {
        [parameters setObject:aUsername forKey:@"newadmin"];
    }
    [self _doPostRequestWithPath:kPostRequestSetAdminUrl(aRoomId) parameters:parameters completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            if (!error) {
                ret = YES;
            }
            aCompletion(ret);
        }
    }];
}

- (void)deleteAdminForLiveRoomWithRoomId:(NSString*)aRoomId
                                username:(NSString*)aUsername
                              completion:(void (^)(BOOL success))aCompletion
{
    [self _doDeleteRequestWithPath:kDeleteRequestCancelAdminUrl(aRoomId, aUsername) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            if (!error) {
                ret = YES;
            }
            aCompletion(ret);
        }
    }];
}

- (void)joinLiveRoomWithRoomId:(NSString*)aRoomId
                    chatroomId:(NSString*)aChatroomId
                       isCount:(BOOL)aIsCount
                    completion:(void (^)(BOOL success))aCompletion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        [[EMClient sharedClient].roomManager joinChatroom:aChatroomId error:&error];
        BOOL ret = NO;
        if (!error) {
            if (aIsCount) {
                [weakSelf _doPutCountWithRoomId:aRoomId
                                           type:@"join"
                                          count:1
                                     completion:NULL];
            }
            ret = YES;
        }
        
        if (aCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                aCompletion(ret);
            });
        }
    });
}

- (void)leaveLiveRoomWithRoomId:(NSString*)aRoomId
                     chatroomId:(NSString*)aChatroomId
                        isCount:(BOOL)aIsCount
                     completion:(void (^)(BOOL success))aCompletion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        [[EMClient sharedClient].roomManager leaveChatroom:aChatroomId error:&error];
        BOOL ret = NO;
        if (!error) {
            if (aIsCount) {
                [weakSelf _doPutCountWithRoomId:aRoomId
                                           type:@"leave"
                                          count:1
                                     completion:NULL];
            }
            ret = YES;
        }
        
        if (aCompletion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                aCompletion(ret);
            });
        }
    });
}

- (void)kickUserFromLiveRoomWithRoomId:(NSString*)aRoomId
                              username:(NSString*)aUsername
                            completion:(void (^)(BOOL success))aCompletion
{
    [self _doDeleteRequestWithPath:kDeleteRequestKickMemberUrl(aRoomId, aUsername) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            if (!error) {
                ret = YES;
            }
            aCompletion(ret);
        }
    }];
}

- (void)getLiveRoomCurrentWithRoomId:(NSString*)aRoomId
                          completion:(void (^)(EaseLiveSession *session, BOOL success))aCompletion
{
    [self _doGetRequestWithPath:kGetRequestCurrentLiveroomsUrl(aRoomId) parameters:nil completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            EaseLiveSession *session = nil;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        session = [[EaseLiveSession alloc] initWithParameter:data];
                        ret = YES;
                    }
                }
            }
            aCompletion(session, ret);
        }
    }];
}

#pragma mark - private

- (void)_doPutCountWithRoomId:(NSString*)aRoomId
                         type:(NSString*)aType
                        count:(NSInteger)aCount
                   completion:(void (^)(NSInteger count, BOOL success))aCompletion
{
    NSDictionary *parameters = nil;
    if ([aType isEqualToString:@"join"] || [aType isEqualToString:@"leave"]) {
        parameters = @{@"count":[EMClient sharedClient].currentUsername,@"type":aType};
    } else {
        parameters = @{@"count":@(aCount),@"type":aType};
    }
    [self _doPutRequestWithPath:kRequestCountUrl(aRoomId) parameters:parameters completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            NSInteger count = 0;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        count = [data safeIntegerValueForKey:@"result"];
                        ret = YES;
                    }
                }
            }
            aCompletion(count, ret);
        }
    }];
}

- (void)_doGetCountWithRoomId:(NSString*)aRoomId
                         type:(NSString*)aType
                   completion:(void (^)(NSInteger count, BOOL success))aCompletion
{
    [self _doGetRequestWithPath:kRequestCountUrl(aRoomId) parameters:@{@"type":aType} completion:^(id responseObject, NSError *error) {
        if (aCompletion) {
            BOOL ret = NO;
            NSInteger count = 0;
            if (!error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data) {
                        count = [data safeIntegerValueForKey:@"count"];
                        ret = YES;
                    }
                }
            }
            aCompletion(count, ret);
        }
    }];
}

- (void)_doGetRequestWithPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                   completion:(void (^)(id responseObject, NSError *error))completion
{
    [self _setHeaderToken];
    [_sessionManager GET:path
              parameters:parameters
                progress:^(NSProgress * _Nonnull downloadProgress) {
                  
              } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  if (completion) {
                      completion(responseObject, nil);
                  }
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  if (completion) {
                      completion(nil, error);
                  }
              }];
}

- (void)_doPutRequestWithPath:(NSString*)path
                   parameters:(NSDictionary*)parameters
                   completion:(void (^)(id responseObject, NSError *error))completion
{
    [self _setHeaderToken];
    [_sessionManager PUT:path
              parameters:parameters
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     if (completion) {
                         completion(responseObject, nil);
                     }
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     if (completion) {
                         completion(nil, error);
                     }
                 }];
}

- (void)_doPostRequestWithPath:(NSString*)path
                    parameters:(NSDictionary*)parameters
                    completion:(void (^)(id responseObject, NSError *error))completion
{
    [self _setHeaderToken];
    [_sessionManager POST:path
               parameters:parameters
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     if (completion) {
                         completion(responseObject, nil);
                     }
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     if (completion) {
                         completion(nil, error);
                     }
                 }];
}

- (void)_doDeleteRequestWithPath:(NSString*)path
                      parameters:(NSDictionary*)parameters
                      completion:(void (^)(id responseObject, NSError *error))completion
{
    [self _setHeaderToken];
    [_sessionManager DELETE:path
                 parameters:parameters
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        if (completion) {
                            completion(responseObject, nil);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (completion) {
                            completion(nil, error);
                        }
                    }];
}

- (void)_doUploadRequestWithPath:(NSString*)path
                      parameters:(NSDictionary*)parameters
                            data:(NSData*)data
                      completion:(void (^)(id responseObject, NSError *error))completion
{
    [self _setHeaderToken];
    [_sessionManager POST:path
               parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFileData:data name:@"file" fileName:[NSString stringWithFormat:@"%d.jpeg", (int)([[NSDate date] timeIntervalSince1970]*1000)] mimeType:@"image/jpeg"];
} progress:^(NSProgress * _Nonnull uploadProgress) {
    
} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    if (completion) {
        completion(responseObject, nil);
    }
} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    if (completion) {
        completion(nil, error);
    }
}];
    
}

- (void)_setHeaderToken
{
    [[_sessionManager requestSerializer] setValue:[NSString stringWithFormat:@"Bearer %@", [self _getUserToken]] forHTTPHeaderField:@"Authorization"];
}

- (NSString*)_getUserToken
{
    NSString *userToken = nil;
    BOOL isRefresh = NO;
    EMClient *client = [EMClient sharedClient];
    SEL selector = NSSelectorFromString(@"getUserToken:");
    if ([client respondsToSelector:selector]) {
        IMP imp = [client methodForSelector:selector];
        NSString *(*func)(id, SEL, NSNumber *) = (void *)imp;
        userToken = func(client, selector, @(isRefresh));
    }
    return userToken;
}

@end
