//
//  NSDictionary+SafeValue.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/3/8.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "NSDictionary+SafeValue.h"

@implementation NSDictionary (SafeValue)

- (NSString *)safeStringValueForKey:(NSString *)key
{
    NSString *safeString = @"";
    id value = [self objectForKey:key];
    
    do {
        if (value == [NSNull null] || value == nil) {
            break;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            safeString = (NSString *)value;
            break;
        }
        
        if ([value isKindOfClass:[NSNumber class]]) {
            safeString = [value stringValue];
            break;
        }
        
        safeString = [value stringValue];
    } while (0);
    
    return safeString;
}

- (NSInteger)safeIntegerValueForKey:(NSString *)key
{
    NSInteger safeInteger = 0;
    id value = [self objectForKey:key];
    
    do {
        if (value == [NSNull null] || value == nil) {
            break;
        }
        
        if ([value isKindOfClass:[NSObject class]]) {
            safeInteger = [value integerValue];
            break;
        }
    } while (0);
    
    return safeInteger;
}

- (id)safeObjectForKey:(NSString *)key
{
    id value = [self objectForKey:key];
    if (value == [NSNull null]) {
        value = nil;
    }
    
    return value;
}


@end
