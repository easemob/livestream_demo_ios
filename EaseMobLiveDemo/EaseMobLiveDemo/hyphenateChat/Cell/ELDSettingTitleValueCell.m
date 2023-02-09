//
//  ELDSettingTitleValueCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/6/12.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDSettingTitleValueCell.h"

@implementation ELDSettingTitleValueCell

- (void)prepare {
    
    self.contentView.backgroundColor = ViewControllerBgBlackColor;
//    self.backgroundColor = ViewControllerBgBlackColor;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.bottomLine];
    
}

- (void)placeSubViews {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kEaseLiveDemoPadding * 1.6);
        make.width.equalTo(@(140.0));
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(5.0);
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16.0);
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
        _detailLabel.font = Font(@"PingFang SC", 16.0);
        _detailLabel.textColor = TextLabelGrayColor;
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _detailLabel;
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = COLOR_HEX(0x333333);
    }else {
        self.contentView.backgroundColor = ViewControllerBgBlackColor;
    }
}

@end
