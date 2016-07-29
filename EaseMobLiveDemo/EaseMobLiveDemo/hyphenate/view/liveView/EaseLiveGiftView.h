//
//  EaseLiveGiftView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseBaseSubView.h"

@protocol EaseLiveGiftViewDelegate <NSObject>

- (void)didSelectGiftWithGiftId:(NSString*)giftId;

@end

@interface EaseLiveGiftView : EaseBaseSubView

@property (nonatomic, weak) id<EaseLiveGiftViewDelegate> giftDelegate;

@end
