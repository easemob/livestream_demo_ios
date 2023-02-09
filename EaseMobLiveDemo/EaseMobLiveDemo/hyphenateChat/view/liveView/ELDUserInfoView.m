//
//  ELDContactView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/11.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDUserInfoView.h"
#import "ELDTitleSwitchCell.h"
#import "ELDUserInfoHeaderView.h"
#import "ELDTitleDetailCell.h"

#define kUserInfoCellTitle @"kUserInfoCellTitle"
#define kUserInfoCellActionType @"kUserInfoCellActionType"
#define kUserInfoAlertTitle @"kUserInfoAlertTitle"

#define kMuteAll NSLocalizedString(@"live.allTimedOut", nil)

#define kUserInfoCellHeight 44.0
#define kHeaderViewHeight 154.0

@interface ELDUserInfoView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) ELDUserInfoHeaderView *headerView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ELDTitleSwitchCell *muteCell;

@property (nonatomic, strong) EMUserInfo *userInfo;
@property (nonatomic, strong) NSString *currentUsername;
@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic, assign) ELDMemberRoleType beOperationedMemberRoleType;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableDictionary *actionTypeDic;

//owner check oneself
@property (nonatomic, assign) BOOL ownerSelf;

//whether isMute
@property (nonatomic, assign) BOOL isMute;

//whether isBlock
@property (nonatomic, assign) BOOL isBlock;

//whether isWhite
@property (nonatomic, assign) BOOL isWhite;


@property (nonatomic, assign) ELDMemberVCType memberVCType;

@property (nonatomic, strong) NSString *displayName;

@end


@implementation ELDUserInfoView
- (instancetype)initWithUsername:(NSString *)username
                        chatroom:(EMChatroom *)chatroom
                    memberVCType:(ELDMemberVCType)memberVCType {
    self = [super init];
    if (self) {
        
        self.currentUsername = username;
        self.chatroom = chatroom;
        self.memberVCType = memberVCType;
        
        [self fetchUserInfoWithUsername:username];
     
    }
    return self;
}

- (instancetype)initWithOwnerId:(NSString *)ownerId
                       chatroom:(EMChatroom *)chatroom {
    self = [super init];
    if (self) {
        self.currentUsername = ownerId;
        self.chatroom = chatroom;
        
        if ([EMClient.sharedClient.currentUsername isEqualToString:ownerId]) {
            self.ownerSelf = YES;
            self.beOperationedMemberRoleType = ELDMemberRoleTypeOwner;
            self.isMute = NO;
        }
        
        [self fetchUserInfoWithUsername:self.currentUsername];
     
    }
    return self;
}


- (void)fetchUserInfoWithUsername:(NSString *)username {
    [EMClient.sharedClient.userInfoManager fetchUserInfoById:@[username] completion:^(NSDictionary *aUserDatas, EMError *aError) {
        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userInfo = aUserDatas[username];
                [self.headerView updateUIWithUserInfo:self.userInfo roleType:self.beOperationedMemberRoleType isMute:self.isMute];
                [self buildCells];
                
            });
        }
    }];
}


- (void)placeAndlayoutSubviews {
    self.backgroundColor = UIColor.clearColor;

    UIView *alphaBgView = UIView.alloc.init;
    alphaBgView.alpha = 0.0;

    
    [self addSubview:alphaBgView];
    [self addSubview:self.headerView];
    [self addSubview:self.table];

    
    CGFloat topPadding = (kUserInfoHeaderImageHeight + 2 * 2) * 0.5;

    [alphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

        
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(kHeaderViewHeight));
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.table.mas_top).offset(7.0);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.dataArray.count * kUserInfoCellHeight));
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-[self bottomPadding]);
    }];
}



