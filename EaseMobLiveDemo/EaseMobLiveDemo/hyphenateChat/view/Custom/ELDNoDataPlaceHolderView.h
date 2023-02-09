//
//  ACDNoDataPromptView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDNoDataPlaceHolderView : UIView

/// 无数据占位图
@property (nonatomic,strong,readonly) UIImageView *noDataImageView;

/**
 提示语
 */
@property (nonatomic,strong,readonly) UILabel *prompt;

@end

NS_ASSUME_NONNULL_END
