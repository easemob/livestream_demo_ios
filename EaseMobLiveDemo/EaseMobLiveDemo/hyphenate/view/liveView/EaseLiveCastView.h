//
//  EaseLiveCastView.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/26.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseLiveHeaderListView.h"

@class EaseLiveRoom;
@interface EaseLiveCastView : UIView

- (instancetype)initWithFrame:(CGRect)frame room:(EaseLiveRoom*)room;

@property (nonatomic, weak) id<EaseLiveHeaderListViewDelegate> delegate;

- (void)setNumberOfChatroom:(NSInteger)number;

@end
