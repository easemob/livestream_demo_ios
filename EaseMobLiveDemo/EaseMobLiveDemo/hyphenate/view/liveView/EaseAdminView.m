//
//  EaseAdminView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/28.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseAdminView.h"

#import "MJRefresh.h"
#import "EaseDefaultDataHelper.h"
#import "EaseCustomSwitch.h"
#import <QuartzCore/CALayer.h>

#define kButtonDefaultHeight 50.f
#define kDefaultPageSize 10

@interface EaseAdminCell : UITableViewCell

@property (nonatomic, strong) UILabel *identityLabel;
@property (nonatomic, strong) UIButton *clickButton;
@property (nonatomic, strong) UIView *anchorIdentity;
@property (nonatomic, strong) CAGradientLayer *livingGl;
@property (nonatomic, strong) CAGradientLayer *mutingGl;
@property (nonatomic, strong) UIImageView *headImageView;
@property (strong, nonatomic) EaseCustomSwitch *muteSwitch;//房间禁言开关
@property (strong, nonatomic) UILabel *mutingLabel;//正在禁言标签

@end

extern BOOL isAllTheSilence;
@implementation EaseAdminCell

- (UIButton*)clickButton
{
    if (_clickButton == nil) {
        _clickButton = [[UIButton alloc] init];
        _clickButton.frame = CGRectMake(self.width - 120, (65 - 30)/2, 60, 30);
        [_clickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _clickButton;
}

- (UILabel*)mutingLabel
{
    if (_mutingLabel == nil) {
        _mutingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 200, (65 - 15)/2, 40.f, 15.f)];
        _mutingLabel.text = @"禁言中";
        _mutingLabel.textAlignment = NSTextAlignmentCenter;
        _mutingLabel.textColor = [UIColor whiteColor];
        _mutingLabel.font = [UIFont systemFontOfSize:10.f];
        _mutingLabel.layer.cornerRadius = 7.5;
        [_mutingLabel.layer addSublayer:self.mutingGl];
    }
    return _mutingLabel;
}

- (EaseCustomSwitch*)muteSwitch
{
    if (_muteSwitch == nil) {
        _muteSwitch = [[EaseCustomSwitch alloc]initWithTextFont:[UIFont systemFontOfSize:12.f] OnText:@"" offText:@"" onBackGroundColor:RGBACOLOR(4, 174, 240, 1) offBackGroundColor:RGBACOLOR(191, 191, 191, 1) onButtonColor:RGBACOLOR(255, 255, 255, 1) offButtonColor:RGBACOLOR(255, 255, 255, 1) onTextColor:RGBACOLOR(4, 174, 240, 1) andOffTextColor:RGBACOLOR(191, 191, 191, 1) isOn:isAllTheSilence frame:CGRectMake(self.width - 60, (65 - 24) / 2, 44.f, 24.f)];
    }
    return _muteSwitch;
}

- (UIView*)anchorIdentity
{
    if (_anchorIdentity == nil) {
        _anchorIdentity = [[UIView alloc] initWithFrame:CGRectMake(self.width - 200, (65 - 15)/2, 45.f, 15.f)];
        _anchorIdentity.backgroundColor = [UIColor clearColor];
        _anchorIdentity.layer.cornerRadius = 7.5;
        [_anchorIdentity.layer addSublayer:self.livingGl];
        [_anchorIdentity addSubview:self.headImageView];
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@11.f);
            make.left.equalTo(_anchorIdentity.mas_left).offset(2.f);
            make.top.equalTo(_anchorIdentity.mas_top).offset(2.f);
        }];
        [_anchorIdentity addSubview:self.identityLabel];
        [self.identityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@24.f);
            make.height.equalTo(@15.f);
            make.left.equalTo(self.headImageView.mas_right).offset(4.f);
            make.top.equalTo(_anchorIdentity.mas_top);
        }];
    }
    return _anchorIdentity;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-living"]];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}