- (void)buildCells {
    NSMutableArray *tempArray = NSMutableArray.new;

    if (self.ownerSelf) {
        [tempArray addObject:@{kUserInfoCellTitle:kMuteAll}];
    }else {
        //owner check oneself
        if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner) {
            if (self.beOperationedMemberRoleType == ELDMemberRoleTypeOwner) {
                self.ownerSelf = YES;
                [tempArray addObject:@{kUserInfoCellTitle:kMuteAll}];
            }else if(self.beOperationedMemberRoleType == ELDMemberRoleTypeAdmin){
                
                if (self.memberVCType == ELDMemberVCTypeAll) {
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveAdmin]];
                    if (self.isMute) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                    }
                    
                    if (self.isWhite) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                    }
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
                }else {
                    [tempArray  addObjectsFromArray:[self addOperationNotInAllView]];
                }
                
            }else {
                if (self.memberVCType == ELDMemberVCTypeAll) {
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeAdmin]];
                    if (self.isMute) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                    }
                    
                    if (self.isWhite) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                    }
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
                }else {
                    [tempArray  addObjectsFromArray:[self addOperationNotInAllView]];
                }
            }
        }
        
        if (self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
            if (self.beOperationedMemberRoleType == ELDMemberRoleTypeOwner || self.beOperationedMemberRoleType == ELDMemberRoleTypeAdmin) {
                // no operate permission
            }else {
                if (self.memberVCType == ELDMemberVCTypeAll) {
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeAdmin]];
                    if (self.isMute) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeMute]];
                    }
                    
                    if (self.isWhite) {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
                    }else {
                        [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeWhite]];
                    }
                    [tempArray addObject:self.actionTypeDic[kMemberActionTypeMakeBlock]];
                }else {
                    [tempArray  addObjectsFromArray:[self addOperationNotInAllView]];
                }
            }
        }
        
        if (self.chatroom.permissionType == EMChatroomPermissionTypeMember) {
           // no operate permission
        }
    }

    self.dataArray = tempArray;
    
    [self placeAndlayoutSubviews];
    [self.table reloadData];
}

- (NSArray *)addOperationNotInAllView {
    NSMutableArray *tArray = NSMutableArray.array;
    if (self.memberVCType == ELDMemberVCTypeAdmin) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveAdmin]];
    }
    
    if (self.memberVCType == ELDMemberVCTypeAllow) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveWhite]];
    }

    if (self.memberVCType == ELDMemberVCTypeMute) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveMute]];
    }

    if (self.memberVCType == ELDMemberVCTypeBlock) {
        [tArray addObject:self.actionTypeDic[kMemberActionTypeRemoveBlock]];
    }
    
    return [tArray copy];
}


#pragma mark operation
//make all member silence 
- (void)allTheSilence:(BOOL)isAllTheSilence
{
    if (isAllTheSilence) {
        [[EMClient sharedClient].roomManager muteAllMembersFromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.muteSuccess", nil)];
            }
        }];
    } else {
        [[EMClient sharedClient].roomManager unmuteAllMembersFromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.unmuteSuccess", nil)];
            }
        }];
    }
}

- (void)addAdminAction
{
    [[EMClient sharedClient].roomManager addAdmin:self.currentUsername
                                       toChatroom:self.chatroom.chatroomId
                                       completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.setSuccess", nil)];
        }
                                       }];
}

- (void)removeAdminAction {
    if (_chatroom) {
        ELD_WS
        [[EMClient sharedClient].roomManager removeAdmin:self.currentUsername
                                            fromChatroom:self.chatroom.chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError) {
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
                [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.removeSuccess", nil)];
            }
                                              }];
    }
}



- (void)addMuteAction {
    [[EMClient sharedClient].roomManager muteMembers:@[self.currentUsername]
                                    muteMilliseconds:-1
                                        fromChatroom:self.chatroom.chatroomId
                                          completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.muteSuccess", nil)];
        }
                                          }];
}

//解除禁言
- (void)removeMuteAction
{
    ELD_WS
    [[EMClient sharedClient].roomManager unmuteMembers:@[self.currentUsername]
                                          fromChatroom:self.chatroom.chatroomId
                                            completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.unmuteSuccess", nil)];
        }
                                            }];
}




