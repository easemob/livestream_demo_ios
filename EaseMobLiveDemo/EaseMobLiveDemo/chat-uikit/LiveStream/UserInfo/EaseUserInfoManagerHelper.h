//
//  EMUserInfoManager.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseUserInfoManagerHelper : NSObject

@property (nonatomic, strong, readonly)NSMutableDictionary *userInfoCacheDic;


/// create EaseUserInfoManagerHelper instance.
+ (EaseUserInfoManagerHelper *)sharedHelper;


/// fetch userInfos
/// @param userIds userIds
/// @param completion completion
+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion;


/// fetch user information by user ID and information type
/// @param userIds userIds
/// @param userInfoTypes userInfo types
/// @param completion completion
+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion;


/// Update user information
/// @param userInfo userInfo
/// @param completion completion
+ (void)updateUserInfo:(EMUserInfo *)userInfo
            completion:(void(^)(EMUserInfo *aUserInfo))completion;



/// Update user information
/// @param userId user ID
/// @param type userInfo type
/// @param completion completion
+ (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(EMUserInfoType)type
                      completion:(void(^)(EMUserInfo *aUserInfo))completion;


/// Obtain personal user information
/// @param completion completion
+ (void)fetchOwnUserInfoCompletion:(void(^)(EMUserInfo *ownUserInfo))completion;


@end

NS_ASSUME_NONNULL_END
