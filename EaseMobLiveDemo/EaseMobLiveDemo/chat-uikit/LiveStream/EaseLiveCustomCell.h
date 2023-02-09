//
//  EaseLiveCustomCell.h
//  chat-uikit
//
//  Created by liu001 on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import "EaseHeaders.h"
#import "EaseChatViewCustomOption.h"

#define EaseAvatarHeight 28.0f

NS_ASSUME_NONNULL_BEGIN

@interface EaseLiveCustomCell : UITableViewCell

@property (nonatomic, copy) void (^tapCellBlock)(void);
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UIView* bottomLine;
@property (nonatomic, strong, readonly)UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIView *bgView;

//custom chatView UI with option
@property (nonatomic, strong) EaseChatViewCustomOption *customOption;


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                 customOption:(EaseChatViewCustomOption *)customOption;

+ (NSString *)reuseIdentifier;
+ (CGFloat)height;
- (void)prepare;
- (void)placeSubViews;
- (void)updateWithObj:(id)obj;

// fetch userInfo update cell with userId
- (void)fetchUserInfoWithUserId:(NSString *)userId
                     completion:(void (^)(NSDictionary * _Nonnull userInfoDic))completion;

@end

NS_ASSUME_NONNULL_END

