//
//  EMUserInfo+Time.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/5/27.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "EMUserInfo+expireTime.h"
#import <objc/runtime.h>

static char *expireTimeKey = "expireTimeKey";

@implementation EMUserInfo (expireTime)

- (NSInteger)expireTime {
    return  [objc_getAssociatedObject(self, expireTimeKey) integerValue];
}

- (void)setExpireTime:(NSInteger)expireTime {
    objc_setAssociatedObject(self, expireTimeKey, @(expireTime), OBJC_ASSOCIATION_ASSIGN);
}


@end
