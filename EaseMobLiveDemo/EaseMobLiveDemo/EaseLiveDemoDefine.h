/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#ifndef EaseLiveDemoDefine_h
#define EaseLiveDemoDefine_h

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})


#define AgoraChatVIEWTOPMARGIN (kIsBangsScreen ? 34.f : 0.f)

#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX KScreenWidth >=375.0f && KScreenHeight >=812.0f&& kIs_iphone
 
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX?(44.0):(20.0))
#define kNavBarHeight (44)

#define kNavBarAndStatusBarHeight (CGFloat)(kIs_iPhoneX?(88.0):(64.0))

#define kTabBarHeight (CGFloat)(kIs_iPhoneX?(49.0 + 34.0):(49.0))

#define kTopBarSafeHeight (CGFloat)(kIs_iPhoneX?(44.0):(0))

#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX?(34.0):(0))

#define kTopBarDifHeight (CGFloat)(kIs_iPhoneX?(24.0):(0))

#define kNavAndTabHeight (kNavBarAndStatusBarHeight + kTabBarHeight)

#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth  [[UIScreen mainScreen] bounds].size.width



#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// rgb颜色转换（16进制->10进制）
#define COLOR_HEXA(__RGB,__ALPHA) [UIColor colorWithRed:((float)((__RGB & 0xFF0000) >> 16))/255.0 green:((float)((__RGB & 0xFF00) >> 8))/255.0 blue:((float)(__RGB & 0xFF))/255.0 alpha:__ALPHA]

#define COLOR_HEX(__RGB) COLOR_HEXA(__RGB,1.0f)

#define WEAK_SELF typeof(self) __weak weakSelf = self;

//weak & strong self
#define ELD_WS                  __weak __typeof(&*self)weakSelf = self;
#define ELD_SS(WKSELF)          __strong __typeof(&*self)strongSelf = WKSELF;

#define ELD_ONE_PX  (1.0f / [UIScreen mainScreen].scale)

#define  EASELIVEDEMO_POSTNOTIFY(name,object)  [[NSNotificationCenter defaultCenter] postNotificationName:name object:object]

#define  EASELIVEDEMO_LISTENNOTIFY(name,SEL) [[NSNotificationCenter defaultCenter] addObserver:self selector:SEL name:name object:nil]
  
#define EASELIVEDEMO_REMOVENOTIFY(observer) [[NSNotificationCenter defaultCenter] removeObserver:observer]


#define ImageWithName(imageName) [UIImage imageNamed:imageName]

#define kEaseLiveDemoPadding 10.0f
#define kAvatarHeight 32.0f
#define kContactAvatarHeight 40.0f
#define kSearchBarHeight 32.0

//fonts
#define NFont(__SIZE) [UIFont systemFontOfSize:__SIZE] //system font with size
#define IFont(__SIZE) [UIFont italicSystemFontOfSize:__SIZE] //system font with size
#define BFont(__SIZE) [UIFont boldSystemFontOfSize:__SIZE]//system bold font with size
#define Font(__NAME, __SIZE) [UIFont fontWithName:__NAME size:__SIZE] //font with name and size

//user
#define USER_NAME @"user_name"
#define USER_NICKNAME @"nick_name"
#define LAST_LOGINUSER @"eld_lastLoginUser"


typedef enum : NSUInteger {
    ELDMemberVCTypeAll = 1,
    ELDMemberVCTypeAdmin,
    ELDMemberVCTypeAllow,
    ELDMemberVCTypeMute,
    ELDMemberVCTypeBlock,
} ELDMemberVCType;


typedef enum : NSUInteger {
    ELDMemberRoleTypeMember = 1,
    ELDMemberRoleTypeAdmin,
    ELDMemberRoleTypeOwner,
} ELDMemberRoleType;


typedef enum : NSUInteger {
    ELDMemberActionTypeMakeAdmin = 1,
    ELDMemberActionTypeRemoveAdmin,
    ELDMemberActionTypeMakeMute,
    ELDMemberActionTypeRemoveMute,
    ELDMemberActionTypeMakeWhite,
    ELDMemberActionTypeRemoveWhite,
    ELDMemberActionTypeMakeBlock,
    ELDMemberActionTypeRemoveBlock,
} ELDMemberActionType;


#define kMemberActionTypeMakeAdmin @"MemberActionTypeMakeAdmin"
#define kMemberActionTypeRemoveAdmin @"MemberActionTypeRemoveAdmin"
#define kMemberActionTypeMakeMute @"MemberActionTypeMakeMute"
#define kMemberActionTypeRemoveMute @"MemberActionTypeRemoveMute"
#define kMemberActionTypeMakeWhite @"MemberActionTypeMakeWhite"
#define kMemberActionTypeRemoveWhite @"MemberActionTypeRemoveWhite"
#define kMemberActionTypeMakeBlock @"MemberActionTypeMakeBlock"
#define kMemberActionTypeRemoveBlock @"MemberActionTypeRemoveBlock"


#define kGiftNameKey @"kGiftNameKey"
#define kGiftSingleValueKey @"kGiftSingleValueKey"

//send or receive
#define kGiftIdKey @"gift_id"
#define kGiftNumKey @"gift_num"

#define kChatroom_member_join @"chatroom_member_join"

#define kLiveHeaderViewHeight 50.0f

#define kChatViewHeight 320.0

#define kLiveNotifacationViewHeight 30.0

#define kGenderViewWidth 38.0
#define kGenderViewHeight 16.0

#define kCustomTabbarHeight  49.0

#define kMeHeaderImageViewHeight 90.0

#define kUserInfoHeaderImageHeight 72.0


#define kDefultUserImage   ImageWithName(@"default_avatar")


#define kDefaultAvatarURL  @"https://download-sdk.oss-cn-beijing.aliyuncs.com/downloads/AgoraChatDemo_Resource/defaultAvatat%403x.png"



#endif /* EaseLiveDemoDefine_h */
