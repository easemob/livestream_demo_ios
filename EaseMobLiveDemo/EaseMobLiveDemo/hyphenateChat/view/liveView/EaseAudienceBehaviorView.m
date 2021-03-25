//
//  EaseAudienceBehaviorView.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/3/3.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseAudienceBehaviorView.h"
#import "Masonry.h"

@interface EaseAudienceBehaviorView ()

@property (nonatomic, strong) NSString *currentOperateUser;//当前操作对象

@property (nonatomic, strong) NSString *chatroomId;//当前聊天室

@property (nonatomic, strong) NSArray *mutelist;//禁言列表

@property (nonatomic, strong) NSArray *whitelist;//白名单列表

@property (nonatomic, strong) UIButton *muteBtn;

@property (nonatomic, strong) UIButton *whitelistBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation EaseAudienceBehaviorView

- (instancetype)initWithOperateUser:(NSString*)currentObject chatroomId:(NSString*)chatroomId
{
    self = [super init];
    if (self) {
        self.currentOperateUser = currentObject;
        self.chatroomId = chatroomId;
        [self _setupSubviews];
        [self _settingStatus];
    }
    return self;
}

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.cancelBtn];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@46);
        make.bottom.equalTo(self).offset(-30);
    }];
    [self addSubview:self.whitelistBtn];
    [_whitelistBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@46);
        make.bottom.equalTo(_cancelBtn.mas_top).offset(-8);
    }];
    [self addSubview:self.muteBtn];
    [_muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@46);
        make.bottom.equalTo(_whitelistBtn.mas_top);
    }];
}

- (UIButton*)muteBtn
{
    if (_muteBtn == nil) {
        _muteBtn = [[UIButton alloc]init];
        [_muteBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:199/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_muteBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        _muteBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _muteBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_muteBtn addTarget:self action:@selector(muteAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteBtn;
}

- (UIButton*)whitelistBtn
{
    if (_whitelistBtn == nil) {
        _whitelistBtn = [[UIButton alloc]init];
        [_whitelistBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_whitelistBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        _whitelistBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _whitelistBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_whitelistBtn addTarget:self action:@selector(whitelistAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _whitelistBtn;
}

- (UIButton*)cancelBtn
{
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIButton alloc]init];
        [_cancelBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        _cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _cancelBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

//设置状态
- (void)_settingStatus
{
    [self _loadMuteList];
    if ([self.mutelist containsObject:_currentOperateUser]) {
        [_muteBtn setTitle:@"解除禁言" forState:UIControlStateNormal];
        _muteBtn.selected = NO;
    } else {
        [_muteBtn setTitle:@"禁言" forState:UIControlStateNormal];
        _muteBtn.selected = YES;
    }
    
    [self _loadWhitelist];
    if ([self.whitelist containsObject:_currentOperateUser]) {
        [_whitelistBtn setTitle:@"移除白名单" forState:UIControlStateNormal];
        _whitelistBtn.selected = NO;
    } else {
        [_whitelistBtn setTitle:@"加入白名单" forState:UIControlStateNormal];
        _whitelistBtn.selected = YES;
    }
}

#pragma - Action

//禁言操作
- (void)muteAction:(UIButton*)btn
{
    __weak typeof(self) weakSelf = self;
    if (btn.isSelected) {
        //禁言
        [[EMClient sharedClient].roomManager muteMembers:@[_currentOperateUser] muteMilliseconds:-1 fromChatroom:_chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf cancelAction];
        }];
    } else {
        //解除禁言
        [[EMClient sharedClient].roomManager unmuteMembers:@[_currentOperateUser] fromChatroom:_chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf cancelAction];
        }];
    }
}

//白名单操作
- (void)whitelistAction:(UIButton*)btn
{
    __weak typeof(self) weakSelf = self;
    if (btn.isSelected) {
        //添加白名单
        [[EMClient sharedClient].roomManager addWhiteListMembers:@[_currentOperateUser] fromChatroom:_chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf cancelAction];
        }];
    } else {
        //从白名单移除
        [[EMClient sharedClient].roomManager removeWhiteListMembers:@[_currentOperateUser] fromChatroom:_chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf cancelAction];
        }];
    }
}

//取消
- (void)cancelAction
{
    [self removeFromParentView];
}

//获取禁言列表
- (void)_loadMuteList
{
    self.mutelist = [[EMClient sharedClient].roomManager getChatroomMuteListFromServerWithId:_chatroomId pageNumber:0 pageSize:10000 error:nil];
}

//获取白名单列表
- (void)_loadWhitelist
{
    self.whitelist = [[EMClient sharedClient].roomManager getChatroomWhiteListFromServerWithId:_chatroomId error:nil];
}

- (NSArray*)mutelist
{
    if (_mutelist == nil) {
        _mutelist = [[NSArray alloc] init];
    }
    return _mutelist;
}

@end
