//
//  ELDBaseTitleBtnNavView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/17.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDBaseTitleBtnNavView : UIView

@property (nonatomic, copy) void (^rightButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
