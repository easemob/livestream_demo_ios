//
//  ELDGifCountDownView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/29.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDGiftCountDownView : UIView
@property (nonatomic, copy)void (^countDownFinishBlock)();

- (void)startCountDown;

@end

NS_ASSUME_NONNULL_END
