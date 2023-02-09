//
//  ELDNotificationView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/20.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDNotificationView : UIView

@property (nonatomic,copy) void (^displayFinishBlock)();

- (void)showHintMessage:(NSString *)message
             completion:(void(^)(BOOL finish))completion;

- (void)showHintMessage:(NSString *)message
         displayAllTime:(BOOL)displayAllTime
             completion:(void(^)(BOOL finish))completion;

@end

NS_ASSUME_NONNULL_END
