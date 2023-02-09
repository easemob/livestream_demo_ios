//
//  EaseKeyBoardViewController.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseCustomKeyBoardDelegate <NSObject>

- (void)customGiftNum:(NSString *)giftNum;

@end

@interface EaseCustomKeyBoardView : EaseBaseSubView

@property (nonatomic, weak) id<EaseCustomKeyBoardDelegate> customGiftNumDelegate;

@end

NS_ASSUME_NONNULL_END
