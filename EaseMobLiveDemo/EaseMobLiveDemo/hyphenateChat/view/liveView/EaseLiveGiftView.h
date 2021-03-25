//
//  EaseLiveGiftView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseBaseSubView.h"
#import "EaseGiftCell.h"
#import "EaseCustomKeyBoardView.h"

@protocol EaseLiveGiftViewDelegate;
@interface EaseLiveGiftView : EaseBaseSubView<EaseCustomKeyBoardDelegate>

@property (nonatomic, weak) id<EaseLiveGiftViewDelegate> giftDelegate;

@end

@protocol EaseLiveGiftViewDelegate <NSObject>

- (void)didConfirmGift:(EaseGiftCell *)giftCell giftNum:(long)num;

- (void)giftNumCustom:(EaseLiveGiftView *)liveGiftView;

@end
