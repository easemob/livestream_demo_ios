//
//  ELDChatViewHelper.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/24.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDChatViewHelper : NSObject

+ (instancetype)sharedHelper;

- (void)joinChatroomWithChatroomId:(NSString *)chatroomId
                        completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletion;

- (void)leaveChatroomId:(NSString *)chatroomId
             completion:(void (^)(BOOL success))aCompletion;



@end

NS_ASSUME_NONNULL_END
