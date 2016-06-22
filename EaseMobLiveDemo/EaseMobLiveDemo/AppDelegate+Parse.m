//
//  AppDelegate+Parse.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/7.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "AppDelegate+Parse.h"
#import <Parse/Parse.h>
#import "EaseParseManager.h"

@implementation AppDelegate (Parse)

- (void)parseApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"43wo1Ok7aWLJqEOrG67hjdFPCGC3KVyP6Umq32Q1"
                  clientKey:@"jEfd2kDgqOyNMeazv0wY0Evwefz549dAv4EKNX9s"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    // setup ACL
    PFACL *defaultACL = [PFACL ACL];
    
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
//    [[EaseParseManager sharedInstance] closePublishLiveInBackgroundWithCompletion:NULL];
}

- (void)initParse
{

}

- (void)clearParse
{

}


@end
