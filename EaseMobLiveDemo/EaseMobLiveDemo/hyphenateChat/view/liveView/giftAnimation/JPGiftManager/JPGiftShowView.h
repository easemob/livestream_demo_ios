//
//  JPGiftShowView.h  礼物的展示view
//  JPGiftManager
//
//  Created by Keep丶Dream on 2018/3/13.
//  Copyright © 2018年 dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPGiftCountLabel.h"

@class JPGiftModel;
typedef void(^completeShowViewBlock)(BOOL finished,NSString *giftKey);

typedef void(^completeShowViewKeyBlock)(JPGiftModel *giftModel);

@interface JPGiftShowView : UIView
/** block */
@property(nonatomic,copy)completeShowViewBlock showViewFinishBlock;
/** 返回当前礼物的唯一key */
@property(nonatomic,copy)completeShowViewKeyBlock showViewKeyBlock;

/**
 展示礼物动效

 @param giftModel 礼物的数据
 @param completeBlock 展示完毕回调
 */
- (void)showGiftShowViewWithModel:(JPGiftModel *)giftModel
                    completeBlock:(completeShowViewBlock)completeBlock;

/**
 隐藏礼物
 */
- (void)hiddenGiftShowView;

@end

