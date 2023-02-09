//
//  EaseLiveCustomCell.m
//  chat-uikit
//
//  Created by liu001 on 2022/5/12.
//

#import "EaseLiveCustomCell.h"
#import "EaseUserInfoManagerHelper.h"
#import "EaseKitDefine.h"


@interface EaseLiveCustomCell ()
@property (nonatomic, strong) UIView* bottomLine;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation EaseLiveCustomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                 customOption:(EaseChatViewCustomOption *)customOption {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customOption = customOption;
        [self prepare];
        [self placeSubViews];
    }
    return self;
}


- (void)tapAction {
    if (self.tapCellBlock) {
        self.tapCellBlock();
    }
}

- (void)prepare {

}

- (void)placeSubViews {
    
}

- (void)updateWithObj:(id)obj {
    
}


- (void)fetchUserInfoWithUserId:(NSString *)userId
                     completion:(void (^)(NSDictionary * _Nonnull userInfoDic))completion {
    [EaseUserInfoManagerHelper fetchUserInfoWithUserIds:@[userId] completion:completion];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}


+ (CGFloat)height {
    return 54.0f;
}


#pragma mark getter and setter
- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = EaseAvatarHeight * 0.5;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}


- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.font = EaseKitNFont(12.0f);
        _nameLabel.textColor = EaseKitWhiteAlphaColor;
    }
    return _nameLabel;
}


- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = UIView.new;
        _bottomLine.backgroundColor = EaseKitCOLOR_HEX(0x333333);
    }
    return _bottomLine;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 8.0f;
    }
    return _bgView;
}

@end

#undef EaseAvatarHeight
