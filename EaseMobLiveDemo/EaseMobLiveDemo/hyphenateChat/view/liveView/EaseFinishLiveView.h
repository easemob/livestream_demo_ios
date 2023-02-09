//
//  EaseFinishLiveView.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/16.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseFinishLiveView : UIView

@property (nonatomic, copy) void (^doneCompletion)(BOOL isFinish);

- (instancetype)initWithTitleInfo:(NSString *)titleText;

@end

NS_ASSUME_NONNULL_END
