//
//  EaseBroadCastTabCell.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2021/3/23.
//  Copyright © 2021 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBoradCastCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseBroadCastTabCell : UITableViewCell

+ (EaseBroadCastTabCell *)tableView:(UITableView *)tableView;

@property (nonatomic, strong) EaseBoradCastCard *model;

@end

NS_ASSUME_NONNULL_END
