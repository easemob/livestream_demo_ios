//
//  ELDUserInfoHeaderView.h
//  EaseMobLiveDemo
//
//  Created by liang on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDUserInfoHeaderView : UIView
@property (nonatomic, assign) ELDMemberRoleType roleType;
@property (nonatomic, assign) BOOL isMute;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateUIWithUserInfo:(EMUserInfo *)userInfo
                    roleType:(ELDMemberRoleType)roleType
                      isMute:(BOOL)isMute;

@end

NS_ASSUME_NONNULL_END
