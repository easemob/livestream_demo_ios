//
//  EaseKitDefine.h
//  Pods
//
//  Created by liu001 on 2022/5/12.
//

#ifndef EaseKitDefine_h
#define EaseKitDefine_h

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})


#define EaseKitVIEWTOPMARGIN (kIsBangsScreen ? 34.f : 0.f)

#define EaseKitScreenHeight [[UIScreen mainScreen] bounds].size.height
#define EaseKitScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define EaseKitIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define EaseKitIs_iPhoneX EaseKitScreenWidth >=375.0f && EaseKitScreenHeight >=812.0f&& EaseKitIs_iphone
 
#define EaseKitStatusBarHeight (CGFloat)(EaseKitIs_iPhoneX?(44.0):(20.0))
#define EaseKitNavBarHeight (44)

#define EaseKitNavBarAndStatusBarHeight (CGFloat)(EaseKitIs_iPhoneX?(88.0):(64.0))

#define EaseKitTabBarHeight (CGFloat)(EaseKitIs_iPhoneX?(49.0 + 34.0):(49.0))

#define EaseKitTopBarSafeHeight (CGFloat)(EaseKitIs_iPhoneX?(44.0):(0))

#define EaseKitBottomSafeHeight (CGFloat)(EaseKitIs_iPhoneX?(34.0):(0))

#define EaseKitTopBarDifHeight (CGFloat)(EaseKitIs_iPhoneX?(24.0):(0))

#define EaseKitNavAndTabHeight (EaseKitNavBarAndStatusBarHeight + EaseKitTabBarHeight)

#define EaseKitScreenHeight [[UIScreen mainScreen] bounds].size.height
#define EaseKitScreenWidth  [[UIScreen mainScreen] bounds].size.width


#define EaseKitRGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// rgb颜色转换（16进制->10进制）
#define EaseKitCOLOR_HEXA(__RGB,__ALPHA) [UIColor colorWithRed:((float)((__RGB & 0xFF0000) >> 16))/255.0 green:((float)((__RGB & 0xFF00) >> 8))/255.0 blue:((float)(__RGB & 0xFF))/255.0 alpha:__ALPHA]

#define EaseKitCOLOR_HEX(__RGB) EaseKitCOLOR_HEXA(__RGB,1.0f)

//weak & strong self
#define EaseKit_WS                  __weak __typeof(&*self)weakSelf = self;
#define EaseKit_SS(WKSELF)          __strong __typeof(&*self)strongSelf = WKSELF;

#define EaseKit_ONE_PX  (1.0f / [UIScreen mainScreen].scale)

#define EaseKitImageWithName(imageName) [UIImage imageNamed:imageName]

#define EaseKitPadding 10.0f


//fonts
#define EaseKitNFont(__SIZE) [UIFont systemFontOfSize:__SIZE] //system font with size
#define EaseKitIFont(__SIZE) [UIFont italicSystemFontOfSize:__SIZE] //system font with size
#define EaseKitBFont(__SIZE) [UIFont boldSystemFontOfSize:__SIZE]//system bold font with size
#define EaseKitFont(__NAME, __SIZE) [UIFont fontWithName:__NAME size:__SIZE] //font with name and size

#define EaseKitTextLabelGrayColor  EaseKitCOLOR_HEX(0x999999)
#define EaseKitDefaultSystemLightGrayColor EaseKitRGBACOLOR(197, 197, 197, 1)
#define EaseKitDefaultSystemTextGrayColor EaseKitRGBACOLOR(197, 197, 197, 1)
#define EaseKitDefaultSystemTextColor EaseKitRGBACOLOR(38, 38, 38, 1)
#define EaseKitDefaultSystemBgColor EaseKitRGBACOLOR(51, 51, 51, 1)
#define EaseKitDefaultSystemLightGrayColor EaseKitRGBACOLOR(197, 197, 197, 1)
#define EaseKitDefaultLoginButtonColor EaseKitRGBACOLOR(25, 163, 255, 1)

#define  EaseKitBlackAlphaColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]

#define  EaseKitWhiteAlphaColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.74]

#endif /* EaseKitDefine_h */
