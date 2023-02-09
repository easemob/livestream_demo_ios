//
//  EaseChatViewCustomOption.m
//  chat-uikit
//
//  Created by liu001 on 2022/5/18.
//

#import "EaseChatViewCustomOption.h"
#import "EaseHeaders.h"
#import "EaseKitDefine.h"

@implementation EaseChatViewCustomOption

static EaseChatViewCustomOption *instance = nil;
+ (EaseChatViewCustomOption *)customOption {
   static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[EaseChatViewCustomOption alloc]init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.displaySenderAvatar = YES;
        self.displaySenderNickname = YES;
        self.avatarStyle = Circular;
        self.avatarCornerRadius = 0;
        self.sendTextButtonBottomMargin = 12.0;
        self.cellBgColor = EaseKitBlackAlphaColor;

//        self.tableViewBgColor = UIColor.redColor;
//        self.tableViewRightMargin = 0;
//        self.sendTextButtonBottomMargin = 30.0;
//        self.sendTextButtonRightMargin = 0;
//
//        self.displaySenderAvatar = NO;
//        self.displaySenderNickname = NO;
//        self.avatarStyle = Rectangular;
//        self.avatarCornerRadius = 6.0;
//
//        self.cellBgColor = UIColor.greenColor;
//        self.messageLabelColor = UIColor.yellowColor;
//        self.messageLabelSize = 14.0;
//        self.nameLabelColor = UIColor.purpleColor;
//        self.nameLabelFontSize = 10.0;
        
    }
    return self;
}


@end
