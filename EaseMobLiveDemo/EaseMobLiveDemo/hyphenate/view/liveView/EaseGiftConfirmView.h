//
//  EaseGiftConfirmView.h
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseSubView.h"
#import "EaseGiftCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseGiftConfirmView : EaseBaseSubView

@property (nonatomic, copy) BOOL (^doneCompletion)(BOOL aConfirm);

- (instancetype)initWithGiftInfo:(EaseGiftCell *)giftCell giftNum:(long)num titleText:(NSString *)titleText;

@end

NS_ASSUME_NONNULL_END
