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
#import "JPGiftCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseGiftConfirmView : EaseBaseSubView

@property (nonatomic, copy) void (^doneCompletion)(BOOL aConfirm,JPGiftCellModel *giftModel);

- (instancetype)initWithGiftInfo:(EaseGiftCell *)giftCell giftNum:(long)num titleText:(NSString *)titleText;

@end

NS_ASSUME_NONNULL_END