- (UILabel*)identityLabel
{
    if (_identityLabel == nil) {
        _identityLabel = [[UILabel alloc]init];
        _identityLabel.text = @"主播";
        _identityLabel.textColor = [UIColor whiteColor];
        _identityLabel.font = [UIFont systemFontOfSize:10.f];
    }
    return _identityLabel;
}

- (CAGradientLayer *)mutingGl{
    if(_mutingGl == nil){
        _mutingGl = [CAGradientLayer layer];
        _mutingGl.frame = CGRectMake(0,0,_mutingLabel.frame.size.width,_mutingLabel.frame.size.height);
        _mutingGl.startPoint = CGPointMake(0.76, 0.84);
        _mutingGl.endPoint = CGPointMake(0.26, 0.14);
        _mutingGl.colors = @[(__bridge id)[UIColor colorWithRed:208/255.0 green:90/255.0 blue:90/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:240/255.0 green:118/255.0 blue:4/255.0 alpha:1.0].CGColor];
        _mutingGl.locations = @[@(0), @(1.0f)];
        _mutingGl.cornerRadius = 7.5;
    }
    
    return _mutingGl;
}


- (CAGradientLayer *)livingGl{
    if(_livingGl == nil){
        _livingGl = [CAGradientLayer layer];
        _livingGl.frame = CGRectMake(0,0,_anchorIdentity.frame.size.width,_anchorIdentity.frame.size.height);
        _livingGl.startPoint = CGPointMake(0.76, 0.84);
        _livingGl.endPoint = CGPointMake(0.26, 0.14);
        _livingGl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor];
        _livingGl.locations = @[@(0), @(1.0f)];
        _livingGl.cornerRadius = 7.5;
    }
    
    return _livingGl;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView addSubview:self.muteSwitch];
    [self.contentView addSubview:self.clickButton];
    [self.contentView addSubview:self.anchorIdentity];
    [self.contentView addSubview:self.mutingLabel];
    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width=60.0f;
    self.textLabel.frame = textLabelFrame;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end

@interface EaseAdminView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    NSString* _chatroomId;
    EMChatroom *_chatroom;
    
    MJRefreshFooter *_refreshMemberFooter;
    NSInteger _memberPageNum;
    
    MJRefreshFooter *_refreshMuteFooter;
    NSInteger _mutePageNum;
    
    MJRefreshFooter *_refreshWhitelistFooter;
    NSInteger _blockPageNum;
    
    BOOL _isOwner;
}

@property (nonatomic, strong) UIView *adminView;

@property (nonatomic, strong) UIImageView *auidenceImg;
@property (nonatomic, strong) UIButton *adminListBtn;
@property (nonatomic, strong) UIButton *muteListBtn;
@property (nonatomic, strong) UIButton *whitelistBtn;
@property (nonatomic, strong) UIView *selectLine;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UITableView *adminTableView;
@property (nonatomic, strong) UITableView *muteTableView;
@property (nonatomic, strong) UITableView *whitelistTableView;

@property (nonatomic, strong) NSMutableArray *muteList;
@property (nonatomic, strong) NSMutableArray *whitelist;

@property (nonatomic, strong) NSMutableArray *memberList;
@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@end

extern BOOL isAllTheSilence;
@implementation EaseAdminView

- (instancetype)initWithChatroomId:(NSString*)chatroomId
                           isOwner:(BOOL)isOwner
{
    self = [super init];
    if (self) {
        _chatroomId = chatroomId;
        _isOwner = isOwner;
        _cursor = nil;
        [self addSubview:self.adminView];
        
        [self.adminView addSubview:self.adminListBtn];
        if (_isOwner) {
            [self.adminView addSubview:self.whitelistBtn];
            [self.adminView addSubview:self.muteListBtn];
        }
        [self.adminView addSubview:self.selectLine];
        [self.adminView addSubview:self.line];
        [self.adminView addSubview:self.mainScrollView];
        [self.mainScrollView addSubview:self.adminTableView];
        if (_isOwner) {
            [self.mainScrollView addSubview:self.muteTableView];
            [self.mainScrollView addSubview:self.whitelistTableView];
        }
    }
    return self;
}

