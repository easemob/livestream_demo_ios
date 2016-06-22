//
//  AppDelegate+Parse.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/7.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Parse)

- (void)parseApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)initParse;

- (void)clearParse;

@end
