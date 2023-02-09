//
//  ACDTitleDetailCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/17.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDTitleDetailCell.h"

@implementation ELDTitleDetailCell

- (void)prepare {
    
    self.nameLabel.font = NFont(14.0);
    self.nameLabel.textColor = TextLabelBlackColor;

    self.contentView.backgroundColor = ViewControllerBgWhiteColor;
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kEaseLiveDemoPadding * 1.6);
        make.right.equalTo(self.detailLabel.mas_left);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kEaseLiveDemoPadding * 1.6);
    }];
    
}

#pragma mark getter and setter
- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = Font(@"PingFang SC", 16.0);
        _detailLabel.textColor = TextLabelGrayColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = COLOR_HEX(0xF5F5F5);
    }else {
        self.contentView.backgroundColor = ViewControllerBgWhiteColor;
    }
}

@end
