//
//  ACDUtil.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDUtil.h"

@implementation ELDUtil

+ (NSAttributedString *)attributeContent:(NSString *)content color:(UIColor *)color font:(UIFont *)font {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:color,
          NSFontAttributeName:font
        }];
    return attrString;
}

+ (UIBarButtonItem *)customBarButtonItem:(NSString *)title
                                  action:(SEL)action
                            actionTarget:(id)actionTarget {
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 50, 40);
    customButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [customButton setTitleColor:ButtonEnableBlueColor forState:UIControlStateNormal];
    [customButton setTitle:title forState:UIControlStateNormal];
    [customButton setTitle:title forState:UIControlStateHighlighted];
    [customButton addTarget:actionTarget action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customNavItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];

    return customNavItem;
}


+ (UIBarButtonItem *)customBarButtonItemImage:(NSString *)imageName
                                       action:(SEL)action
                                 actionTarget:(id)actionTarget {
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44.f, 44.f);
    [customButton setImage:ImageWithName(imageName) forState:UIControlStateNormal];
    [customButton addTarget:actionTarget action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *customNavItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];

    return customNavItem;
}



+ (UIBarButtonItem *)customLeftButtonItem:(NSString *)title
                                   action:(SEL)action
                             actionTarget:(id)actionTarget {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"nav_left_arrow_white"] forState:UIControlStateNormal];
    [backButton addTarget:actionTarget action:action forControlEvents:UIControlEventTouchUpInside];

//    Font(@"Roboto", 20.0)

    backButton.titleLabel.font = Font(@"Roboto", 20.0);
    [backButton setTitle:title forState:UIControlStateNormal];
    [backButton setTitleColor:TextLabelWhiteColor forState:UIControlStateNormal];
    UIBarButtonItem *customNavItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    return customNavItem;
}



+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter dateFromString:dateString];
}

+ (NSInteger)ageFromBirthString:(NSString *)birthString {
    NSDate *birthDate = [self dateFromString:birthString];
    return [self ageFromDateOfBirth:birthDate];
}


+ (NSInteger)ageFromDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
      
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
      
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear;
//    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
//        iAge++;
//    }
    if (iAge < 0) {
        iAge = 0;
    }
    return iAge;
}


// UIViewController+TopViewController.h
+ (UIViewController * )topViewController {
    UIViewController *resultVC;
    resultVC = [self recursiveTopViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self recursiveTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
 
+ (UIViewController * )recursiveTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self recursiveTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self recursiveTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
