//
//  EaseChatCell.h
//
//  Created by EaseMob on 16/6/12.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseChatCell : UITableViewCell

- (void)setMesssage:(EMMessage*)message liveroom:(EaseLiveRoom*)liveroom;

+ (CGFloat)heightForMessage:(EMMessage *)message;

@end
