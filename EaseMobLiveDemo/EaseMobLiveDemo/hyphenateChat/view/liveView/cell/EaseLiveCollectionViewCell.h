//
//  EaseCollectionViewCell.h
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBaseViewController.h"

@class EaseLiveRoom;
@interface EaseLiveCollectionViewCell : UICollectionViewCell

- (void)setLiveRoom:(EaseLiveRoom*)room liveBehavior:(kTabbarItemBehavior)liveBehavior;

@end
