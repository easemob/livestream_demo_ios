//
//  EaseGiftCell.h
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELDGiftModel.h"

@protocol EaseGiftCellDelegate;
@interface EaseGiftCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *giftImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, weak) id<EaseGiftCellDelegate> delegate;
@property (nonatomic, strong, readonly) ELDGiftModel *giftModel;

- (void)updateWithGiftModel:(ELDGiftModel *)giftModel;

@end

@protocol EaseGiftCellDelegate <NSObject>

@required
- (void)giftCellDidSelected:(EaseGiftCell *)aCell;

@end