#pragma mark - getter

- (UIView*)adminView
{
    if (_adminView == nil) {
         _adminView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 320.f, self.width, 320.f)];
        _adminView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _adminView;
}

- (UIImageView*)auidenceImg
{
    if (_auidenceImg == nil) {
        _auidenceImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 16, 18, 18)];
        _auidenceImg.image = [UIImage imageNamed:@"auidence"];
    }
    return _auidenceImg;
}

- (UIButton*)adminListBtn
{
    if (_adminListBtn == nil) {
        _adminListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _adminListBtn.frame = CGRectMake(0, 0, KScreenWidth/3, kButtonDefaultHeight);
        [_adminListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_adminListBtn setTitle:@"观众" forState:UIControlStateNormal];
        [_adminListBtn.titleLabel setFont:[UIFont fontWithName:@"Alibaba-PuHuiTi" size:15.f]];
        _adminListBtn.tag = 100;
        [_adminListBtn addSubview:self.auidenceImg];
        [_adminListBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminListBtn;
}

- (UIButton*)whitelistBtn
{
    if (_whitelistBtn == nil) {
        _whitelistBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _whitelistBtn.frame = CGRectMake(CGRectGetMaxX(_adminListBtn.frame), 0, KScreenWidth/3, kButtonDefaultHeight);
        //[_whitelistBtn setTitle:NSLocalizedString(@"profile.block", @"Block") forState:UIControlStateNormal];
        [_whitelistBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
        [_whitelistBtn setTitle:@"白名单" forState:UIControlStateNormal];
        [_whitelistBtn.titleLabel setFont:[UIFont fontWithName:@"Alibaba-PuHuiTi" size:15.f]];
        _whitelistBtn.tag = 101;
        [_whitelistBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _whitelistBtn;
}

- (UIButton*)muteListBtn
{
    if (_muteListBtn == nil) {
        _muteListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteListBtn.frame = CGRectMake(CGRectGetMaxX(_whitelistBtn.frame), 0, KScreenWidth/3, kButtonDefaultHeight);
        //[_muteListBtn setTitle:NSLocalizedString(@"profile.mute", @"Mute") forState:UIControlStateNormal];
        [_muteListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
        [_muteListBtn setTitle:@"观众禁言" forState:UIControlStateNormal];
        [_muteListBtn.titleLabel setFont:[UIFont fontWithName:@"Alibaba-PuHuiTi" size:15.f]];
        _muteListBtn.tag = 102;
        [_muteListBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteListBtn;
}

- (UIView*)selectLine
{
    if (_selectLine == nil) {
        _selectLine = [[UIView alloc] initWithFrame:CGRectMake(_adminListBtn.centerX - 50, CGRectGetMaxY(_adminListBtn.frame), 100.f, 2.f)];
        _selectLine.backgroundColor = RGBACOLOR(25, 163, 255, 1);
    }
    return _selectLine;
}

- (UIView*)line
{
    if (_line == nil) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_selectLine.frame), KScreenWidth, 1)];
        _line.backgroundColor = RGBACOLOR(222, 222, 222, 1);
    }
    return _line;
}

- (UIScrollView*)mainScrollView
{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_selectLine.frame), _adminView.width, _adminView.height - CGRectGetMaxY(_selectLine.frame))];
        _mainScrollView.contentSize = CGSizeMake(_mainScrollView.width*3, _mainScrollView.height);
        _mainScrollView.tag = 1000;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _mainScrollView;
}

- (UITableView*)adminTableView
{
    if (_adminTableView == nil) {
        _adminTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.mainScrollView.width, self.mainScrollView.height) style:UITableViewStylePlain];
        _adminTableView.dataSource = self;
        _adminTableView.delegate = self;
        _adminTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _adminTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _adminTableView.tableFooterView = [[UIView alloc] init];
        
        [self _loadMemberList:YES];
        
        _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_chatroomId error:nil];
        __weak EaseAdminView *weakSelf = self;
        _adminTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_chatroomId error:nil];
            [weakSelf _loadMemberList:YES];
            [weakSelf _tableViewDidFinishTriggerHeader:YES reload:YES tableView:_adminTableView];
        }];
        _adminTableView.mj_header.accessibilityIdentifier = @"refresh_admin_header";
        
        _adminTableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            [weakSelf _loadMemberList:NO];
            [weakSelf _tableViewDidFinishTriggerHeader:NO reload:YES tableView:_adminTableView];
        }];
        _adminTableView.mj_footer = nil;
        _adminTableView.mj_footer.accessibilityIdentifier = @"refresh_admin_footer";
    }
    return _adminTableView;
}

