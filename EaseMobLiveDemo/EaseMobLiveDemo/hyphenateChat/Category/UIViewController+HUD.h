//
//  UIViewController+UIViewController_HUD.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/4.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (HUD)
- (void)showHudInView:(UIView *)view hint:(NSString *)hint;

- (void)hideHud;

- (void)showHint:(NSString *)hint;

- (void)showHint:(NSString *)hint yOffset:(float)yOffset;
@end

NS_ASSUME_NONNULL_END
