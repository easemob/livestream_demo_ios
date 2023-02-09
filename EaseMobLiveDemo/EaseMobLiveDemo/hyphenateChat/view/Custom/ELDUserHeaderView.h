//
//  ELDUserHeaderView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDUserHeaderView : UIView
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, copy) void (^tapHeaderViewBlock)(void);
- (instancetype)initWithFrame:(CGRect)frame
                   isEditable:(BOOL)isEditable;

@end

NS_ASSUME_NONNULL_END
