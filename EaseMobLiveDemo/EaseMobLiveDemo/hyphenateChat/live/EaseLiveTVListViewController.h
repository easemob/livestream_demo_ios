//
//  EaseLiveTVListViewController.h
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"

@interface EaseLiveTVListViewController : EaseBaseViewController

@property (nonatomic, strong) UIBarButtonItem *searchBarItem;
@property (nonatomic, strong) UIBarButtonItem *logoutItem;

- (instancetype)initWithBehavior:(kTabbarItemBehavior)tabBarBehavior video_type:(NSString *)video_type;

@end