- (UITableView*)muteTableView
{
    if (_muteTableView == nil) {
        _muteTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.mainScrollView.width*2, 0, self.mainScrollView.width, self.mainScrollView.height) style:UITableViewStylePlain];
        _muteTableView.dataSource = self;
        _muteTableView.delegate = self;
        _muteTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _muteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _muteTableView.tableFooterView = [[UIView alloc] init];
        
        [self _loadMuteList:YES];
        
        __weak EaseAdminView *weakSelf = self;
        _muteTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _mutePageNum = 0;
            [weakSelf _loadMuteList:YES];
        }];
        
        _muteTableView.mj_header.accessibilityIdentifier = @"refresh_mute_header";
        
        _refreshMuteFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            _mutePageNum ++;
            [weakSelf _loadMuteList:NO];
        }];
        _muteTableView.mj_footer = nil;
        _muteTableView.mj_footer.accessibilityIdentifier = @"refresh_mute_footer";
    }
    return _muteTableView;
}

- (UITableView*)whitelistTableView
{
    if (_whitelistTableView == nil) {
        _whitelistTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.mainScrollView.width, 0, self.mainScrollView.width, self.mainScrollView.height) style:UITableViewStylePlain];
        _whitelistTableView.dataSource = self;
        _whitelistTableView.delegate = self;
        _whitelistTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _whitelistTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _whitelistTableView.tableFooterView = [[UIView alloc] init];
        
        [self _loadWhitelist:YES];
        
        __weak EaseAdminView *weakSelf = self;
        _whitelistTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf _loadWhitelist:YES];
        }];
        _whitelistTableView.mj_header.accessibilityIdentifier = @"refresh_block_header";
        
        _refreshWhitelistFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf _loadWhitelist:NO];
        }];
        
        _whitelistTableView.mj_footer = nil;
        _whitelistTableView.mj_footer.accessibilityIdentifier = @"refresh_block_footer";
    }
    return _whitelistTableView;
}

- (NSMutableArray*)memberList
{
    if (_memberList == nil) {
        _memberList = [[NSMutableArray alloc] init];
    }
    return _memberList;
}

- (NSMutableArray*)muteList
{
    if (_muteList == nil) {
        _muteList = [[NSMutableArray alloc] init];
    }
    return _muteList;
}

- (NSMutableArray*)whitelist
{
    if (_whitelist == nil) {
        _whitelist = [[NSMutableArray alloc] init];
    }
    return _whitelist;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (tableView == _adminTableView) {
        if (_chatroom) {
            return [_memberList count];
        }
        return 0;
    } else if (tableView == _muteTableView) {
        return [_muteList count];
    } else {
        return [_whitelist count];
    }
}

