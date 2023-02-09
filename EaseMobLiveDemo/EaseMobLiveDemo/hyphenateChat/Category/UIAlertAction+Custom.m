//
//  UIAlertAction+Custom.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "UIAlertAction+Custom.h"

@implementation UIAlertAction (Custom)

+ (UIAlertAction* )alertActionWithTitle:(NSString *)title
                              iconImage:(UIImage *)iconImage
                              textColor:(UIColor *)textColor
                              alignment:(NSTextAlignment )alignment
                             completion:(void(^)(void))completion {
    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];
    
    [alertAction setValue:textColor forKey:@"titleTextColor"];
    [alertAction setValue:[NSNumber numberWithInteger:alignment] forKey:@"titleTextAlignment"];
    [alertAction setValue:iconImage forKey:@"image"];

    return alertAction;
}

@end
