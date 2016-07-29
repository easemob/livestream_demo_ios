//
//  EaseSelectHeaderView.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/6.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EaseSelectHeaderViewDelegate <NSObject>

- (void)didSelectButtonWithIndex:(NSInteger)index;


@end

@interface EaseSelectHeaderView : UIView

@property (nonatomic, weak) id<EaseSelectHeaderViewDelegate> delegate;

- (void)setSelectWithIndex:(NSInteger)index;

@end
