//
//  EaseGiftConfirmView.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseGiftConfirmView.h"
#import "EaseUserInfoManagerHelper.h"


@interface EaseGiftConfirmView()
{
    long _giftNum;
}

@property (nonatomic, strong) EaseGiftCell *giftCell;

@property (nonatomic, strong) NSString *titleText;

@property (nonatomic, strong) NSString *giftId;

@property (nonatomic, strong) ELDGiftModel *giftModel;

@end

@implementation EaseGiftConfirmView

- (instancetype)initWithGiftInfo:(EaseGiftCell *)giftCell giftNum:(long)num titleText:(NSString *)titleText giftId:(NSString *)giftId
{
    self = [super init];
       if (self) {
           _giftCell = giftCell;
           _titleText = titleText;
           _giftNum = num;
           _giftId = giftId;
           [self _setupSuviews];
       }
    return self;
}

- (instancetype)initWithGiftModel:(ELDGiftModel *)giftModel
                          giftNum:(NSInteger)num
                        titleText:(NSString *)titleText
{
    self = [super init];
       if (self) {
           _giftModel = giftModel;
           _titleText = titleText;
           _giftNum = num;
           [self _setupSuviews];
       }
    return self;
}


- (void)_setupSuviews
{
    self.backgroundColor = [UIColor clearColor];
    
    UIView *confirmView = [[UIView alloc]init];
    confirmView.backgroundColor = [UIColor whiteColor];
    confirmView.layer.cornerRadius = 8;
    [self addSubview:confirmView];
    [confirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.equalTo(@240);
        make.centerY.centerX.equalTo(self);
    }];
    
    UILabel *content = [[UILabel alloc]init];
    content.text = self.titleText;
    content.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0];
    content.textAlignment = NSTextAlignmentCenter;
    content.font = [UIFont fontWithName:@"PingFangSC" size: 20];
    [confirmView addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(confirmView).offset(20);
        make.left.equalTo(confirmView).offset(32);
        make.right.equalTo(confirmView).offset(-32);
        make.height.equalTo(@28);
    }];
    
    UIView *memberView = [[UIView alloc]init];
    memberView.backgroundColor = RGBACOLOR(249, 249, 249, 1);
    [confirmView addSubview:memberView];
    [memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content.mas_bottom).offset(20);
        make.left.equalTo(confirmView).offset(32);
        make.right.equalTo(confirmView).offset(-32);
        make.height.equalTo(@90);
    }];
    UIImageView *avatarView = [[UIImageView alloc]initWithImage:ImageWithName(self.giftModel.giftname)];
    [memberView addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(memberView).offset(22);
        make.bottom.equalTo(memberView).offset(-22);
        make.width.equalTo(@46);
    }];
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.text = [NSString stringWithFormat:@"%ld %@",(long)_giftNum,self.giftModel.giftname];
    nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    nameLabel.font = [UIFont fontWithName:@"PingFangSC" size: 18];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [memberView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarView.mas_right).offset(10);
        make.top.equalTo(memberView).offset(32);
        make.bottom.equalTo(memberView).offset(-32);
        make.right.equalTo(memberView).offset(-10);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setTitle:NSLocalizedString(@"publish.cancel", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBtn setTitleColor:RGBACOLOR(51, 51, 51, 1) forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    cancelBtn.layer.borderWidth = 1;
    cancelBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    cancelBtn.layer.cornerRadius = 8;
    [confirmView addSubview:cancelBtn];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-32)/2;
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(confirmView);
        make.height.equalTo(@55);
        make.width.mas_equalTo(width);
    }];
    
    UIButton *confirmBtn = [[UIButton alloc]init];
    [confirmBtn setTitle:@"Give now" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [confirmBtn setTitleColor:RGBACOLOR(255, 43, 43, 1) forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:[UIColor whiteColor]];
    confirmBtn.layer.borderWidth = 1;
    confirmBtn.layer.borderColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    confirmBtn.layer.cornerRadius = 8;
    [confirmView addSubview:confirmBtn];
    confirmBtn.tag = 1;
    [confirmBtn addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(confirmView);
        make.height.equalTo(@55);
        make.width.mas_equalTo(width);
    }];
}

#pragma mark - Action

- (void)confirmAction:(UIButton *)btn
{
    BOOL confirm = false;
    if (btn.tag == 1) {
        confirm = true;
    }
    if (_doneCompletion) {
        
        [EaseUserInfoManagerHelper fetchOwnUserInfoCompletion:^(EMUserInfo * _Nonnull ownUserInfo) {
           
            JPGiftCellModel *cellModel = [[JPGiftCellModel alloc]init];
            cellModel.id = self.giftModel.giftId;
            cellModel.userAvatarURL = ownUserInfo.avatarUrl;
            cellModel.username = ownUserInfo.nickname ?: ownUserInfo.userId;
            cellModel.icon = ImageWithName(self.giftModel.giftname);
            cellModel.name = self.giftModel.giftname;
            cellModel.count = (NSInteger)_giftNum;
            _doneCompletion(confirm,cellModel);
        }];
    }
    [self removeFromParentView];
}

@end
