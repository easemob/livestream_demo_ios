//
//  UIView+Blur.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/6/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "UIView+Blur.h"

@implementation UIView (Blur)
- (void)blurWithEffectStyle:(UIBlurEffectStyle)style {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];

    UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    [self addSubview:visualView];
    [visualView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

}

@end
