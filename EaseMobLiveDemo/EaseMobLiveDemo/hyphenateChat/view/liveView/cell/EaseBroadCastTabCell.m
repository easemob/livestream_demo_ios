//
//  EaseBroadCastTabCell.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2021/3/23.
//  Copyright © 2021 zmw. All rights reserved.
//

#import "EaseBroadCastTabCell.h"
#import <Masonry/Masonry.h>

@interface EaseBroadCastTabCell ()

@property (nonatomic, strong) UIButton *cardBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation EaseBroadCastTabCell

+ (EaseBroadCastTabCell *)tableView:(UITableView *)tableView
{
    static NSString *cellId = @"EaseBroadCastTabCell";
    EaseBroadCastTabCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[EaseBroadCastTabCell alloc] initWithIdentifier:cellId];
    }
    
    return cell;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self _addSubViews];
    }
    return self;
}

- (void)_addSubViews
{
    _cardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cardBtn.userInteractionEnabled = NO;
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 0;
    _descLabel = [[UILabel alloc]init];
    _descLabel.textColor = [UIColor whiteColor];
    _descLabel.font = [UIFont systemFontOfSize:12];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    _descLabel.numberOfLines = 0;
    
    self.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_cardBtn];
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_descLabel];
    
    __weak typeof(self) weakSelf = self;
    [_cardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom);
        make.left.equalTo(weakSelf.contentView.mas_left).offset(13);
        make.right.equalTo(weakSelf.contentView.mas_right).offset(-13);
        make.height.equalTo(@125);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).offset(32);
        make.left.equalTo(_cardBtn.mas_left).offset(13).offset(24);
        make.right.equalTo(weakSelf.contentView.mas_centerX);
    }];
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel.mas_bottom).offset(6);
        make.left.equalTo(_cardBtn.mas_left).offset(13).offset(24);
        make.right.equalTo(weakSelf.contentView.mas_centerX);
    }];
}

- (void)setModel:(EaseBoradCastCard *)model
{
    [_cardBtn setBackgroundImage:model.cardBackImg forState:UIControlStateNormal];
    _titleLabel.text = model.title;
    NSMutableAttributedString *attContentStr = [[NSMutableAttributedString alloc] initWithString:model.desc];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attContentStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [model.desc length])];
    _descLabel.attributedText = attContentStr;
    [_descLabel sizeToFit];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
