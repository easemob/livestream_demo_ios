//
//  EaseChatView.h
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseCustomMessageHelper.h"
#import "EaseChatViewCustomOption.h"

@class EMChatMessage;
@class EaseLiveRoom;

@protocol EaseChatViewDelegate <NSObject>

@optional

/// display custom message cell at indexpath
/// @param indexPath indexPath
- (UITableViewCell *)easeMessageCellForRowAtIndexPath:(NSIndexPath *)indexPath;


/// height for custom message cell at indexpath
/// @param indexPath indexPath
- (CGFloat)easeMessageCellHeightAtIndexPath:(NSIndexPath *)indexPath;


/// display custom join cell at indexpath
/// @param indexPath indexPath
- (UITableViewCell *)easeJoinCellForRowAtIndexPath:(NSIndexPath *)indexPath;


/// height for custom join cell at indexpath
/// @param indexPath indexPath
- (CGFloat)easeJoinCellHeightAtIndexPath:(NSIndexPath *)indexPath;


/// tap  message callback
/// @param message  tap message
- (void)didSelectUserWithMessage:(EMChatMessage*)message;


/// change chatview offset from bottom
/// @param offset offset from bottom
- (void)chatViewDidBottomOffset:(CGFloat)offset;


/// chatview send message
/// @param message send message
/// @param error error
- (void)chatViewDidSendMessage:(EMChatMessage *)message
                         error:(EMError *)error;

@end

@interface EaseChatView : UIView

@property (nonatomic, weak) id<EaseChatViewDelegate> delegate;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *sendTextButton;
@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic,assign) BOOL isMuted;


/// Init a chatView
/// @param frame assign frame
/// @param chatroom a EMChatroom
/// @param customMsgHelper a EaseCustomMessageHelper
/// @param customOption a EaseChatViewCustomOption
- (instancetype)initWithFrame:(CGRect)frame
                     chatroom:(EMChatroom*)chatroom
              customMsgHelper:(EaseCustomMessageHelper*)customMsgHelper
                 customOption:(EaseChatViewCustomOption *)customOption;


/// send gift
/// @param giftId  a giftId
/// @param num gift num
/// @param aCompletion a callback send gift message
- (void)sendGiftAction:(NSString *)giftId
                   num:(NSInteger)num
            completion:(void (^)(BOOL success))aCompletion;


/// display or hidden chatview
/// @param isHidden whether hidden
- (void)updateChatViewWithHidden:(BOOL)isHidden;


/// update sendTextButton title
/// @param hint sendTextButton title
- (void)updateSendTextButtonHint:(NSString *)hint;

@end
