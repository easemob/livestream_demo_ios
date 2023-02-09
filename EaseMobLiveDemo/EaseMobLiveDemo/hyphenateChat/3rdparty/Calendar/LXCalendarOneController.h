//
//  LXCalendarOneController.h
//  LXCalendar
//
//  Created by chenergou on 2017/11/3.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"

@interface LXCalendarOneController : EaseBaseViewController

@property (nonatomic, copy)void (^selectedBlock)(NSString *dateString);

@end
