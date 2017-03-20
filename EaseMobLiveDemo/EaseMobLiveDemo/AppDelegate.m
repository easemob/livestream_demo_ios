//
//  AppDelegate.m
//  UCloudMediaRecorderDemo
//
//  Created by yisanmao on 15/10/21.
//  Copyright (c) 2015年 zmw. All rights reserved.
//

#import "AppDelegate.h"

#import "AppDelegate+Hyphenate.h"
#import "EaseLoginViewController.h"
#import "EaseMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:@"loginStateChange"
                                               object:nil];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:kDefaultSystemBgColor];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(255, 255, 255, 1), NSForegroundColorAttributeName, [UIFont systemFontOfSize:20.f weight:0], NSFontAttributeName, nil]];
    }
    
    //初始化环信sdk
    [self initHyphenateSDK];
    return YES;
}

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {//登录成功加载主窗口控制器
        EaseMainViewController *main = [[EaseMainViewController alloc] init];
        UINavigationController *navigationController = nil;
        navigationController = [[UINavigationController alloc] initWithRootViewController:main];
        _mainVC = main;
        self.window.rootViewController = navigationController;
    }
    else{//登录失败加载登录页面控制器
        _mainVC = nil;
        UINavigationController *navigationController = nil;
        EaseLoginViewController *login = [[EaseLoginViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:login];
        self.window.rootViewController = navigationController;
    }
    [self.window makeKeyAndVisible];
}

#pragma makr - EMClientDelegate
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState
{

}

- (void)didAutoLoginWithError:(EMError *)aError
{
    if (aError) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"自动登录失败，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)didLoginFromOtherDevice
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的账号已在其他地方登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@NO];
}

- (void)didRemovedFromServer
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的账号已被从服务器端移除" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@NO];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    //在此时设置解析notification，并展示提示视图
//    NSLog(@"%@", notification.alertBody);
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    /**
     *  这里移动要注意，条件判断成功的是在播放器播放过程中返回的
     下面的是播放器没有弹出来的所支持的设备方向
     */
//    if (self.vc.playerManager)
//    {
//        return self.vc.playerManager.supportInterOrtation;
//    }
//    else
//    {
//        return UIInterfaceOrientationMaskPortrait;
//    }
    return UIInterfaceOrientationMaskPortrait;
}
@end
