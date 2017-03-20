//
//  NSDictionary+SafeValue.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SafeValue)

- (NSString *)safeStringValueForKey:(NSString *)key;

- (NSInteger)safeIntegerValueForKey:(NSString *)key;

- (id)safeObjectForKey:(NSString *)key;

@end
