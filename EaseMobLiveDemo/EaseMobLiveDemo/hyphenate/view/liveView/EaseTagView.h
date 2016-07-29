//
//  EaseTagView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EaseTagView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString*)name
                    imageName:(NSString*)imageName;

- (void)setNameColor:(UIColor*)color;

@end

@interface EaseEndTagView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                         name:(NSString*)name
                         text:(NSString*)text;

- (void)setTextColor:(UIColor*)color;

- (void)setNameColor:(UIColor*)color;

@end