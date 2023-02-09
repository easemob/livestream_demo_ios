//
//  ELDLiveroomMemberAllViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/8.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELDContainerTableViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface ELDLiveroomMembersViewController : ELDContainerTableViewController
@property (nonatomic, copy)void (^selectedUserBlock)(NSString *userId,ELDMemberVCType memberVCType);

@property (nonatomic, assign) NSInteger isAdmin;

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom withMemberType:(ELDMemberVCType)memberVCType;

- (void)updateUIWithChatroom:(EMChatroom *)chatroom;

@end

NS_ASSUME_NONNULL_END
