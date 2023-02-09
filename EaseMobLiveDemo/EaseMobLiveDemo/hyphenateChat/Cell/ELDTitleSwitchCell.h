//
//  ACDTitleSwitchCell.h
//  AgoraChat
//
//  Created by liu001 on 2022/3/9.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ELDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELDTitleSwitchCell : ELDCustomCell
@property (nonatomic, strong) UISwitch *aSwitch;
@property (nonatomic, copy) void (^switchActionBlock)(BOOL isOn);

@end

NS_ASSUME_NONNULL_END
