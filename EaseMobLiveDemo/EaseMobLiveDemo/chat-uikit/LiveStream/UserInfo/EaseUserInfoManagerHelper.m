//
//  EMUserInfoManagerHelper.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "EaseUserInfoManagerHelper.h"
#import "EMUserInfo+expireTime.h"
#import "EaseKitDefine.h"

#define kExpireSeconds 20

@interface EaseUserInfoManagerHelper ()
@property (nonatomic, strong)NSMutableDictionary *userInfoCacheDic;

@end


@implementation EaseUserInfoManagerHelper
static EaseUserInfoManagerHelper *instance = nil;
+ (EaseUserInfoManagerHelper *)sharedHelper {
static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[EaseUserInfoManagerHelper alloc]init];
    });
    return instance;
}

+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedHelper] fetchUserInfoWithUserIds:userIds completion:completion];
}


+ (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes completion:(void (^)(NSDictionary * _Nonnull))completion {
    [[self sharedHelper] fetchUserInfoWithUserIds:userIds userInfoTypes:userInfoTypes completion:completion];
}


+ (void)updateUserInfo:(EMUserInfo *)userInfo completion:(void (^)(EMUserInfo * _Nonnull))completion {
    [[self sharedHelper] updateUserInfo:userInfo completion:completion];
}

+ (void)updateUserInfoWithUserId:(NSString *)userId withType:(EMUserInfoType)type completion:(void (^)(EMUserInfo * _Nonnull))completion {
    [[self sharedHelper] updateUserInfoWithUserId:userId withType:type completion:completion];
}

+ (void)fetchOwnUserInfoCompletion:(void(^)(EMUserInfo *ownUserInfo))completion {
    [[self sharedHelper] fetchOwnUserInfoCompletion:completion];
}

#pragma mark instance method
- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    EaseKit_WS
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,EMUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {
            [[EMClient sharedClient].userInfoManager fetchUserInfoById:reqIds completion:^(NSDictionary *aUserDatas, EMError *aError) {
                if (!aError) {
                    for (NSString *userKey in aUserDatas.allKeys) {
                        if (userKey.length <= 0) {
                            continue;
                        }
                        EMUserInfo *user = aUserDatas[userKey];
                        if (!user) {
                            continue;
                        }
                        user.expireTime = [[NSDate date] timeIntervalSince1970];
                        if (user) {
                            resultDic[userKey] = user;
                            if (weakSelf.userInfoCacheDic == nil) {
                                weakSelf.userInfoCacheDic = [[NSMutableDictionary alloc] init];
                            }
                            weakSelf.userInfoCacheDic[userKey] = user;
                        }
                    }
                }
                
                if (resultDic && completion) {
                    completion(resultDic);
                }
            }];
        }
    }];

}

- (void)fetchUserInfoWithUserIds:(NSArray<NSString *> *)userIds
                   userInfoTypes:(NSArray<NSNumber *> *)userInfoTypes
                      completion:(void(^)(NSDictionary *userInfoDic))completion {
    
    if (userIds.count == 0) {
        return;
    }
    
    [self splitUserIds:userIds completion:^(NSMutableDictionary<NSString *,EMUserInfo *> *resultDic, NSMutableArray<NSString *> *reqIds) {
        if (reqIds.count == 0) {
            if (resultDic && completion) {
                completion(resultDic);
            }
            return;
        }else {

            [[EMClient sharedClient].userInfoManager fetchUserInfoById:userIds type:userInfoTypes completion:^(NSDictionary *aUserDatas, EMError *aError) {
                for (NSString *userKey in aUserDatas.allKeys) {
                    EMUserInfo *user = aUserDatas[userKey];
                    user.expireTime = [[NSDate date] timeIntervalSince1970];
                    if (user) {
                        resultDic[userKey] = user;
                        self.userInfoCacheDic[userKey] = user;
                    }
                }
                if (resultDic && completion) {
                    completion(resultDic);
                }
            }];
            
        }
    }];
    
    
}

- (void)updateUserInfo:(EMUserInfo *)userInfo
                       completion:(void(^)(EMUserInfo *aUserInfo))completion {
    
    [[EMClient sharedClient].userInfoManager updateOwnUserInfo:userInfo completion:^(EMUserInfo *aUserInfo, EMError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

- (void)updateUserInfoWithUserId:(NSString *)userId
                        withType:(EMUserInfoType)type
                      completion:(void(^)(EMUserInfo *aUserInfo))completion {
    [[EMClient sharedClient].userInfoManager updateOwnUserInfo:userId withType:type completion:^(EMUserInfo *aUserInfo, EMError *aError) {
        if (aUserInfo && completion) {
            completion(aUserInfo);
        }
    }];
    
}

- (void)fetchUserInfoModelsWithUserId:(NSArray *)userIds completion:(void (^)(NSDictionary * _Nonnull))completion {
    if (userIds.count == 0) {
        return;
    }
    
    if (self.userInfoCacheDic.count > 0 && completion) {
        completion(self.userInfoCacheDic);
    }
}

#pragma mark private method
- (void)splitUserIds:(NSArray *)userIds
          completion:(void(^)(NSMutableDictionary<NSString *,EMUserInfo *> *resultDic,NSMutableArray<NSString *> *reqIds))completion {
    
    NSMutableDictionary<NSString *,EMUserInfo *> *resultDic = NSMutableDictionary.new;
    NSMutableArray<NSString *> *reqIds = NSMutableArray.new;
    
    for (NSString *userId in userIds) {
        EMUserInfo *user = self.userInfoCacheDic[userId];
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970] - user.expireTime;
        if (delta > kExpireSeconds || !user) {
            [reqIds addObject:userId];
        }else {
            resultDic[userId] = user;
        }
    }
    if (completion) {
        completion(resultDic,reqIds);
    }
}


- (void)fetchOwnUserInfoCompletion:(void(^)(EMUserInfo *ownUserInfo))completion {
    NSString *userId = [EMClient sharedClient].currentUsername;
    if (userId == nil) {
        userId = @"";
    }
    [[EMClient sharedClient].userInfoManager fetchUserInfoById:@[userId] completion:^(NSDictionary *aUserDatas, EMError *aError) {
        EMUserInfo *user = aUserDatas[userId];
        if (completion) {
            completion(user);
        }
    }];
}



#pragma mark getter and setter
- (NSMutableDictionary *)userInfoCacheDic {
    if (_userInfoCacheDic == nil) {
        _userInfoCacheDic = NSMutableDictionary.new;
    }
    return _userInfoCacheDic;
}


@end

#undef kExpireSeconds

