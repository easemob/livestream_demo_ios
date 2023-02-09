//
//  ACDGroupInfoMembersCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/28.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDSettingAvatarTitleValueAccessCell.h"

@interface ELDSettingAvatarTitleValueAccessCell ()
@property (nonatomic, strong) UIImageView* accessoryImageView;
@end


@implementation ELDSettingAvatarTitleValueAccessCell

- (void)prepare {
    self.contentView.backgroundColor = ViewControllerBgBlackColor;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.accessoryImageView];
    [self.contentView addSubview:self.bottomLine];
}

- (void)placeSubViews {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.mas_equalTo(kAvatarHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(kEaseLiveDemoPadding);
        make.right.equalTo(self.detailLabel.mas_left);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.equalTo(self.accessoryImageView.mas_left).offset(-13.0);
    }];
     
    [self.accessoryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@(8.0));
        make.height.equalTo(@(12.0));
        make.right.equalTo(self.contentView).offset(-12.0);
    }];

    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@ELD_ONE_PX);
        make.bottom.equalTo(self.contentView);
    }];

}

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = NFont(16.0f);
        _detailLabel.textColor = TextLabelGrayColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

- (UIImageView *)accessoryImageView {
    if (_accessoryImageView == nil) {
        _accessoryImageView = [[UIImageView alloc] init];
        [_accessoryImageView setImage:ImageWithName(@"gray_right_arrow")];
        _accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _accessoryImageView;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = COLOR_HEX(0x333333);
    }else {
        self.contentView.backgroundColor = ViewControllerBgBlackColor;
    }
}

@end
