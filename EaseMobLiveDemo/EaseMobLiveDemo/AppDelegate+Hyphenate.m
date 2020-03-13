//
//  AppDelegate+Hyphenate.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "AppDelegate+Hyphenate.h"
#import "EaseDefaultDataHelper.h"

#import <Hyphenate/EMOptions+PrivateDeploy.h>

NSArray<NSString*> *nickNameArray;//本地昵称库

NSMutableDictionary *anchorInfoDic;//直播间主播本应用显示信息库

@implementation AppDelegate (Hyphenate)

- (void)initHyphenateSDK
{
    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
    /*
    [options setEnableDnsConfig:false];
    [options setRestServer:@"a1-hsb.easemob.com"];
    [options setChatPort:6717];
    [options setChatServer:@"39.107.54.56"];*/
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"chatdemoui_dev";
#else
    apnsCertName = @"chatdemoui";
#endif
    options.apnsCertName = apnsCertName;
    options.isAutoAcceptGroupInvitation = NO;
    options.enableConsoleLog = YES;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [self _setupAppDelegateNotifications];
    
    [self _registerRemoteNotification];
    
    [self _initNickNameArray];
    
    anchorInfoDic = [[NSMutableDictionary alloc]initWithCapacity:16];//初始化本地直播间主播昵称库

    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@YES];
    } else {
        if (!EaseDefaultDataHelper.shared.isInitiativeLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"autoRegistAccount" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@NO];
        }
    }
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)_initNickNameArray
{
    nickNameArray = @[@"东方漆",@"孟闾裆",@"曹秆",@"游龙纸",@"熊龛",@"元阊",@"闵茂",@"姚宠",@"印虹",@"尚仕",@"蔚光",@"钦亭",@"京俳",@"牧奖",
                    @"解笋",@"耿丁艮",@"牛菊",@"侯薇",@"习适袁",@"关阡",@"管致",@"聂焚",@"焦岸",@"米而",@"竺莜",@"黎轾",@"邓贰",@"周铎",@"闾丘裳",
                    @"程毗",@"南郭货",@"雍椿",@"康由",@"蔺晶",@"庞浈",@"辛芥",@"邢萧丹",@"谷梁深",@"宾彩",@"吴莛",@"贺扬",@"慕容岽",@"阎邮",@"萧由",
                    @"吕梆",@"高钓",@"西门韩赤",@"元真",@"司司",@"司空晰",@"万麦",@"姜戒",@"武抚",@"苍柳",@"季汶",@"周门",@"公孙褫",@"李乙",@"茹宁",
                    @"楼恕",@"司马穴凇",@"公孙赦",@"那伊",@"冼觊",@"丰核",@"钟创",@"沙迈",@"单寇",@"屋庐丘",@"李李",@"惠婷",@"池学",@"冯貂",@"东乡期",
                    @"毋丘出",@"左颀",@"宰绝",@"谷唐",@"萧格",@"谈草",@"商炅",@"米秀",@"习垂",@"黄崔",@"单遇观",@"茹启",@"田瓮",@"蒋蹯苻",@"呼延汶",
                    @"林犍",@"左丘芍",@"东宅蜇",@"谭七",@"徐仙",@"欧阳使",@"龙偃",@"山鹰",@"况梁",@"江胭",@"展思"];
}

#pragma mark - app delegate notifications
// 监听系统生命周期回调，以便将需要的事件传给SDK
// Listen the life cycle of the system so that it will be passed to the SDK
- (void)_setupAppDelegateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)appDidEnterBackgroundNotif:(NSNotification*)notif
{
    [[EMClient sharedClient] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EMClient sharedClient] applicationWillEnterForeground:notif.object];
}

#pragma mark - register apns
// 注册推送
// regist push
- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    //iOS8 regist APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}

#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
// Get deviceToken to pass SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
// Regist deviceToken failed,not Hyphenate SDK Business,generally have something wrong with your environment configuration or certificate configuration
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
}

@end
