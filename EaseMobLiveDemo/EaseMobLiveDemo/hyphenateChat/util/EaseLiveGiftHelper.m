//
//  EaseLiveGiftHelper.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/18.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseLiveGiftHelper.h"
#import "ELDGiftModel.h"

@interface EaseLiveGiftHelper()

@property (nonatomic, strong) NSArray *giftNameArray;
@property (nonatomic, strong) NSArray *giftValueArray;
@property (nonatomic, strong) NSArray *giftIdArray;

@end

@implementation EaseLiveGiftHelper

static dispatch_once_t onceToken;
static EaseLiveGiftHelper *giftHelperInstance;
+ (EaseLiveGiftHelper *)sharedInstance {
    dispatch_once(&onceToken, ^{
        giftHelperInstance = [[EaseLiveGiftHelper alloc] init];
//        helper_.giftNameArray = @[@"gift.rose",@"gift.wishs_come_true",@"gift.balloons",@"gift.cake",@"gift.box",@"gift.bouquet",@"gift.dog",@"gift.rings"];
    });
    return giftHelperInstance;
}

- (void)destoryInstance {
    onceToken = 0;
    giftHelperInstance = nil;
}

- (NSArray *)giftNameArray {
    if (_giftNameArray == nil) {
        _giftNameArray = @[@"gift.PinkHeart",@"gift.PlasticFlower",@"gift.ThePushBox",@"gift.BigAce",@"gift.Star",@"gift.Lollipop",@"gift.Diamond",@"gift.Crown"];
    }
    return _giftNameArray;
}

- (NSArray *)giftValueArray {
    if (_giftValueArray == nil) {
        _giftValueArray = @[@(1),@(5),@(10),@(20),@(50),@(100),@(500),@(1000)];
    }
    return _giftValueArray;
}

- (NSArray *)giftIdArray {
    if (_giftIdArray == nil) {
        _giftIdArray = [NSArray array];

        NSMutableArray *idArray = [[NSMutableArray alloc]init];
        for (NSInteger i = 1; i < 9; ++i) {
            NSString *giftId = [NSString stringWithFormat:@"gift_%@",@(i)];
            [idArray addObject:giftId];
        }
        _giftIdArray = [idArray copy];
    }
    return _giftIdArray;
}
- (NSArray *)giftArray {
    if( _giftArray == nil){
        NSMutableArray *mutableGiftArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<8; i++) {
            
            NSString *giftName = giftHelperInstance.giftNameArray[i];
            NSNumber *giftValue = giftHelperInstance.giftValueArray[i];
            NSString *giftId = giftHelperInstance.giftIdArray[i];

            ELDGiftModel *giftModel = [[ELDGiftModel alloc] initWithGiftname:giftName giftValue:[giftValue integerValue] giftId:giftId];
            [mutableGiftArray addObject:giftModel];
        }
        _giftArray = [mutableGiftArray copy];
    }
    return _giftArray;
}


@end
