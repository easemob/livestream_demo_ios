//
//  EaseHttpManager.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/13.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EaseLiveRoom.h"

@interface EaseHttpManager : NSObject

+ (instancetype)sharedInstance;

/*
 *  创建直播聊天室
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)createLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;

/*
 *  修改直播聊天室
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)modifyLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;


/*
 *  获取直播聊天室详情
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCompletion      完成的回调block
 */
- (void)getLiveRoomWithRoomId:(NSString*)aRoomId
                   completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;

/*
 *  删除直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCompletion      完成的回调block
 */
- (void)deleteLiveRoomWithRoomId:(NSString*)aRoomId
                      completion:(void (^)(BOOL success))aCompletion;

/*
 *  获取正在直播聊天室列表
 *
 *  @param aCursor          游标
 *  @param aLimit           预期获取的记录数
 *  @param aCompletion      完成的回调block
 */
- (void)fetchLiveRoomsOngoingWithCursor:(NSString*)aCursor
                                  limit:(NSInteger)aLimit
                             completion:(void (^)(EMCursorResult *result, BOOL success))aCompletion;

/*
 *  获取直播聊天室状态
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCompletion      完成的回调block
 */
- (void)getLiveRoomStatusWithRoomId:(NSString*)aRoomId
                         completion:(void (^)(EaseLiveSessionStatus status, BOOL success))aCompletion;

/*
 *  修改直播聊天室状态
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aStatus          直播聊天室状态
 *  @param aCompletion      完成的回调block
 */
- (void)modifyLiveRoomStatusWithRoomId:(NSString*)aRoomId
                                status:(EaseLiveSessionStatus)aStatus
                            completion:(void (^)(BOOL success))aCompletion;

/*
 *  创建新的直播场次
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)createLiveSessionWithRoom:(EaseLiveRoom*)aRoom
                       completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;

/*
 *  增加点赞数量
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCount           点赞数量
 *  @param aCompletion      完成的回调block
 */
- (void)savePraiseCountToServerWithRoomId:(NSString*)aRoomId
                                    count:(NSInteger)aCount
                               completion:(void (^)(NSInteger count, BOOL success))aCompletion;

/*
 *  获取点赞数量
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCompletion      完成的回调block
 */
- (void)getPraiseCountToServerWithRoomId:(NSString*)aRoomId
                              completion:(void (^)(NSInteger count, BOOL success))aCompletion;


/*
 *  增加礼物数量
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCount           礼物数量
 *  @param aCompletion      完成的回调block
 */
- (void)saveGiftCountToServerWithRoomId:(NSString*)aRoomId
                                  count:(NSInteger)aCount
                             completion:(void (^)(NSInteger count, BOOL success))aCompletion;

/*
 *  获取礼物数量
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCompletion      完成的回调block
 */
- (void)getGiftCountToServerWithRoomId:(NSString *)aRoomId
                            completion:(void (^)(NSInteger count, BOOL success))aCompletion;
/*
 *  获取一个主播关联的直播聊天室列表
 *
 *  @param aUsername        直播环信ID
 *  @param aPage            获取第几页
 *  @param aPageSize        获取多少条
 *  @param aCompletion      完成的回调block
 */
- (void)getLiveRoomListWithUsername:(NSString*)aUsername
                               page:(NSInteger)aPage
                           pagesize:(NSInteger)aPageSize
                         completion:(void (^)(NSArray *roomList, BOOL success))aCompletion;

/*
 *  直播聊天室添加管理员信息
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aUsername        直播环信ID
 *  @param aCompletion      完成的回调block
 */
- (void)setAdminForLiveRoomWithRoomId:(NSString*)aRoomId
                             username:(NSString*)aUsername
                           completion:(void (^)(BOOL success))aCompletion;

/*
 *  直播聊天室移除管理员
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aUsername        直播环信ID
 *  @param aCompletion      完成的回调block
 */
- (void)deleteAdminForLiveRoomWithRoomId:(NSString*)aRoomId
                                username:(NSString*)aUsername
                              completion:(void (^)(BOOL success))aCompletion;

/*
 *  用户加入直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 *  @param aIsCount         是否计数
 *  @param aCompletion      完成的回调block
 */
- (void)joinLiveRoomWithRoomId:(NSString*)aRoomId
                    chatroomId:(NSString*)aChatroomId
                       isCount:(BOOL)aIsCount
                    completion:(void (^)(BOOL success))aCompletion;

/*
 *  用户离开直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 *  @param aIsCount         是否计数
 *  @param aCompletion      完成的回调block
 */
- (void)leaveLiveRoomWithRoomId:(NSString*)aRoomId
                     chatroomId:(NSString*)aChatroomId
                        isCount:(BOOL)aIsCount
                     completion:(void (^)(BOOL success))aCompletion;

/*
 *  将用户踢出直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aUsername        直播环信ID
 *  @param aCompletion      完成的回调block
 */
- (void)kickUserFromLiveRoomWithRoomId:(NSString*)aRoomId
                              username:(NSString*)aUsername
                            completion:(void (^)(BOOL success))aCompletion;

/*
 *  获取某个直播房间当前直播场次的实时数据(直播状态，在线人数，总观看人数)
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aCompletion      完成的回调block
 */
- (void)getLiveRoomCurrentWithRoomId:(NSString*)aRoomId
                          completion:(void (^)(EaseLiveSession *session, BOOL success))aCompletion;

/*
 *  上传文件
 *
 *  @param aData            文件数据
 *  @param aCompletion      完成的回调block
 */
- (void)uploadFileWithData:(NSData*)aData
                completion:(void (^)(NSString *url, BOOL success))aCompletion;

@end
