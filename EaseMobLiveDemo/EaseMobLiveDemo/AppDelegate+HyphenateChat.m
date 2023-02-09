//
//  AppDelegate+HyphenateChat.m
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "AppDelegate+HyphenateChat.h"
#import "EaseDefaultDataHelper.h"

#import "Reachability.h"
#import <HyphenateChat/EMOptions+PrivateDeploy.h>



@implementation AppDelegate (HyphenateChat)

- (void)initHyphenateChatSDK
{
    EMOptions *options = [EMOptions optionsWithAppkey:Appkey];
    
//    [options setEnableDnsConfig:NO];
//    [options setRestServer:@"a1.easemob.com"];
//    [options setChatPort:6717];
//    [options setChatServer:@"106.75.100.247"];
    options.enableConsoleLog = YES;
    
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [self _setupAppDelegateNotifications];
    
    
    BOOL isAutoLogin = [EMClient sharedClient].currentUsername.length > 0;
    if (isAutoLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@NO];
    }
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
}


- (BOOL)conecteNetwork
{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}


//- (void)doLogin {
//
//    if (![self conecteNetwork]) {
//        [self showAlertControllerWithTitle:@"" message:@"Network disconnected."];
//        return;
//    }
//
//    void (^finishBlock) (NSString *aName, NSString *nickName, EMError *aError) = ^(NSString *aName, NSString *nickName, EMError *aError) {
//        if (!aError) {
//            if (nickName) {
//                [EMClient.sharedClient.userInfoManager updateOwnUserInfo:nickName withType:EMUserInfoTypeNickName completion:^(EMUserInfo *aUserInfo, EMError *aError) {
//                    if (!aError) {
//
//                        [[NSNotificationCenter defaultCenter] postNotificationName:ELDUSERINFO_UPDATE  object:aUserInfo userInfo:nil];
//                    }
//                }];
//            }
//
//            [self saveLoginUserInfoWithUserName:aName nickName:nickName];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:@YES userInfo:@{@"userName":aName,@"nickName":!nickName ? @"" : nickName}];
//            });
//            return ;
//        }
//
//        NSString *errorDes = NSLocalizedString(@"login.failure", @"login failure");
//        switch (aError.code) {
//            case EMErrorServerNotReachable:
//                errorDes = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
//                break;
//            case EMErrorNetworkUnavailable:
//                errorDes = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
//                break;
//            case EMErrorServerTimeout:
//                errorDes = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
//                break;
//            case EMErrorUserAlreadyExist:
//                errorDes = NSLocalizedString(@"login.taken", @"Username taken");
//                break;
//            default:
//                errorDes = NSLocalizedString(@"login.failure", @"login failure");
//                break;
//        }
//
//        [self showAlertControllerWithTitle:@"" message:errorDes];
//    };
//
//
//    NSString *userName = @"";
//    NSString *nickName = @"";
//
//    NSDictionary *loginDic = [self getLoginUserInfo];
//    if (loginDic.count > 0) {
//        userName = loginDic[USER_NAME];
//        nickName = loginDic[USER_NICKNAME];
//    }else {
//        userName = @"eld_002";
//        nickName = userName;
//    }
//
//
//    //unify token login
//    [[EaseHttpManager sharedInstance] loginToApperServer:userName nickName:nickName completion:^(NSInteger statusCode, NSString * _Nonnull response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *alertStr = nil;
//            if (response && response.length > 0 && statusCode) {
//                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//                NSString *token = [responsedict objectForKey:@"accessToken"];
//                NSString *loginName = [responsedict objectForKey:@"chatUserName"];
//                NSString *nickName = [responsedict objectForKey:@"chatUserNickname"];
//                if (token && token.length > 0) {
//                    [[EMClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:^(NSString *aUsername, EMError *aError) {
//                        finishBlock(aUsername, nickName, aError);
//                    }];
//                    return;
//                } else {
//                    alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
//                }
//            } else {
//                alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
//            }
//
//
//            [self showAlertControllerWithTitle:@"" message:alertStr];
//
//        });
//    }];
//
//}



- (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alertControler addAction:conform];
    [self.window.rootViewController presentViewController:alertControler animated:YES completion:nil];

}

- (NSDictionary *)getLoginUserInfo {
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [shareDefault objectForKey:LAST_LOGINUSER];
    return dic;
}

- (void)saveLoginUserInfoWithUserName:(NSString *)userName nickName:(NSString *)nickName {
    NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = @{USER_NAME:userName,USER_NICKNAME:nickName};
    [shareDefault setObject:dic forKey:LAST_LOGINUSER];
    [shareDefault synchronize];
}



#pragma mark - app delegate notifications
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

@end
