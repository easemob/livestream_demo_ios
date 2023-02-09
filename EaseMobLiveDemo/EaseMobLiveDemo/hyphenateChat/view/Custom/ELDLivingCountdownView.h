//
//  ELDLivingCountdownView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/7.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ELDLivingCountdownView : UIView
@property (nonatomic, assign) BOOL hasUnit;
@property (nonatomic, copy)void (^CountDownFinishBlock)();
- (void)startCountDown;

@end

NS_ASSUME_NONNULL_END
