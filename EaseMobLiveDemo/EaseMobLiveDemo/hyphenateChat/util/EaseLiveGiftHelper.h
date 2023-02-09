//
//  EaseLiveGiftHelper.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/18.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseLiveGiftHelper : NSObject

@property (nonatomic, strong) NSArray *giftArray;

- (void)destoryInstance;//销毁单例
+ (EaseLiveGiftHelper *)sharedInstance;
@end

NS_ASSUME_NONNULL_END
