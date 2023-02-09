//
//  ELDEditUserInfoViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDEditUserInfoViewController : EaseBaseViewController
@property (nonatomic, strong) EMUserInfo *userInfo;
@property (nonatomic, copy) void(^updateUserInfoBlock)(EMUserInfo *userInfo);

@end

NS_ASSUME_NONNULL_END