extern NSMutableDictionary*anchorInfoDic;
extern NSArray<NSString*> *nickNameArray;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:_chatroom.chatroomId];
    EaseAdminCell *cell;
    int random = (arc4random() % 100);
    NSString *username = nickNameArray[random];
    if (tableView == _adminTableView) {
        static NSString *CellIdentifierMember = @"audience";
        NSString *tempUsername = [_memberList objectAtIndex:indexPath.row];
        cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierMember];
        if (cell == nil) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMember];
        }
        if (indexPath.row == 0) {
            [cell.clickButton setTitle:@"房间禁言" forState:UIControlStateNormal];
            cell.muteSwitch.hidden = NO;
            cell.anchorIdentity.hidden = NO;
        } else {
            cell.anchorIdentity.hidden = YES;
        }
        cell.textLabel.text = username;
        if ([tempUsername isEqualToString:_chatroom.owner] && [tempUsername isEqualToString:EMClient.sharedClient.currentUsername]){
            cell.muteSwitch.hidden = NO;
            cell.clickButton.hidden = NO;
            cell.textLabel.text = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
        } else {
            cell.muteSwitch.hidden = YES;
            cell.clickButton.hidden = YES;
        }
        if ([tempUsername isEqualToString:EMClient.sharedClient.currentUsername]) {
            cell.textLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
        }
        __weak typeof(self) weakSelf = self;
        cell.muteSwitch.changeStateBlock = ^(BOOL isOn) {
            isAllTheSilence = isOn;
            [weakSelf allTheSilence:isAllTheSilence];
        };
        cell.mutingLabel.hidden = YES;
    } else if (tableView == _muteTableView) {
        static NSString *CellIdentifier = @"mute";
        cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        //username = [_muteList objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        [cell.clickButton setTitle:@"解禁" forState:UIControlStateNormal];
        [cell.clickButton addTarget:self action:@selector(removeMuteAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.anchorIdentity.hidden = YES;
        cell.muteSwitch.hidden = YES;
        cell.mutingLabel.hidden = NO;
    } else {
        static NSString *CellIdentifier = @"whitelist";
        cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        //username = [_whitelist objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        [cell.clickButton setTitle:@"删除" forState:UIControlStateNormal];
        [cell.clickButton addTarget:self action:@selector(removeWhitelistAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.muteSwitch.hidden = YES;
        cell.anchorIdentity.hidden = YES;
        cell.mutingLabel.hidden = YES;
    }
    
    random = (arc4random() % 7) + 1;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avatat_%d",random]];
    cell.clickButton.tag = indexPath.row;
   
    if (tableView == _adminTableView) {
        if ([username isEqualToString:_chatroom.owner]) {
            cell.imageView.image = [UIImage imageNamed:[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_AVATAR]];
            if ([username isEqualToString:EMClient.sharedClient.currentUsername]) {
                cell.imageView.image = [UIImage imageNamed:@"default_anchor_avatar"];
            }
        } else {
            if ([username isEqualToString:EMClient.sharedClient.currentUsername]) {
                cell.imageView.image = [UIImage imageNamed:@"default_anchor_avatar"];
            }
        }
        cell.clickButton.frame = CGRectMake(self.width - 120, (65 - 30)/2, 60, 30);
        [cell.clickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        cell.clickButton.frame = CGRectMake(self.width - 66, (65 - 20)/2, 30, 20);
        [cell.clickButton setTitleColor:RGBACOLOR(255, 199, 0, 1) forState:UIControlStateNormal];
    }
    CALayer *cellImageLayer = cell.imageView.layer;
    [cellImageLayer setCornerRadius:15];
    [cellImageLayer setMasksToBounds:YES];
    
    CGSize itemSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.textColor= [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1000)
    {
        NSInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
        index = index > 0 ? index : 0;
        [self _setSelectWithIndex:index];
    }
}

#pragma mark - action

- (void)selectAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSInteger index = btn.tag - 100;
    [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.width * index, 0) animated:YES];
    [self _setSelectWithIndex:index];
}

/*
- (void)removeAdminAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (_chatroom) {
        NSString *username = [_chatroom.adminList objectAtIndex:btn.tag];
        __weak EaseAdminView *weakSelf = self;
        MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@..." ,NSLocalizedString(@"profile.admin.remove", @"Remove")] toView:self];
        __weak MBProgressHUD *weakHud = hud;
        [[EMClient sharedClient].roomManager removeAdmin:username
                                            fromChatroom:_chatroomId
                                              completion:^(EMChatroom *aChatroom, EMError *aError) {
                                                  if (!aError) {
                                                      _chatroom = aChatroom;
                                                      [weakSelf _loadMemberList:YES];
                                                      [weakHud hide:YES afterDelay:0.5];
                                                  } else {
                                                      [weakHud setLabelText:aError.errorDescription];
                                                      [weakHud hide:YES afterDelay:0.5];
                                                  }
                                              }];
    }
}*/

//全体禁言

- (void)allTheSilence:(BOOL)isAllTheSilence
{
    if (isAllTheSilence) {
        [[EMClient sharedClient].roomManager muteAllMembersFromChatroom:_chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            if (!aError) {
                
            }
        }];
    } else {
        [[EMClient sharedClient].roomManager unmuteAllMembersFromChatroom:_chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            if (!aError) {
                
            }
        }];
    }
}

