//
//  EasePublishViewController.h
//
//  Created by EaseMob on 16/6/3.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EaseLiveRoom;
@interface EasePublishViewController : UIViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room;

@property (nonatomic, copy) void (^finishBroadcastCompletion)(BOOL isFinish);

@end
