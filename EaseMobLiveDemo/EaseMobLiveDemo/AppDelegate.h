//
//  AppDelegate.h
//
//  Created by yisanmao on 15/10/21.
//  Copyright (c) 2015年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,EMClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) EaseMainViewController *mainVC;

@end

