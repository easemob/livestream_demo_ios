//
//  ELDGenderView.h
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/7.
//  Copyright © 2022 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDGenderView : UIView
@property (nonatomic, strong, readonly)UILabel *ageLabel;
@property (nonatomic, strong, readonly)UIImageView *genderImageView;

- (void)updateWithGender:(NSInteger)gender birthday:(NSString *)birthday;

@end

NS_ASSUME_NONNULL_END
