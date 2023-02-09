//
//  EaseChatViewCustomOption.h
//  chat-uikit
//
//  Created by liu001 on 2022/5/18.
//

#import <Foundation/Foundation.h>
#import "EaseChatEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseChatViewCustomOption : NSObject
+ (EaseChatViewCustomOption *)customOption;

/**
 * set custom tableview message cell
 */
@property (nonatomic, assign) BOOL customMessageCell;
/**
 * set custom user join cell
 */
@property (nonatomic, assign) BOOL customJoinCell;

/**
 * set tableView backgroud color
 */
@property (nonatomic, strong) UIColor *tableViewBgColor;

/**
 * set right margin of EaseChatView
 */
@property (nonatomic, assign) CGFloat tableViewRightMargin;

/**
 * set sendTextButton bottom margin of EaseChatView
 */
@property (nonatomic, assign) CGFloat sendTextButtonBottomMargin;

/**
 * set sendTextButton right margin of EaseChatView
 */
@property (nonatomic, assign) CGFloat sendTextButtonRightMargin;

/**
 * set whether display sender avatarImageView
 */
@property (nonatomic, assign) BOOL   displaySenderAvatar;

/**
 * set whether display sender nickname
 */
@property (nonatomic, assign) BOOL   displaySenderNickname;

/**
 * Avatar style
 */
@property (nonatomic) EaseChatAvatarStyle avatarStyle;

/**
 * Avatar cornerRadius Default: 0 (Only avatar type RoundedCorner)
 */
@property (nonatomic) CGFloat avatarCornerRadius;

/**
 * set cell contentview backgroud color
 */
@property (nonatomic, strong) UIColor *cellBgColor;

/**
 * set nameLabel text font size
 */
@property (nonatomic, assign) CGFloat nameLabelFontSize;
/**
 * set nameLabel text color
 */
@property (nonatomic, strong) UIColor *nameLabelColor;
/**
 * set messageLabel font size
 */
@property (nonatomic, assign) CGFloat messageLabelSize;

/**
 * set messageLabel text color
 */
@property (nonatomic, strong) UIColor *messageLabelColor;


@end

NS_ASSUME_NONNULL_END