//解除禁言
- (void)removeMuteAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *username = [_muteList objectAtIndex:btn.tag];
    __weak EaseAdminView *weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@..." ,NSLocalizedString(@"profile.mute.cancel", @"Cancel")] toView:self];
    __weak MBProgressHUD *weakHud = hud;
    [[EMClient sharedClient].roomManager unmuteMembers:@[username]
                                          fromChatroom:_chatroomId
                                            completion:^(EMChatroom *aChatroom, EMError *aError) {
                                                if (!aError) {
                                                    [weakSelf.muteTableView beginUpdates];
                                                    [weakSelf.muteList removeObjectAtIndex:btn.tag];
                                                    [_muteListBtn setTitle:[NSString stringWithFormat:@"观众禁言(%lu)",(unsigned long)[weakSelf.muteList count]] forState:UIControlStateNormal];
                                                    [self.muteTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                                    [self.muteTableView endUpdates];
                                                    [weakHud hideAnimated:YES afterDelay:0.5];
                                                } else {
                                                    weakHud.label.text = aError.errorDescription;
                                                    [weakHud hideAnimated:YES afterDelay:0.5];
                                                }
                                            }];
}

//从白名单移除
- (void)removeWhitelistAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *username = [_whitelist objectAtIndex:btn.tag];
    __weak EaseAdminView *weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"从白名单移除"] toView:self];
    __weak MBProgressHUD *weakHud = hud;
    [[EMClient sharedClient].roomManager removeWhiteListMembers:@[username]
                                           fromChatroom:_chatroomId
                                             completion:^(EMChatroom *aChatroom, EMError *aError) {
                                                 if (!aError) {
                                                     [weakSelf.whitelistTableView beginUpdates];
                                                     [weakSelf.whitelist removeObjectAtIndex:btn.tag];
                                                     [_whitelistBtn setTitle:[NSString stringWithFormat:@"白名单(%lu)",(unsigned long)[weakSelf.whitelist count]] forState:UIControlStateNormal];
                                                     [self.whitelistTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.whitelistTableView endUpdates];
                                                     [weakHud hideAnimated:YES afterDelay:0.5];
                                                 } else {
                                                     weakHud.label.text = aError.errorDescription;
                                                     [weakHud hideAnimated:YES afterDelay:0.5];
                                                 }
                                             }];
}

#pragma mark - private

