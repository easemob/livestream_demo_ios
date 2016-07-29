//
//  EaseTextAttachment.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/13.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseTextAttachment.h"

#define kEmotionTopMargin -5.0f

@interface EaseTextAttachment ()

@end

@implementation EaseTextAttachment
//I want my emoticon has the same size with line's height
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex NS_AVAILABLE_IOS(7_0)
{
    return CGRectMake( 0, kEmotionTopMargin, 36, 18);
}

@end
