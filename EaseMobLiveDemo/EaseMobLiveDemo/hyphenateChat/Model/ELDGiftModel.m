//
//  ELDGiftModel.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/13.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDGiftModel.h"
@interface ELDGiftModel ()

@end

@implementation ELDGiftModel
- (instancetype)initWithGiftname:(NSString *)giftname
                       giftValue:(NSInteger)giftValue
                          giftId:(NSString *)giftId {
    if (self) {
        self.giftname = giftname;
        self.giftValue = giftValue;
        self.giftId = giftId;
    }
    return self;
}


@end
