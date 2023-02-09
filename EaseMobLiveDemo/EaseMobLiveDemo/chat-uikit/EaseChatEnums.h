//
//  EaseChatEnums.h
//
//  Created by dujiepoeng on 2020/11/19.
//

#ifndef EaseChatEnums_h
#define EaseChatEnums_h


#endif /* EaseChatEnums_h */

/*!
 *  avatarStyle
 */
typedef NS_ENUM(NSInteger, EaseChatAvatarStyle) {
    RoundedCorner = 0,      //Rounded Corner
    Rectangular,            //Rectangular
    Circular,               //Circular
};

/*!
 *  view position is not read
 */
typedef NS_ENUM(NSInteger, EaseChatUnReadCountViewPosition) {
    EaseCellRight = 0,    //The right of the cell
    EaseAvatarTopRight,   //Top right corner of profile picture
};

/*!
 *  unread view style: red dot, unread number
 */
typedef NS_ENUM(NSInteger, EaseChatUnReadBadgeViewStyle) {
    EaseUnreadBadgeViewRedDot = 0,  //Unread red dot
    EaseUnreadBadgeViewNumber,      //Unread number
};

/*!
 *  top style
 */
typedef NS_ENUM(NSInteger, EaseChatConversationTopStyle) {
    EaseConversationTopBgColorStyle = 0,    //BgColorStyle
    EaseConversationTopIconStyle,           //IconStyle
};

/*!
 *  system Notification Type
 */
typedef NS_ENUM(NSInteger, EaseChatKitCallBackReason) {
    ContanctsRequestDidReceive = 0,     //Add as contact request
    ContanctsRequestDidAgree = 1,       //Contact request was approved
    
    GroupInvitationDidReceive = 10,     //Add group invited
    JoinGroupRequestDidReceive = 11,    //Add group to apply for
};


/*!
 *  weak alert message
 */
typedef NS_ENUM(NSInteger, EaseChatWeakRemind) {
    EaseChatWeakRemindSystemHint = 0,   //System prompt
    EaseChatWeakRemindMsgTime = 10,     //Message time
};
