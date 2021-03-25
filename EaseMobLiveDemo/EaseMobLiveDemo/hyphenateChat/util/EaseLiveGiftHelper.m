//
//  EaseLiveGiftHelper.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/18.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseLiveGiftHelper.h"

@interface EaseLiveGiftHelper()

@property (nonatomic, strong) NSArray *giftNameArray;

@end

@implementation EaseLiveGiftHelper

static dispatch_once_t onceToken;
static EaseLiveGiftHelper *helper_;

- (NSArray *)giftArray {
    if(!_giftArray){
        NSMutableArray *mutableGiftArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<8; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(i+i)] forKey:helper_.giftNameArray[i]];
            [mutableGiftArray addObject:dict];
        }
        _giftArray = [mutableGiftArray copy];
    }
    return _giftArray;
}

+ (EaseLiveGiftHelper *)sharedInstance {
    dispatch_once(&onceToken, ^{
        helper_ = [[EaseLiveGiftHelper alloc] init];
        helper_.giftNameArray = @[@"gift.rose",@"gift.wishs_come_true",@"gift.balloons",@"gift.cake",@"gift.box",@"gift.bouquet",@"gift.dog",@"gift.rings"];
    });
    return helper_;
}

- (void)destoryInstance {
    onceToken = 0;
    helper_ = nil;
}

@end
