//
//  EaseSearchDisplayController.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/22.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"

@interface EaseSearchDisplayController : UICollectionViewController

@property (strong, nonatomic) NSMutableArray *resultsSource;
@property (strong, nonatomic) NSMutableArray *searchSource;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout liveBehavior:(kTabbarItemBehavior)liveBehavior;

@end
