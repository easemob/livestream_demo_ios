//
//  UIViewController+Bottom.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/15.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "UIViewController+Bottom.h"

@implementation UIViewController (Bottom)

- (CGFloat)bottomPadding {
    CGFloat bottom = 0;;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    return bottom;
}


@end
