//
//  ALSLiveListViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/28.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDLiveListViewController : EaseBaseViewController
@property (nonatomic, strong, readonly) NSMutableArray *dataArray;
@property (nonatomic, copy) void (^liveRoomSelectedBlock)(EaseLiveRoom *room);
@property (nonatomic, copy) void (^selfLiveRoomSelectedBlock)(EaseLiveRoom *room);


- (instancetype)initWithBehavior:(kTabbarItemBehavior)tabBarBehavior video_type:(NSString *)video_type;

@end

NS_ASSUME_NONNULL_END
