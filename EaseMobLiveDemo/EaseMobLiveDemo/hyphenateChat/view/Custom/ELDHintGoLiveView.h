//
//  ELDHintGoLiveView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/28.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDHintGoLiveView : UIView
/// 无数据占位图
@property (nonatomic,strong,readonly) UIImageView *hintImageView;

/**
 提示语
 */
@property (nonatomic,strong,readonly) UILabel *prompt;

@end

NS_ASSUME_NONNULL_END
