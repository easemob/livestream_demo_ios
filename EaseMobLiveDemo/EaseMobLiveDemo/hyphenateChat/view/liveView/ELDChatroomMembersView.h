//
//  ELDChatroomMembersView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/12.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@class EaseBaseSubView;
@protocol ELDChatroomMembersViewDelegate <NSObject>

- (void)selectedUser:(NSString *)userId memberVCType:(ELDMemberVCType)memberVCType chatRoom:(EMChatroom *)chatroom;

@end


@interface ELDChatroomMembersView : EaseBaseSubView
@property (nonatomic, weak) id<ELDChatroomMembersViewDelegate> selectedUserDelegate;

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom;

- (void)updateWithChatroom:(EMChatroom *)aChatroom;

@end

NS_ASSUME_NONNULL_END