- (void)_setSelectWithIndex:(NSInteger)index
{
    UIButton *tagBtn = (UIButton*)[self viewWithTag:index + 100];
    if (!tagBtn || ![tagBtn isKindOfClass:[UIButton class]]) {
        return;
    }
    
    [_whitelistBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
    [_muteListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
    [_adminListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
    
    CGFloat pointX = _adminListBtn.centerX - 50;
    if (tagBtn.tag == 100) {
        [_adminListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else if (tagBtn.tag == 101) {
        pointX = _whitelistBtn.centerX - 50;
        [_whitelistBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else if (tagBtn.tag == 102) {
        pointX = _muteListBtn.centerX - 50;
        [_muteListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _selectLine.left = pointX;
    }];
}

#pragma mark - private

- (void)_tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload tableView:(UITableView*)tableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload) {
            [tableView reloadData];
        }
        
        if (isHeader) {
            if (tableView == self.adminTableView) {
                self.cursor = nil;
            }
            [tableView.mj_header endRefreshing];
        }
        else{
            [tableView.mj_footer endRefreshing];
        }
    });
}

//观众列表
- (void)_loadMemberList:(BOOL)isHeader
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:_chatroomId cursor:self.cursor pageSize:50 completion:^(EMCursorResult *aResult, EMError *aError) {
        if (!aError) {
           if (isHeader) {
               [weakself.memberList removeAllObjects];
               [weakself.memberList addObject:_chatroom.owner];
               [weakself.memberList addObjectsFromArray:_chatroom.adminList];
           }
           weakself.cursor = aResult.cursor;
           [weakself.memberList addObjectsFromArray:aResult.list];
            [_adminListBtn setTitle:[NSString stringWithFormat:@"观众(%lu)",(unsigned long)[weakself.memberList count]] forState:UIControlStateNormal];
           if ([aResult.list count] == 0 || [aResult.cursor length] == 0) {
               weakself.adminTableView.mj_footer = nil;
           } else {
               weakself.adminTableView.mj_footer = _refreshMemberFooter;
           }
           [weakself _tableViewDidFinishTriggerHeader:isHeader reload:YES tableView:_adminTableView];
        }
    }];
}

//禁言列表
- (void)_loadMuteList:(BOOL)isHeader
{
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager getChatroomMuteListFromServerWithId:_chatroomId
                                                                  pageNumber:_mutePageNum
                                                                    pageSize:kDefaultPageSize
                                                                  completion:^(NSArray *aList, EMError *aError) {
                                                                      if (!aError) {
                                                                          if (isHeader) {
                                                                              [weakSelf.muteList removeAllObjects];
                                                                          }
                                                                          [weakSelf.muteList addObjectsFromArray:aList];
                                                                          [_muteListBtn setTitle:[NSString stringWithFormat:@"观众禁言(%lu)",(unsigned long)[weakSelf.muteList count]] forState:UIControlStateNormal];
                                                                          if ([aList count] < kDefaultPageSize) {
                                                                              weakSelf.muteTableView.mj_footer = nil;
                                                                          } else {
                                                                              weakSelf.muteTableView.mj_footer = _refreshMuteFooter;
                                                                          }
                                                                      }
                                                                      [weakSelf _tableViewDidFinishTriggerHeader:isHeader reload:YES tableView:_muteTableView];
                                                                  }];
}

//白名单列表
- (void)_loadWhitelist:(BOOL)isHeader
{
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager getChatroomWhiteListFromServerWithId:_chatroomId completion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            if (isHeader) {
                [weakSelf.whitelist removeAllObjects];
            }
            [weakSelf.whitelist addObjectsFromArray:aList];
            [_whitelistBtn setTitle:[NSString stringWithFormat:@"白名单(%lu)",(unsigned long)[weakSelf.whitelist count]] forState:UIControlStateNormal];
            if ([aList count] < kDefaultPageSize) {
                weakSelf.whitelistTableView.mj_footer = nil;
            } else {
                weakSelf.whitelistTableView.mj_footer = _refreshWhitelistFooter;
            }
        }
        [weakSelf _tableViewDidFinishTriggerHeader:isHeader reload:YES tableView:_whitelistTableView];
    }];
}

@end
