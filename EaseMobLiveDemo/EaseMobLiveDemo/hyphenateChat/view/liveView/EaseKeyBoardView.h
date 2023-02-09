//
//  EaseKeyBoardView.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//创建自定义键盘协议
@protocol My_KeyBoardDelegate <NSObject>
//创建协议方法
@required//必须执行的方法
- (void)numberKeyBoard:(NSInteger) number;
- (void)cancelKeyBoard;
- (void)finishKeyBoard;
- (void)periodKeyBoard;
- (void)changeKeyBoard;
@optional//不必须执行方法

@end


@interface EaseKeyBoardView : UIView

@property (nonatomic, strong) id<My_KeyBoardDelegate> delegate;

- (id)initWithNumber:(NSNumber *)number;
@end

NS_ASSUME_NONNULL_END
