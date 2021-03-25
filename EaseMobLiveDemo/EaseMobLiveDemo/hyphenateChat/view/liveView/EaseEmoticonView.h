//
//  EMChatBarEmoticonView.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/30.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMEmoticonGroup.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EaseEmoticonViewDelegate;
@interface EaseEmoticonView : UIView

@property (nonatomic, weak) id<EaseEmoticonViewDelegate> delegate;

@property (nonatomic, readonly) CGFloat viewHeight;

- (instancetype)initWithOutlineFrame:(CGRect)frame;

@end


@protocol EaseEmoticonViewDelegate <NSObject>

@optional

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel;

- (void)didChatBarEmoticonViewSendAction;

@end

NS_ASSUME_NONNULL_END
