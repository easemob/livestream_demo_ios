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

@end

@interface EaseEndLiveView : UIView

@property (nonatomic, weak) id<EaseEndLiveViewDelegate> delegate;

- (instancetype)initWithUsername:(NSString*)username
                            like:(NSString*)like
                            time:(NSString*)time
                        audience:(NSString*)audience
                        comments:(NSString*)comments;


@end
