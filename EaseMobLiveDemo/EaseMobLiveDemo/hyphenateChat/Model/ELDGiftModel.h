//
//  ELDGiftModel.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/13.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDGiftModel : NSObject
@property (nonatomic, strong) NSString *giftId;
@property (nonatomic, strong) NSString *giftname;
@property (nonatomic, assign) NSInteger giftValue;
@property (nonatomic, assign) BOOL selected;
//display countdown to previous too frequent send gift
@property (nonatomic, assign) BOOL displayCountdown;

- (instancetype)initWithGiftname:(NSString *)giftname
                       giftValue:(NSInteger)giftValue
                          giftId:(NSString *)giftId;

@end

NS_ASSUME_NONNULL_END
