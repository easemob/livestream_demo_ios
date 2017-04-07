//
//  EaseAdminView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/28.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseAdminView.h"

#import "MJRefresh.h"

#define kButtonDefaultHeight 50.f
#define kDefaultPageSize 10

@interface EaseAdminCell : UITableViewCell

@property (nonatomic, strong) UIButton *clickButton;

@end

@implementation EaseAdminCell

- (UIButton*)clickButton
{
    if (_clickButton == nil) {
        _clickButton = [[UIButton alloc] init];
        _clickButton.frame = CGRectMake(self.width - 90, (65 - 30)/2, 80, 30);
        [_clickButton setTitleColor:RGBACOLOR(255, 116, 49, 1) forState:UIControlStateNormal];
        _clickButton.layer.borderWidth = 1.f;
        _clickButton.layer.borderColor = RGBACOLOR(255, 116, 49, 1).CGColor;
        _clickButton.layer.cornerRadius = 4.f;
        [_clickButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    }
    return _clickButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.clickButton.left = self.width - 90;
    [self.contentView addSubview:self.clickButton];
}

@end

@interface EaseAdminView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    NSString* _chatroomId;
    EMChatroom *_chatroom;
    
    MJRefreshFooter *_refreshMuteFooter;
    NSInteger _mutePageNum;
    
    MJRefreshFooter *_refreshBlockFooter;
    NSInteger _blockPageNum;
    
    BOOL _isOwner;
}

@property (nonatomic, strong) UIView *adminView;

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
        [self addSubview:self.adminView];
        
        [self.adminView addSubview:self.adminListBtn];
        [self.adminView addSubview:self.muteListBtn];
        [self.adminView addSubview:self.blockListBtn];
        [self.adminView addSubview:self.selectLine];
        [self.adminView addSubview:self.line];
        [self.adminView addSubview:self.mainScrollView];
        [self.mainScrollView addSubview:self.adminTableView];
        [self.mainScrollView addSubview:self.muteTableView];
        [self.mainScrollView addSubview:self.blockTableView];
    }
    return self;
}

#pragma mark - getter

- (UIView*)adminView
{
    if (_adminView == nil) {
         _adminView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 320.f, self.width, 320.f)];
        _adminView.backgroundColor = [UIColor whiteColor];
    }
    return _adminView;
}

- (UIButton*)adminListBtn
{
    if (_adminListBtn == nil) {
        _adminListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _adminListBtn.frame = CGRectMake(0, 0, KScreenWidth/3, kButtonDefaultHeight);
        [_adminListBtn setTitle:NSLocalizedString(@"profile.admin", @"Admin") forState:UIControlStateNormal];
        [_adminListBtn setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
        _adminListBtn.tag = 100;
        [_adminListBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminListBtn;
}

- (UIButton*)muteListBtn
{
    if (_muteListBtn == nil) {
        _muteListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteListBtn.frame = CGRectMake(CGRectGetMaxX(_adminListBtn.frame), 0, KScreenWidth/3, kButtonDefaultHeight);
        [_muteListBtn setTitle:NSLocalizedString(@"profile.mute", @"Mute") forState:UIControlStateNormal];
        [_muteListBtn setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
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
        [_blockListBtn setTitle:NSLocalizedString(@"profile.block", @"Block") forState:UIControlStateNormal];
        [_blockListBtn setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
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
        _adminTableView.backgroundColor = [UIColor clearColor];
        _adminTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _adminTableView.tableFooterView = [[UIView alloc] init];
        
        _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_chatroomId error:nil];
        
        __weak EaseAdminView *weakSelf = self;
        _adminTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_chatroomId error:nil];
            [weakSelf _tableViewDidFinishTriggerHeader:YES reload:YES tableView:_adminTableView];
        }];
        _adminTableView.mj_header.accessibilityIdentifier = @"refresh_admin_header";
    }
    return _adminTableView;
}

- (UITableView*)muteTableView
{
    if (_muteTableView == nil) {
        _muteTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.mainScrollView.width, 0, self.mainScrollView.width, self.mainScrollView.height) style:UITableViewStylePlain];
        _muteTableView.dataSource = self;
        _muteTableView.delegate = self;
        _muteTableView.backgroundColor = [UIColor clearColor];
        _muteTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
        _blockTableView.backgroundColor = [UIColor clearColor];
        _blockTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
            return [_chatroom.adminList count];
        }
        return 0;
    } else if (tableView == _muteTableView) {
        return [_muteList count];
    } else {
        return [_blockList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseAdminCell *cell;
    NSString *username = nil;
    if (tableView == _adminTableView) {
        static NSString *CellIdentifier = @"admin";
        cell = (EaseAdminCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Configure the cell...
        if (cell == nil) {
            cell = [[EaseAdminCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        username = [_chatroom.adminList objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        [cell.clickButton setTitle:NSLocalizedString(@"profile.admin.remove", @"Remove") forState:UIControlStateNormal];
        [cell.clickButton addTarget:self action:@selector(removeAdminAction:) forControlEvents:UIControlEventTouchUpInside];
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
    }
    cell.imageView.image = [UIImage imageNamed:@"live_default_user"];
    cell.clickButton.tag = indexPath.row;
    if (tableView == _adminTableView) {
        if (_isOwner) {
            cell.clickButton.hidden = NO;
        } else {
            cell.clickButton.hidden = YES;
        }
    } else {
        BOOL ret = username.length > 0 && [username isEqualToString:[EMClient sharedClient].currentUsername];
        if (ret) {
            cell.clickButton.hidden = YES;
        } else {
            cell.clickButton.hidden = NO;
        }
    }
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
                                                      [weakSelf.adminTableView reloadData];
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
    
    CGFloat pointX = _adminListBtn.centerX - 50;
    if (tagBtn.tag == 101) {
        pointX = _muteListBtn.centerX - 50;
    } else if (tagBtn.tag == 102) {
        pointX = _blockListBtn.centerX - 50;
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
            [tableView.mj_header endRefreshing];
        }
        else{
            [tableView.mj_footer endRefreshing];
        }
    });
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
