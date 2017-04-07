//
//  EaseEndLiveView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/19.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EaseEndLiveViewDelegate <NSObject>

- (void)didClickEndButton;

- (void)didClickContinueButton;

@end

@interface EaseEndLiveView : UIView

@property (nonatomic, weak) id<EaseEndLiveViewDelegate> delegate;

- (instancetype)initWithUsername:(NSString*)username
                        audience:(NSString*)audience;

- (void)setAudience:(NSString*)audience;


@end
