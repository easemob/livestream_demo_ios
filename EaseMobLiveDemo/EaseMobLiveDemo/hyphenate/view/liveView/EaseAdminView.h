//
//  EaseAdminView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/28.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseBaseSubView.h"

@protocol EaseMuteDelegate <NSObject>

@required
- (void)muteStatusDidchange:(EMChatroom *)chatRoom;

@end


@interface EaseAdminView : EaseBaseSubView

- (instancetype)initWithChatroomId:(EaseLiveRoom*)liveroom
                           isOwner:(BOOL)isOwner
                        currentMemberList:(NSMutableArray*)currentMemberList;

@property (nonatomic, weak) id<EaseMuteDelegate> muteDelegate;

@end


