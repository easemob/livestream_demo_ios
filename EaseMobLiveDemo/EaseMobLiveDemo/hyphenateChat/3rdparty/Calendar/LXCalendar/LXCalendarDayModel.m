
//
//  LXCalendarDayModel.m
//  LXCalendar
//
//  Created by chenergou on 2017/11/3.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXCalendarDayModel.h"

@implementation LXCalendarDayModel

- (BOOL)isSameDayWithOtherModel:(LXCalendarDayModel *)otherModel {
    if (self.day != otherModel.day) {
        return NO;
    }
    
    if (self.month != otherModel.month) {
        return NO;
    }
    
    if (self.day != otherModel.day) {
        return NO;
    }

    return YES;
}


@end
