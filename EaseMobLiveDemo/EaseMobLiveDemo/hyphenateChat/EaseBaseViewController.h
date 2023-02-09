//
//  EaseBaseViewController.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger{
    kTabbarItemTag_Live,//直播大厅
    kTabbarItemTag_Broadcast,//开播大厅
    kTabbarItemTag_Settings //设置
}kTabbarItemBehavior;

@interface EaseBaseViewController : UIViewController
@property (nonatomic, strong) UILabel *prompt;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIBarButtonItem *searchBarItem;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

- (void)backAction;
- (void)searchAction;
- (void)tapAction;

@end
