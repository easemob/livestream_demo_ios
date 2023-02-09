//
//  ELDChatViewHelper.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/24.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatViewHelper.h"

static ELDChatViewHelper *shareHelper = nil;

@implementation ELDChatViewHelper

+ (instancetype)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareHelper = [[ELDChatViewHelper alloc] init];
    });
    
    return shareHelper;
}

- (void)joinChatroomWithChatroomId:(NSString *)chatroomId
                        completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletion
{
    [[EaseHttpManager sharedInstance] joinLiveRoomWithRoomId:chatroomId
                  chatroomId:chatroomId
                  completion:aCompletion];
}

- (void)leaveChatroomId:(NSString *)chatroomId
             completion:(void (^)(BOOL success))aCompletion
{
    [[EaseHttpManager sharedInstance] leaveLiveRoomWithRoomId:chatroomId
    chatroomId:chatroomId
    completion:^(BOOL success) {
       BOOL ret = NO;
       if (success) {
           [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:NULL];
           ret = YES;
       }
       aCompletion(ret);
    }];
}

@end
