//
//  ELDPreLivingViewController.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class EaseLiveRoom;
@interface ELDPreLivingViewController : UIViewController
@property (nonatomic, copy) void (^closeBlock)(void);
@property (nonatomic, copy) void (^startLivingBlock)(EaseLiveRoom *liveRoom);

@end

NS_ASSUME_NONNULL_END
