//
//  EaseDefines.h
//  EaseChatKit
//
//  Created by XieYajie on 2019/2/11.
//  Copyright © 2019 XieYajie. All rights reserved.
//


#ifndef EaseDefines_h
#define EaseDefines_h

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#define EaseVIEWBOTTOMMARGIN (kIsBangsScreen ? 34.f : 0.f)

#define EMNavgationHeight (kIsBangsScreen ? 87.f : 64.f)

#define EMScreenHeight [UIScreen mainScreen].bounds.size.height

#define EMScreenWidth [UIScreen mainScreen].bounds.size.width

#define EaseSYSTEMNOTIFICATIONID @"Easesystemnotificationid"

//账号状态
#define ACCOUNT_LOGIN_CHANGED @"loginStateChange"

#define NOTIF_ID @"EaseNotifId"
#define NOTIF_NAVICONTROLLER @"EaseNaviController"

//会话列表
#define CONVERSATIONLIST_UPDATE @"ConversationListUpdate"

//聊天
#define CHAT_PUSHVIEWCONTROLLER @"EasePushChatViewController"
#define CHAT_CLEANMESSAGES @"EaseChatCleanMessages"

//编辑状态
#define MSG_TYPING_BEGIN @"TypingBegin"
#define MSG_TYPING_END @"TypingEnd"

//通话
#define EaseCOMMMUNICATE_RECORD @"EaseCommunicateRecord" //本地通话记录
#define EaseCOMMMUNICATE @"EaseCommunicate" //远端通话记录
#define EaseCOMMUNICATE_TYPE @"EaseCommunicateType"
#define EaseCOMMUNICATE_TYPE_VOICE @"EaseCommunicateTypeVoice"
#define EaseCOMMUNICATE_TYPE_VIDEO @"EaseCommunicateTypeVideo"
#define EaseCOMMUNICATE_DURATION_TIME @"EaseCommunicateDurationTime"

//通话状态
#define EaseCOMMUNICATE_MISSED_CALL @"EaseCommunicateMissedCall" //（通话取消）
#define EaseCOMMUNICATE_CALLER_MISSEDCALL @"EaseCommunicateCallerMissedCall" //（我方取消通话）
#define EaseCOMMUNICATE_CALLED_MISSEDCALL @"EaseCommunicateCalledMissedCall" //（对方拒绝接通）
//发起邀请
#define EaseCOMMUNICATE_CALLINVITE @"EaseCommunicateCallInvite" //（发起通话邀请）
//通话发起方
#define EaseCOMMUNICATE_DIRECTION @"EaseCommunicateDirection"
#define EaseCOMMUNICATE_DIRECTION_CALLEDPARTY @"EaseCommunicateDirectionCalledParty"
#define EaseCOMMUNICATE_DIRECTION_CALLINGPARTY @"EaseCommunicateDirectionCallingParty"

//消息动图
#define MSG_EXT_GIF_ID @"Ease_expression_id"
#define MSG_EXT_GIF @"Ease_is_big_expression"

#define MSG_EXT_READ_RECEIPT @"Ease_read_receipt"

//消息撤回
#define MSG_EXT_RECALL @"Ease_recall"

//新通知
#define MSG_EXT_NEWNOTI @"Ease_noti"
#define SYSTEM_NOTI_TYPE @"system_noti_type"
#define SYSTEM_NOTI_TYPE_CONTANCTSREQUEST @"ContanctsRequest"
#define SYSTEM_NOTI_TYPE_GROUPINVITATION  @"GroupInvitation"
#define SYSTEM_NOTI_TYPE_JOINGROUPREQUEST @"JoinGroupRequest"

//加群/好友 成功
#define NOTIF_ADD_SOCIAL_CONTACT @"EaseAddSocialContact"

//加群/好友 类型
#define NOTI_EXT_ADDFRIEND @"add_friend"
#define NOTI_EXT_ADDGROUP @"add_group"

//多人会议邀请
#define MSG_EXT_CALLOP @"Ease_conference_op"
#define MSG_EXT_CALLID @"Ease_conference_id"
#define MSG_EXT_CALLPSWD @"Ease_conference_password"

//语音状态变化
#define AUDIOMSGSTATECHANGE @"audio_msg_state_change"

//实时音视频
#define CALL_CHATTER @"chatter"
#define CALL_TYPE @"type"
#define CALL_PUSH_VIEWCONTROLLER @"EasePushCallViewController"
//实时音视频1v1呼叫
#define CALL_MAKE1V1 @"EaseMake1v1Call"
//实时音视频多人
#define CALL_MODEL @"EaseCallForModel"
#define CALL_MAKECONFERENCE @"EaseMakeConference"
#define CALL_SELECTCONFERENCECELL @"EaseSelectConferenceCell"
#define CALL_INVITECONFERENCEVIEW @"EaseInviteConverfenceView"

//用户黑名单
#define CONTACT_BLACKLIST_UPDATE @"EaseContactBlacklistUpdate"
#define CONTACT_BLACKLIST_RELOAD @"EaseContactReloadBlacklist"

//群组
#define GROUP_LIST_PUSHVIEWCONTROLLER @"EasePushGroupsViewController"
#define GROUP_INFO_UPDATED @"EaseGroupInfoUpdated"
#define GROUP_SUBJECT_UPDATED @"EaseGroupSubjectUpdated"
#define GROUP_INFO_REFRESH @"EaseGroupInfoRefresh"
#define GROUP_INFO_PUSHVIEWCONTROLLER @"EasePushGroupInfoViewController"
#define GROUP_INFO_CLEARRECORD @"EaseGroupInfoClearRecord"

//聊天室
#define CHATROOM_LIST_PUSHVIEWCONTROLLER @"EasePushChatroomsViewController"
#define CHATROOM_INFO_UPDATED @"EaseChatroomInfoUpdated"
#define CHATROOM_INFO_PUSHVIEWCONTROLLER @"EasePushChatroomInfoViewController"


//custom message type
#define kCustomMsgChatroomGift @"chatroom_gift"
#define kCustomMsgChatroomPraise @"chatroom_praise"
#define kCustomMsgChatroomBarrage @"chatroom_barrage"

//send or receive
#define kGiftIdKey @"gift_id"
#define kGiftNumKey @"gift_num"

#define EaseKit_chatroom_join @"chatroom_join"


#endif /* EaseDefines_h */
