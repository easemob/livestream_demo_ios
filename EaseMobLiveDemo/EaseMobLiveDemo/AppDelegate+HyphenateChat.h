//
//  AppDelegate+HyphenateChat.h
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (HyphenateChat)

- (void)initHyphenateChatSDK;

- (void)doLogin;

- (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message;

@end
