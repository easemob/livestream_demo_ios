//
//  EaseAnchorView.h
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/2/17.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@class EaseLiveRoom;
@interface EaseAnchorCardView : EaseBaseSubView
- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room;

@end

NS_ASSUME_NONNULL_END
