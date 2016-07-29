//
//  EaseProfileTextView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseProfileTextView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString*)name
                       number:(NSString*)number;

- (void)setNumberColor:(UIColor*)color;

- (void)setNameColor:(UIColor*)color;

@end
