//
//  EaseDefaultDataHelper.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/26.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseDefaultDataHelper.h"

static NSString *eDefaultData_Nickname = @"nickName";
static NSString *eDefaultData_CurrentRoomId = @"currentRoomId";
static NSString *eDefaultData_isInitiativeLogin = @"isInitiativeLogin";

static EaseDefaultDataHelper *shared = nil;

@implementation EaseDefaultDataHelper

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [EaseDefaultDataHelper getDefaultDataFromLocal];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaultNickname = @"";
        self.currentRoomId = @"";
        self.isInitiativeLogin = NO;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    extern NSArray<NSString*> *nickNameArray;
    if (self = [super init]) {
        NSString *defaultNickname = [aDecoder decodeObjectForKey:eDefaultData_Nickname];
        if ([defaultNickname length] != 0) {
            self.defaultNickname = defaultNickname;
        } else {
            int random = (arc4random() % 100);
            self.defaultNickname = nickNameArray[random];
        }
        self.currentRoomId = [aDecoder decodeObjectForKey:eDefaultData_CurrentRoomId];
        self.isInitiativeLogin = [aDecoder decodeBoolForKey:eDefaultData_isInitiativeLogin];
        [self archive];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.defaultNickname forKey:eDefaultData_Nickname];
    [aCoder encodeObject:self.currentRoomId forKey:eDefaultData_CurrentRoomId];
    [aCoder encodeBool:self.isInitiativeLogin forKey:eDefaultData_isInitiativeLogin];
}

#pragma mark - Private

+ (EaseDefaultDataHelper *)getDefaultDataFromLocal
{
    //解档
    NSString *fileName = [NSString stringWithFormat:@"emlivedemo_defaultdata_%@.data", [EMClient sharedClient].currentUsername];
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    EaseDefaultDataHelper *defaultData = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    if (!defaultData) {
        defaultData = [[EaseDefaultDataHelper alloc]init];
        [defaultData archive];
    }
    
    return defaultData;
}

//归档
- (void)archive
{
    NSString *fileName = [NSString stringWithFormat:@"emlivedemo_defaultdata_%@.data", [EMClient sharedClient].currentUsername];
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:file];
}

@end
