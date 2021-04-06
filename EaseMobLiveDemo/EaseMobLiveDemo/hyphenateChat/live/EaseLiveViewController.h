//
//  EaseLiveViewController.h
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EaseLiveRoom;
@interface EaseLiveViewController : UIViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room;

@property (nonatomic, copy) void (^chatroomUpdateCompletion)(BOOL isUpdate, EaseLiveRoom *liveRoom);

@end
