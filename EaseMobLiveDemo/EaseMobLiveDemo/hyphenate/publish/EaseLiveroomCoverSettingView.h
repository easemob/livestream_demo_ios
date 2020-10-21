//
//  EaseLiveroomCoverSetting.h
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/10/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseBaseSubView.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseLiveroomCoverSettingView : EaseBaseSubView

- (instancetype)init;

@property (nonatomic, copy) void (^doneCompletion)(NSUInteger type);

@end

NS_ASSUME_NONNULL_END
