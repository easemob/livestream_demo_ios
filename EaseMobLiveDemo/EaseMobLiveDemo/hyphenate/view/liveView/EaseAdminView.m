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
{
    BOOL _isAllthesilence;//全体禁言
}

@property (nonatomic, strong) UILabel *identityLabel;
@property (nonatomic, strong) UIButton *clickButton;
@property (nonatomic, strong) UIView *anchorIdentity;
@property (nonatomic, strong) CAGradientLayer *livingGl;
@property (nonatomic, strong) UIImageView *headImageView;
@property (strong, nonatomic) EaseCustomSwitch *muteSwitch;//房间禁言开关

@end

@implementation EaseAdminCell


- (UIButton*)clickButton
{
    if (_clickButton == nil) {
        _clickButton = [[UIButton alloc] init];
        _clickButton.frame = CGRectMake(self.width - 125, (65 - 30)/2, 60, 30);
        [_clickButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    return _clickButton;
}

- (EaseCustomSwitch*)muteSwitch
{
    if (_muteSwitch == nil) {
        _muteSwitch = [[EaseCustomSwitch alloc]initWithTextFont:[UIFont systemFontOfSize:12.f] OnText:@"" offText:@"" onBackGroundColor:RGBACOLOR(4, 174, 240, 1) offBackGroundColor:RGBACOLOR(191, 191, 191, 1) onButtonColor:RGBACOLOR(255, 255, 255, 1) offButtonColor:RGBACOLOR(255, 255, 255, 1) onTextColor:RGBACOLOR(4, 174, 240, 1) andOffTextColor:RGBACOLOR(191, 191, 191, 1)];
        _muteSwitch.frame = CGRectMake(self.width - 60, (65 - 24) / 2, 44.f, 24.f);
        _muteSwitch.changeStateBlock = ^(BOOL isOn) {
            _isAllthesilence = isOn;
        };
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
    self.contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width=150.0f;
    self.textLabel.frame = textLabelFrame;
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
    
    MJRefreshFooter *_refreshBlockFooter;
    NSInteger _blockPageNum;
    
    BOOL _isOwner;
}

@property (nonatomic, strong) UIView *adminView;

@property (nonatomic, strong) UIImageView *auidenceImg;
@property (nonatomic, strong) UIButton *adminListBtn;
@property (nonatomic, strong) UIButton *muteListBtn;
@property (nonatomic, strong) UIButton *blockListBtn;
@property (nonatomic, strong) UIView *selectLine;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UITableView *adminTableView;
@property (nonatomic, strong) UITableView *muteTableView;
@property (nonatomic, strong) UITableView *blockTableView;

@property (nonatomic, strong) NSMutableArray *muteList;
@property (nonatomic, strong) NSMutableArray *blockList;

@property (nonatomic, strong) NSMutableArray *memberList;
@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@end

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
            [self.adminView addSubview:self.muteListBtn];
            [self.adminView addSubview:self.blockListBtn];
        }
        [self.adminView addSubview:self.selectLine];
        [self.adminView addSubview:self.line];
        [self.adminView addSubview:self.mainScrollView];
        [self.mainScrollView addSubview:self.adminTableView];
        if (_isOwner) {
            [self.mainScrollView addSubview:self.muteTableView];
            [self.mainScrollView addSubview:self.blockTableView];
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
        [_adminListBtn.titleLabel setFont:[UIFont fontWithName:@"阿里巴巴普惠体-R" size:15.f]];
        _adminListBtn.tag = 100;
        [_adminListBtn addSubview:self.auidenceImg];
        [_adminListBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminListBtn;
}

- (UIButton*)muteListBtn
{
    if (_muteListBtn == nil) {
        _muteListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteListBtn.frame = CGRectMake(CGRectGetMaxX(_adminListBtn.frame), 0, KScreenWidth/3, kButtonDefaultHeight);
        //[_muteListBtn setTitle:NSLocalizedString(@"profile.mute", @"Mute") forState:UIControlStateNormal];
        [_muteListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
        [_muteListBtn setTitle:@"观众禁言" forState:UIControlStateNormal];
        [_muteListBtn.titleLabel setFont:[UIFont fontWithName:@"阿里巴巴普惠体-R" size:15.f]];
        _muteListBtn.tag = 101;
        [_muteListBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteListBtn;
}

- (UIButton*)blockListBtn
{
    if (_blockListBtn == nil) {
        _blockListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _blockListBtn.frame = CGRectMake(CGRectGetMaxX(_muteListBtn.frame), 0, KScreenWidth/3, kButtonDefaultHeight);
        //[_blockListBtn setTitle:NSLocalizedString(@"profile.block", @"Block") forState:UIControlStateNormal];
        [_blockListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
        [_blockListBtn setTitle:@"白名单" forState:UIControlStateNormal];
        [_blockListBtn.titleLabel setFont:[UIFont fontWithName:@"阿里巴巴普惠体-R" size:15.f]];
        _blockListBtn.tag = 102;
        [_blockListBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _blockListBtn;
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
        _muteTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.mainScrollView.width, 0, self.mainScrollView.width, self.mainScrollView.height) style:UITableViewStylePlain];
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

- (UITableView*)blockTableView
{
    if (_blockTableView == nil) {
        _blockTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.mainScrollView.width * 2, 0, self.mainScrollView.width, self.mainScrollView.height) style:UITableViewStylePlain];
        _blockTableView.dataSource = self;
        _blockTableView.delegate = self;
        _blockTableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _blockTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _blockTableView.tableFooterView = [[UIView alloc] init];
        
        [self _loadBlockList:YES];
        
        __weak EaseAdminView *weakSelf = self;
        _blockTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _blockPageNum = 0;
            [weakSelf _loadBlockList:YES];
        }];
        _blockTableView.mj_header.accessibilityIdentifier = @"refresh_block_header";
        
        _refreshBlockFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            _blockPageNum ++;
            [weakSelf _loadBlockList:NO];

        }];
        
        _blockTableView.mj_footer = nil;
        _blockTableView.mj_footer.accessibilityIdentifier = @"refresh_block_footer";
    }
    return _blockTableView;
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

- (NSMutableArray*)blockList
{
    if (_blockList == nil) {
        _blockList = [[NSMutableArray alloc] init];
    }
    return _blockList;
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
        return [_blockList count];
    }
}

extern NSMutableDictionary*anchorInfoDic;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:_chatroom.chatroomId];
    EaseAdminCell *cell;
    NSString *username = nil;
    if (tableView == _adminTableView) {
        static NSString *CellIdentifierAdmin = @"admin";
        static NSString *CellIdentifierMember = @"member";
        username = [_memberList objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAdmin];
            [cell.clickButton setTitle:@"房间禁言" forState:UIControlStateNormal];
            cell.anchorIdentity.hidden = YES;
            cell.muteSwitch.hidden = YES;
        } else if ([_chatroom.adminList containsObject:username]) {
            cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierAdmin];
            // Configure the cell...
            if (cell == nil) {
                cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierAdmin];
            }
            [cell.clickButton setTitle:NSLocalizedString(@"profile.admin.remove", @"Remove") forState:UIControlStateNormal];
            [cell.clickButton addTarget:self action:@selector(removeAdminAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierMember];
            // Configure the cell...
            if (cell == nil) {
                cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMember];
            }
        }
        
        cell.textLabel.text = username;
        if ([username isEqualToString:_chatroom.owner]){
            cell.anchorIdentity.hidden = NO;
            cell.muteSwitch.hidden = NO;
            cell.textLabel.text = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
        } else {
            cell.anchorIdentity.hidden = YES;
            cell.muteSwitch.hidden = YES;
        }
        if ([username isEqualToString:EMClient.sharedClient.currentUsername]) {
            cell.textLabel.text = EaseDefaultDataHelper.shared.defaultNickname;
        }
    } else if (tableView == _muteTableView) {
        static NSString *CellIdentifier = @"mute";
        cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        username = [_muteList objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        [cell.clickButton setTitle:NSLocalizedString(@"profile.mute.cancel", @"Cancel") forState:UIControlStateNormal];
        [cell.clickButton addTarget:self action:@selector(removeMuteAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.anchorIdentity.hidden = YES;
        cell.muteSwitch.hidden = YES;
    } else {
        static NSString *CellIdentifier = @"block";
        cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        username = [_blockList objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        [cell.clickButton setTitle:NSLocalizedString(@"profile.block.remove", @"Remove") forState:UIControlStateNormal];
        [cell.clickButton addTarget:self action:@selector(removeBlackAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.muteSwitch.hidden = YES;
        cell.anchorIdentity.hidden = YES;
    }
    
    int random = (arc4random() % 7) + 1;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"avatat_%d",random]];
    cell.clickButton.tag = indexPath.row;
   
    if (tableView == _adminTableView) {
        if ([username isEqualToString:_chatroom.owner]) {
            cell.imageView.image = [UIImage imageNamed:[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_AVATAR]];
            if ([username isEqualToString:EMClient.sharedClient.currentUsername]) {
                cell.imageView.image = [UIImage imageNamed:@"default_anchor_avatar"];
            }
            cell.clickButton.hidden = NO;
            cell.muteSwitch.hidden = NO;
            cell.anchorIdentity.hidden = NO;
        } else {
            if ([username isEqualToString:EMClient.sharedClient.currentUsername]) {
                cell.imageView.image = [UIImage imageNamed:@"default_anchor_avatar"];
            }
            cell.clickButton.hidden = YES;
            cell.muteSwitch.hidden = YES;
            cell.anchorIdentity.hidden = YES;
        }
    } else {
        BOOL ret = username.length > 0 && [username isEqualToString:[EMClient sharedClient].currentUsername];
        if (ret) {
            cell.clickButton.hidden = YES;
        } else {
            cell.clickButton.hidden = NO;
        }
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
}

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
                                                    [_muteListBtn setTitle:[NSString stringWithFormat:@"禁言(%lu)",(unsigned long)[weakSelf.muteList count]] forState:UIControlStateNormal];
                                                    [self.muteTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                                    [self.muteTableView endUpdates];
                                                    [weakHud hide:YES afterDelay:0.5];
                                                } else {
                                                    [weakHud setLabelText:aError.errorDescription];
                                                    [weakHud hide:YES afterDelay:0.5];
                                                }
                                            }];
}

- (void)removeBlackAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSString *username = [_blockList objectAtIndex:btn.tag];
    __weak EaseAdminView *weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessag:[NSString stringWithFormat:@"%@..." ,NSLocalizedString(@"profile.block.remove", @"Remove")] toView:self];
    __weak MBProgressHUD *weakHud = hud;
    [[EMClient sharedClient].roomManager unblockMembers:@[username]
                                           fromChatroom:_chatroomId
                                             completion:^(EMChatroom *aChatroom, EMError *aError) {
                                                 if (!aError) {
                                                     [weakSelf.blockTableView beginUpdates];
                                                     [weakSelf.blockList removeObjectAtIndex:btn.tag];
                                                     [_blockListBtn setTitle:[NSString stringWithFormat:@"白名单(%lu)",(unsigned long)[weakSelf.blockList count]] forState:UIControlStateNormal];
                                                     [self.blockTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                                     [self.blockTableView endUpdates];
                                                     [weakHud hide:YES afterDelay:0.5];
                                                 } else {
                                                     [weakHud setLabelText:aError.errorDescription];
                                                     [weakHud hide:YES afterDelay:0.5];
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
    
    [_blockListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
    [_muteListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
    [_adminListBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.59] forState:UIControlStateNormal];
    
    CGFloat pointX = _adminListBtn.centerX - 50;
    [_adminListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (tagBtn.tag == 101) {
        pointX = _muteListBtn.centerX - 50;
        [_muteListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else if (tagBtn.tag == 102) {
        pointX = _blockListBtn.centerX - 50;
        [_blockListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
                                                                          [_muteListBtn setTitle:[NSString stringWithFormat:@"禁言(%lu)",(unsigned long)[weakSelf.muteList count]] forState:UIControlStateNormal];
                                                                          if ([aList count] < kDefaultPageSize) {
                                                                              weakSelf.muteTableView.mj_footer = nil;
                                                                          } else {
                                                                              weakSelf.muteTableView.mj_footer = _refreshMuteFooter;
                                                                          }
                                                                      }
                                                                      [weakSelf _tableViewDidFinishTriggerHeader:isHeader reload:YES tableView:_muteTableView];
                                                                  }];
}

- (void)_loadBlockList:(BOOL)isHeader
{
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].roomManager getChatroomBlacklistFromServerWithId:_chatroomId
                                                                   pageNumber:_blockPageNum
                                                                     pageSize:kDefaultPageSize
                                                                   completion:^(NSArray *aList, EMError *aError) {
                                                                       if (!aError) {
                                                                           if (isHeader) {
                                                                               [weakSelf.blockList removeAllObjects];
                                                                           }
                                                                           [weakSelf.blockList addObjectsFromArray:aList];
                                                                           [_blockListBtn setTitle:[NSString stringWithFormat:@"白名单(%lu)",(unsigned long)[weakSelf.blockList count]] forState:UIControlStateNormal];
                                                                           if ([aList count] < kDefaultPageSize) {
                                                                               weakSelf.blockTableView.mj_footer = nil;
                                                                           } else {
                                                                               weakSelf.blockTableView.mj_footer = _refreshBlockFooter;
                                                                           }
                                                                       }
                                                                       
                                                                       [weakSelf _tableViewDidFinishTriggerHeader:isHeader reload:YES tableView:_blockTableView];
                                                                   }];
}

@end
