//
//  ELDUserInfoModel.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDUserInfoModel : NSObject
@property (nonatomic, strong, readonly) NSString *hyphenateId;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) UIImage *avatarImage;

- (instancetype)initWithUserInfo:(EMUserInfo *)userInfo;


@end

NS_ASSUME_NONNULL_END
