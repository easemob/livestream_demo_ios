//
//  UIAlertAction+Custom.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertAction (Custom)
+ (UIAlertAction* )alertActionWithTitle:(NSString *)title
                              iconImage:(UIImage *)iconImage
                              textColor:(UIColor *)textColor
                              alignment:(NSTextAlignment )alignment
                             completion:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
