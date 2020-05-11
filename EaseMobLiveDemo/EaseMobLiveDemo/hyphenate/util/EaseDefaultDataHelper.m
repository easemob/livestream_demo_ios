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
static NSString *eDefaultData_praiseStatisticst = @"praiseStatisticst";
static NSString *eDefaultData_giftStatistics = @"giftStatistics";
static NSString *eDefaultData_rewardCount = @"rewardCount";
static NSString *eDefaultData_giftNumbers = @"giftNumbers";
static NSString *eDefaultData_totalGifts = @"totalGifts";

static EaseDefaultDataHelper *shared = nil;

extern NSArray<NSString*> *nickNameArray;
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
        int random = (arc4random() % 100);
        self.defaultNickname = nickNameArray[random];
        self.currentRoomId = @"";
        self.isInitiativeLogin = NO;
        self.praiseStatisticstCount = @"";
        self.giftStatisticsCount = [self emptyGiftStatisticsCount];
        self.rewardCount = [[NSMutableArray alloc]init];
        self.giftNumbers = @"";
        self.totalGifts = @"";
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
        self.praiseStatisticstCount = [aDecoder decodeObjectForKey:eDefaultData_praiseStatisticst];
        NSMutableDictionary *tempDic = [aDecoder decodeObjectForKey:eDefaultData_giftStatistics];
        if ([tempDic allKeys].count == 0) {
            self.giftStatisticsCount = [self emptyGiftStatisticsCount];
        } else {
            self.giftStatisticsCount = tempDic;
        }
        NSMutableArray *tempArray = [aDecoder decodeObjectForKey:eDefaultData_rewardCount];
        if (tempArray == nil) {
            self.rewardCount = [[NSMutableArray alloc]init];
        } else {
            self.rewardCount = tempArray;
        }
        self.giftNumbers = [aDecoder decodeObjectForKey:eDefaultData_giftNumbers];
        self.totalGifts = [aDecoder decodeObjectForKey:eDefaultData_totalGifts];
        [self archive];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.defaultNickname forKey:eDefaultData_Nickname];
    [aCoder encodeObject:self.currentRoomId forKey:eDefaultData_CurrentRoomId];
    [aCoder encodeBool:self.isInitiativeLogin forKey:eDefaultData_isInitiativeLogin];
    [aCoder encodeObject:self.praiseStatisticstCount forKey:eDefaultData_praiseStatisticst];
    [aCoder encodeObject:self.giftStatisticsCount forKey:eDefaultData_giftStatistics];
    [aCoder encodeObject:self.rewardCount forKey:eDefaultData_rewardCount];
    [aCoder encodeObject:self.giftNumbers forKey:eDefaultData_giftNumbers];
    [aCoder encodeObject:self.totalGifts forKey:eDefaultData_totalGifts];
}

#pragma mark - Private

- (NSMutableDictionary*)emptyGiftStatisticsCount
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    for (int i=1; i<9; i++) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
        [dic setObject:tempDic forKey:[NSString stringWithFormat:@"gift_%d",i]];
    }
    return dic;
}

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
