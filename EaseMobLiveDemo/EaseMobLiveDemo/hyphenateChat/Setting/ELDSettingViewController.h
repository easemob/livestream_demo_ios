//
//  ACDSettingsViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"
#import "ELDEditUserInfoViewController.h"
#import "ELDAboutViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDSettingViewController : EaseBaseViewController
@property (nonatomic, strong, readonly) EMUserInfo *userInfo;
@property (nonatomic, copy) void (^goAboutBlock)(void);

- (void)updateUIWithUserInfo:(EMUserInfo *)userInfo;

@end

NS_ASSUME_NONNULL_END
