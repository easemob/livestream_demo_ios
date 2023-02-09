//
//  EaseBoradCastCard.h
//  EaseMobLiveDemo
//
//  Created by easemob on 2021/3/23.
//  Copyright © 2021 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseBoradCastCard : NSObject

@property (nonatomic, strong) UIImage *cardBackImg;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *broadCastType;

- (instancetype)initWithInfo:(UIImage *)cardBackImg title:(NSString *)title desc:(NSString *)desc type:(NSString *)broadCastType;

@end

NS_ASSUME_NONNULL_END
