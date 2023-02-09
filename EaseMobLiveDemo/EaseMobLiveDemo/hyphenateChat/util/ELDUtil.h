//
//  ACDUtil.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDUtil : NSObject
+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font;

+ (UIBarButtonItem *)customBarButtonItem:(NSString *)title
                                  action:(SEL)action
                            actionTarget:(id)actionTarget;

+ (UIBarButtonItem *)customBarButtonItemImage:(NSString *)imageName
                                       action:(SEL)action
                                 actionTarget:(id)actionTarget;

+ (UIBarButtonItem *)customLeftButtonItem:(NSString *)title
                                   action:(SEL)action
                             actionTarget:(id)actionTarget;

+ (NSDate *)dateFromString:(NSString *)dateString;

+ (NSInteger)ageFromDateOfBirth:(NSDate *)date;

+ (NSInteger)ageFromBirthString:(NSString *)birthString;

+ (UIViewController * )topViewController;

@end

NS_ASSUME_NONNULL_END