- (void)addBlockAction
{
    [[EMClient sharedClient].roomManager blockMembers:@[self.currentUsername]
                                         fromChatroom:self.chatroom.chatroomId
                                           completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.blockSuccess", nil)];
        }
                                           }];
}


- (void)removeBlockAction {
    [[EMClient sharedClient].roomManager unblockMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.unblockSuccess", nil)];
        }

    }];
    
}

- (void)addWhiteAction {
    [[EMClient sharedClient].roomManager addWhiteListMembers:@[self.currentUsername] fromChatroom:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.setSuccess", nil)];
        }

    }];
}


//从白名单移除
- (void)removeWhiteAction
{
[[EMClient sharedClient].roomManager removeWhiteListMembers:@[self.currentUsername]
                                           fromChatroom:self.chatroom.chatroomId
                                             completion:^(EMChatroom *aChatroom, EMError *aError) {
    if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
        [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.removeSuccess", nil)];
    }
                                             }];
}

- (void)kickAction
{
    [[EMClient sharedClient].roomManager removeMembers:@[self.currentUsername]
                                                 fromChatroom:self.chatroom.chatroomId
                                                   completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(updateLiveViewWithChatroom:error:successHint:)]) {
            [self.userInfoViewDelegate updateLiveViewWithChatroom:aChatroom error:aError successHint:NSLocalizedString(@"live.removeSuccess", nil)];
        }
                                            }];
}




- (void)confirmActionWithActionType:(ELDMemberActionType)actionType {
    switch (actionType) {
        case ELDMemberActionTypeMakeAdmin:
        {
            [self addAdminAction];
        }
            break;
        case ELDMemberActionTypeRemoveAdmin:
        {
            [self removeAdminAction];
        }
            break;
        case ELDMemberActionTypeMakeMute:
        {
            [self addMuteAction];
        }
            break;
        case ELDMemberActionTypeRemoveMute:
        {
            [self removeMuteAction];
        }
            break;

        case ELDMemberActionTypeMakeWhite:
        {
            [self addWhiteAction];
        }
            break;
        case ELDMemberActionTypeRemoveWhite:
        {
            [self removeWhiteAction];
        }
            break;
        case ELDMemberActionTypeMakeBlock:
        {
            [self addBlockAction];
        }
            break;
        case ELDMemberActionTypeRemoveBlock:
        {
            [self removeBlockAction];
        }
            break;

        default:
            break;
    }
    
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kUserInfoCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ELDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    if (cell == nil) {
        cell = [[ELDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ELDTitleDetailCell reuseIdentifier]];
    }

    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *title = dic[kUserInfoCellTitle];
    NSString *alertTitle = dic[kUserInfoAlertTitle];
    NSInteger actionType = [dic[kUserInfoCellActionType] integerValue];

    if (self.ownerSelf) {
        self.muteCell.nameLabel.text = title;
        [self.muteCell.aSwitch setOn:self.chatroom.isMuteAllMembers];
        
        return self.muteCell;
    }else {
        cell.nameLabel.text = title;
        
        cell.tapCellBlock = ^{
            if (self.userInfoViewDelegate && [self.userInfoViewDelegate respondsToSelector:@selector(showAlertWithTitle:messsage:actionType:)]) {
                [self.userInfoViewDelegate showAlertWithTitle:alertTitle messsage:@"" actionType:actionType];
            }
        };
    }
    
    return cell;
}


#pragma mark getter and setter
- (UITableView*)table
{
    if (_table == nil) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        //ios9.0+
        if ([_table respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
            _table.cellLayoutMarginsFollowReadableWidth = NO;
        }
        _table.dataSource = self;
        _table.delegate = self;
        _table.backgroundView = nil;
        _table.rowHeight = 44.0;
    }
    return _table;
}


- (ELDUserInfoHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[ELDUserInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderViewHeight)];
    }
    return _headerView;
}

