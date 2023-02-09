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

@class EaseLiveGiftView;
@protocol EaseLiveGiftViewDelegate <NSObject>
- (void)didConfirmGiftModel:(ELDGiftModel *)giftModel giftNum:(long)num;
- (void)giftNumCustom:(EaseLiveGiftView *)liveGiftView;
@end

@interface EaseLiveGiftView : EaseBaseSubView<EaseCustomKeyBoardDelegate>

@property (nonatomic, weak) id<EaseLiveGiftViewDelegate> giftDelegate;

- (void)resetWitGiftId:(NSString *)giftId;

@end


