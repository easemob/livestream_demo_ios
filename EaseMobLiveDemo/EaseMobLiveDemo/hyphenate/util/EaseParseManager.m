//
//  EaseParseManager.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/7.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseParseManager.h"

#import "EasePublishModel.h"
#import <Parse/Parse.h>

static EaseParseManager *sharedInstance = nil;

@interface EaseParseManager ()

@end

@implementation EaseParseManager

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)fetchLiveListInBackgroundWithCompletion:(void (^)(NSArray *liveList, NSError *))completion
{
    PFQuery *query = [PFQuery queryWithClassName:kPARSE_HXMODEL];
    [[query orderByDescending:@"updatedAt"] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *liveList = [NSMutableArray array];
            for (id model in objects) {
                if ([model isKindOfClass:[PFObject class]]) {
                    PFObject *pfuser = (PFObject*)model;
                    EasePublishModel *model = [[EasePublishModel alloc] init];
                    model.name = pfuser[kPARSE_HXMODEL_NAME];
                    model.streamId = pfuser[kPARSE_HXMODEL_STREAMID];
                    model.headImageName = pfuser[kPARSE_HXMODEL_IMAGE];
                    model.number = pfuser[kPARSE_HXMODEL_NUMBER];
                    model.userId = pfuser[kPARSE_HXMODEL_USERID];
                    model.chatroomId = pfuser[kPARSE_HXMODEL_CHATROOMID];
                    [liveList addObject:model];
                }
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(liveList, nil);
                });
            }
        } else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
        }
    }];
}

- (void)publishLiveInBackgroundWithText:(NSString*)text
                               streamId:(NSString*)streamId
                             completion:(void (^)(PFObject *pfuser, NSError *error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:kPARSE_HXMODEL];
    [query whereKey:@"userId" equalTo:[EMClient sharedClient].currentUsername];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 0) {
                id model = [objects objectAtIndex:0];
                if ([model isKindOfClass:[PFObject class]]) {
                    PFObject *pfuser = (PFObject*)model;
                    pfuser[kPARSE_HXMODEL_NAME] = text;
                    pfuser[kPARSE_HXMODEL_USERID] = [EMClient sharedClient].currentUsername;
                    pfuser[kPARSE_HXMODEL_IMAGE] = @"1";
                    pfuser[kPARSE_HXMODEL_NUMBER] = @"1人";
                    pfuser[kPARSE_HXMODEL_STREAMID] = streamId;
                    pfuser[kPARSE_HXMODEL_CHATROOMID] = kDefaultChatroomId;
                    [pfuser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(pfuser, error);
                            });
                        }

                    }];
                }
            } else {
                PFObject *pfuser = [PFObject objectWithClassName:kPARSE_HXMODEL];
                pfuser[kPARSE_HXMODEL_NAME] = text;
                pfuser[kPARSE_HXMODEL_USERID] = [EMClient sharedClient].currentUsername;
                pfuser[kPARSE_HXMODEL_IMAGE] = @"1";
                pfuser[kPARSE_HXMODEL_NUMBER] = @"1人";
                pfuser[kPARSE_HXMODEL_STREAMID] = streamId;
                pfuser[kPARSE_HXMODEL_CHATROOMID] = kDefaultChatroomId;
                [pfuser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(pfuser, error);
                        });
                    }
                }];
            }
        } else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
        }
    }];
}

- (void)closePublishLiveInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:kPARSE_HXMODEL];
    [query whereKey:@"userId" equalTo:[EMClient sharedClient].currentUsername];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 0) {
                for (id model in objects) {
                    if ([model isKindOfClass:[PFObject class]]) {
                        PFObject *pfuser = (PFObject*)model;
                        [pfuser deleteInBackground];
                    }
                }
            }
        } else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(NO, error);
                });
            }
        }
    }];
}

@end