- (ELDMemberRoleType)beOperationedMemberRoleType {
    NSString *currentUserId = self.userInfo.userId;
    if ([self.chatroom.owner isEqualToString:currentUserId]) {
        return ELDMemberRoleTypeOwner;
    }else  if ([self.chatroom.adminList containsObject:currentUserId]) {
        return ELDMemberRoleTypeAdmin;
    }else {
        return ELDMemberRoleTypeMember;
    }
}

- (BOOL)isMute {
    return [self.chatroom.muteList containsObject:self.userInfo.userId];
}

- (BOOL)isBlock {
    return [self.chatroom.blacklist containsObject:self.userInfo.userId];
}

- (BOOL)isWhite {
    return [self.chatroom.whitelist containsObject:self.userInfo.userId];
}


- (ELDTitleSwitchCell *)muteCell {
    if (_muteCell == nil) {
        _muteCell = [[ELDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDTitleSwitchCell reuseIdentifier]];
        _muteCell.selectionStyle = UITableViewCellSelectionStyleNone;
        ELD_WS
        _muteCell.switchActionBlock = ^(BOOL isOn) {
            [weakSelf allTheSilence:isOn];
        };
    }
    return _muteCell;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


//解禁：Want to unban Username?  添加白名单：Want to Move Username From the Allowed List? 从白名单移出：Want to Remove Username From the Allowed List? 设定管理员：Want to Move Username as a Moderator? 罢免管理员：Want to Remove Username as Moderator?

- (NSMutableDictionary *)actionTypeDic {
    if (_actionTypeDic == nil) {
        _actionTypeDic = NSMutableDictionary.new;
        
        _actionTypeDic[kMemberActionTypeMakeAdmin] = @{kUserInfoCellTitle:NSLocalizedString(@"live.setModerator", nil),kUserInfoCellActionType:@(ELDMemberActionTypeMakeAdmin),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.setModerator?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveAdmin] = @{kUserInfoCellTitle:NSLocalizedString(@"live.removeFromModerator", nil),kUserInfoCellActionType:@(ELDMemberActionTypeRemoveAdmin),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.removeFromModerator?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeMute] = @{kUserInfoCellTitle:NSLocalizedString(@"live.timeout", nil),kUserInfoCellActionType:@(ELDMemberActionTypeMakeMute),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.timeout?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveMute] = @{kUserInfoCellTitle:NSLocalizedString(@"live.removeTimeout", nil),kUserInfoCellActionType:@(ELDMemberActionTypeRemoveMute),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.removeTimeout?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeWhite] = @{kUserInfoCellTitle:NSLocalizedString(@"live.moveToAllowList", nil),kUserInfoCellActionType:@(ELDMemberActionTypeMakeWhite),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.moveToAllowList?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveWhite] = @{kUserInfoCellTitle:NSLocalizedString(@"live.removeToAllowList", nil),kUserInfoCellActionType:@(ELDMemberActionTypeRemoveWhite),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.removeToAllowList?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeMakeBlock] = @{kUserInfoCellTitle:NSLocalizedString(@"live.ban", nil),kUserInfoCellActionType:@(ELDMemberActionTypeMakeBlock),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.ban?", nil),self.displayName]};
        
        _actionTypeDic[kMemberActionTypeRemoveBlock] = @{kUserInfoCellTitle:NSLocalizedString(@"live.unban", nil),kUserInfoCellActionType:@(ELDMemberActionTypeRemoveBlock),kUserInfoAlertTitle:[NSString stringWithFormat:NSLocalizedString(@"live.unban?", nil),self.displayName]};

    }
    return _actionTypeDic;
}

- (NSString *)displayName {
    if (self.userInfo) {
        return self.userInfo.nickname ?: self.userInfo.userId;
    }
    return @"";
}


@end

#undef kUserInfoCellTitle
#undef kUserInfoCellActionType
#undef kUserInfoAlertTitle
#undef kUserInfoCellHeight
#undef kHeaderViewHeight
#undef kMuteAll

