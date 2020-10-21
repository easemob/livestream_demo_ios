//
//  EaseTextField.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/10/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseTextField.h"

@implementation EaseTextField

- (id)init
{
    self = [super init];
    return self;
}

// placeholder

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 11, 0);
}

// 控制文本的位置，左右缩 10

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 11, 0);
}

@end
