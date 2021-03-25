//
//  UIImage+Color.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/18.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;

@end
