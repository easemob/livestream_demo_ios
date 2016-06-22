//
//  EaseGiftFlyView.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/13.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseGiftFlyView : UIView

-(instancetype)initWithMessage:(EMMessage*)messge;

- (void)animateInView:(UIView *)view;

@end
