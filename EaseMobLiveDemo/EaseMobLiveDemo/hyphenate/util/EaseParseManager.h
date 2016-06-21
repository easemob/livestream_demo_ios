//
//  EaseParseManager.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/7.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPARSE_HXMODEL @"EasePublishModel"

#define kPARSE_HXMODEL_NAME @"name"
#define kPARSE_HXMODEL_STREAMID @"streamId"
#define kPARSE_HXMODEL_NUMBER @"number"
#define kPARSE_HXMODEL_IMAGE @"headImageName"
#define kPARSE_HXMODEL_CHATROOMID @"chatroomId"
#define kPARSE_HXMODEL_USERID @"userId"

@class PFObject;
@interface EaseParseManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchLiveListInBackgroundWithCompletion:(void (^)(NSArray *liveList, NSError *error))completion;

- (void)publishLiveInBackgroundWithText:(NSString*)text
                               streamId:(NSString*)streamId
                             completion:(void (^)(PFObject *pfuser, NSError *error))completion;

- (void)closePublishLiveInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
