//
//  EaseLiveTVListViewController.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger{
    kTabbarItemTag_Live,
    kTabbarItemTag_Broadcast,
    kTabbarItemTag_Settings
}kTabbarItemBehavior;

@interface EaseLiveTVListViewController : UIViewController

@property (nonatomic, strong) UIBarButtonItem *searchBarItem;
@property (nonatomic, strong) UIBarButtonItem *logoutItem;

- (instancetype)initWithBehavior:(kTabbarItemBehavior)tabBarBehavior;

@end
