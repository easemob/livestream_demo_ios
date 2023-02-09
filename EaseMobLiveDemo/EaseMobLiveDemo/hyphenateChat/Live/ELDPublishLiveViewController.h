//
//  ALSLiveViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/25.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDPublishLiveViewController : UIViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room;

@property (nonatomic, copy) void (^finishBroadcastCompletion)(BOOL isFinish);

@end

NS_ASSUME_NONNULL_END
