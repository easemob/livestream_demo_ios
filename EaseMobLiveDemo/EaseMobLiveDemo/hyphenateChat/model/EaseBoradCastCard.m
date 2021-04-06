//
//  EaseBoradCastCard.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2021/3/23.
//  Copyright © 2021 zmw. All rights reserved.
//

#import "EaseBoradCastCard.h"


@implementation EaseBoradCastCard

- (instancetype)initWithInfo:(UIImage *)cardBackImg title:(NSString *)title desc:(NSString *)desc type:(NSString *)broadCastType
{
    self = [super init];
    if (self) {
        _cardBackImg = cardBackImg;
        _title = title;
        _desc = desc;
        _broadCastType = broadCastType;
    }
    
    return self;
}

@end
