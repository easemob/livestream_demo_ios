//
//  EaseLiveTVListViewController.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#define kCollectionCellDefaultHeight 150
#define kDefaultPageSize 8
#define kCollectionIdentifier @"collectionCell"

#import "EaseLiveTVListViewController.h"
#import "EaseLiveCollectionViewCell.h"
#import "EaseLiveViewController.h"
#import "SRRefreshView.h"
#import "EaseCreateLiveViewController.h"
#import "MJRefresh.h"
#import "EaseHttpManager.h"
#import "EaseLiveRoom.h"
#import "EaseSearchDisplayController.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "EasePublishViewController.h"

@interface EaseLiveTVListViewController () <UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SRRefreshDelegate,EMClientDelegate>
{
    NSString *_videoType;
    
    NSString *_cursor;
    BOOL _noMore;
    BOOL _isLoading;
    
    MJRefreshHeader *_refreshHeader;
    MJRefreshFooter *_refreshFooter;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *liveButton;
@property (nonatomic) kTabbarItemBehavior tabBarBehavior; //tabbar行为：看直播/开播

@end

@implementation EaseLiveTVListViewController

- (instancetype)initWithBehavior:(kTabbarItemBehavior)tabBarBehavior video_type:(NSString *)video_type
{
    self = [super init];
       if (self) {
           _videoType = video_type;
           _tabBarBehavior = tabBarBehavior;
           if ([_videoType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE])
               self.title = @"极速直播";
           if ([_videoType isEqualToString:kLiveBroadCastingTypeLIVE])
               self.title = @"传统直播";
           if ([_videoType isEqualToString:kLiveBroadCastingTypeAGORA_INTERACTION_LIVE]) {
               self.title = @"互动直播";
           }
       }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView];
    
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:kNotificationRefreshList object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[EMClient sharedClient] isConnected]) {
        _cursor = @"";
        _noMore = NO;
        [self loadData:YES];
    }
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)loadData:(BOOL)isHeader
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    __weak EaseLiveTVListViewController *weakSelf = self;
    if (self.tabBarBehavior == kTabbarItemTag_Live) {
        if (isHeader) {
            //获取vod点播房间列表
            if ([_videoType isEqualToString:kLiveBroadCastingTypeLIVE]) {
                [[EaseHttpManager sharedInstance] fetchVodRoomWithCursor:0 limit:2 video_type:kLiveBroadCastingTypeAgoraVOD completion:^(EMCursorResult *result, BOOL success) {
                        [weakSelf getOngoingLiveroom:YES vodList:result.list];
                }];
            }
            //获取agora_vod点播房间列表
            if ([_videoType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                [[EaseHttpManager sharedInstance] fetchVodRoomWithCursor:0 limit:2 video_type:kLiveBroadCastingTypeAgoraVOD completion:^(EMCursorResult *result, BOOL success) {
                        [weakSelf getOngoingLiveroom:YES vodList:result.list];
                }];
            }
            if ([_videoType isEqualToString:kLiveBroadCastingTypeAGORA_INTERACTION_LIVE]) {
                [EaseHttpManager.sharedInstance fetchVodRoomWithCursor:0 limit:2 video_type:kLiveBroadCastingTypeAgoraInteractionVOD completion:^(EMCursorResult *result, BOOL success) {
                    [weakSelf getOngoingLiveroom:YES vodList:result.list];
                }];
            }
        } else {
            [self getOngoingLiveroom:NO vodList:nil];
        }
    } else if (self.tabBarBehavior == kTabbarItemTag_Broadcast) {
        [[EaseHttpManager sharedInstance] fetchLiveRoomsWithCursor:_cursor limit:8 completion:^(EMCursorResult *result, BOOL success) {
            if (success) {
                if (isHeader) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf.dataArray addObjectsFromArray:result.list];
                } else {
                    [weakSelf.dataArray addObjectsFromArray:result.list];
                }
                _cursor = result.cursor;
                
                if ([result.list count] < kDefaultPageSize) {
                    _noMore = YES;
                }
                if (_noMore) {
                    weakSelf.collectionView.mj_footer = nil;
                } else {
                    weakSelf.collectionView.mj_footer = _refreshFooter;
                }
            }
            
            [weakSelf _collectionViewDidFinishTriggerHeader:isHeader reload:YES];
            _isLoading = NO;
        }];
    }
}

- (void)getOngoingLiveroom:(BOOL)isHeader vodList:(NSArray*)vodList
{
    __weak EaseLiveTVListViewController *weakSelf = self;
    //获取正在直播的直播间列表
    [[EaseHttpManager sharedInstance] fetchLiveRoomsOngoingWithCursor:_cursor limit:8 video_type:_videoType
                                          completion:^(EMCursorResult *result, BOOL success) {
          if (success) {
              if (isHeader) {
                  [weakSelf.dataArray removeAllObjects];
                  [weakSelf.dataArray addObjectsFromArray:vodList];
                  [weakSelf.dataArray addObjectsFromArray:result.list];
              } else {
                  [weakSelf.dataArray addObjectsFromArray:result.list];
              }
              _cursor = result.cursor;
              if ([result.list count] < kDefaultPageSize ) {
                  _noMore = YES;
              }
              if (_noMore) {
                  weakSelf.collectionView.mj_footer = nil;
              } else {
                  weakSelf.collectionView.mj_footer = _refreshFooter;
              }
          }
          
          [weakSelf _collectionViewDidFinishTriggerHeader:isHeader reload:YES];
          _isLoading = NO;
  }];
}

- (void)setupCollectionView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
    //[self.view addSubview:self.liveButton];
    
    __weak EaseLiveTVListViewController *weakSelf = self;
    _refreshHeader =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _noMore = NO;
        _cursor = @"";
        [weakSelf loadData:YES];
    }];
    self.collectionView.mj_header = _refreshHeader;
    self.collectionView.mj_header.accessibilityIdentifier = @"refresh_header";
    
    _refreshFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (!_noMore) {
            [weakSelf loadData:NO];
        } else {
            [weakSelf _collectionViewDidFinishTriggerHeader:NO reload:YES];
        }
    }];
    self.collectionView.mj_footer = nil;
    self.collectionView.mj_footer.accessibilityIdentifier = @"refresh_footer";
}

#pragma mark - getter

- (UIBarButtonItem*)searchBarItem
{
    if (_searchBarItem == nil) {
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(0, 0, 30.f, 30.f);
        [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
        _searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    }
    return _searchBarItem;
}

- (UIBarButtonItem*)logoutItem
{
    if (_logoutItem == nil) {
        UIButton *liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        liveButton.frame = CGRectMake(0, 0, 80.f, 44.f);
        [liveButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [liveButton setTitle:NSLocalizedString(@"button.logout", @"Log out") forState:UIControlStateNormal];
        [liveButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, -5, -55)];
        [liveButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        _logoutItem = [[UIBarButtonItem alloc] initWithCustomView:liveButton];
    }
    return _logoutItem;
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseLiveCollectionViewCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UIButton*)liveButton
{
    if (_liveButton == nil) {
        _liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _liveButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _liveButton.frame = CGRectMake(KScreenWidth - 75, KScreenHeight - 130, 60, 60);
        _liveButton.layer.cornerRadius = _liveButton.width/2;
        _liveButton.backgroundColor = kDefaultLoginButtonColor;
        [_liveButton setImage:[UIImage imageNamed:@"live"] forState:UIControlStateNormal];
        [_liveButton addTarget:self action:@selector(liveAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _liveButton;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionIdentifier forIndexPath:indexPath];
    EaseLiveRoom *room = [self.dataArray objectAtIndex:indexPath.row];
    [cell setLiveRoom:room liveBehavior:self.tabBarBehavior];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
        
    }
    if (kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        reusableview = footerview;
    }
    return reusableview;
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((CGRectGetWidth(self.view.frame) - 30.f) / 2, (CGRectGetWidth(self.view.frame) - 30.f) / 2);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
/*
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}*/

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveRoom *room = [self.dataArray objectAtIndex:indexPath.row];
    if (self.tabBarBehavior == kTabbarItemTag_Live) {
        
        
        __weak typeof(self) weakSelf = self;
        [[EaseHttpManager sharedInstance] fetchLiveroomDetail:room.roomId completion:^(EaseLiveRoom *room, BOOL success) {
            if (success && room.status == ongoing && [room.anchor isEqualToString:EMClient.sharedClient.currentUsername]) {
                EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:room];
                [publishView setFinishBroadcastCompletion:^(BOOL isFinish) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
                publishView.modalPresentationStyle = 0;
                [weakSelf presentViewController:publishView animated:YES completion:nil];
                return;
            } else {
                EaseLiveViewController *view = [[EaseLiveViewController alloc] initWithLiveRoom:room];
                view.modalPresentationStyle = 0;
                [view setChatroomUpdateCompletion:^(BOOL isUpdate, EaseLiveRoom *liveRoom) {
                    if (isUpdate) {
                        EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:liveRoom];
                        publishView.modalPresentationStyle = 0;
                        [weakSelf.navigationController presentViewController:publishView animated:YES completion:nil];
                    }
                }];
                [weakSelf.navigationController presentViewController:view animated:YES completion:nil];
            }
        }];
    } else if (self.tabBarBehavior == kTabbarItemTag_Broadcast) {
        //view = [[EaseCreateLiveViewController alloc]initWithLiveroom:room];
        __weak typeof(self) weakSelf = self;
        room.anchor = [EMClient sharedClient].currentUsername;
        [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:room completion:^(EaseLiveRoom *room, BOOL success) {
            if (success) {
                EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:room];
                publishView.modalPresentationStyle = 0;
                [weakSelf presentViewController:publishView
                                       animated:YES
                                     completion:^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                                     }];
            } else {
                UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前房间正在直播！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                [alertControler addAction:conform];
                [weakSelf presentViewController:alertControler animated:YES completion:nil];
            }
        }];
        //[self.navigationController pushViewController:view animated:NO];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_noMore && [self.dataArray count] - 1 == indexPath.row && !_isLoading) {
//        [self loadData:NO];
    }
}

#pragma mark - EMClientDelegate

- (void)autoLoginDidCompleteWithError:(EMError *)aError
{
    if (!aError) {
        [self loadData:YES];
    }
}

#pragma mark - action

- (void)liveAction
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    EaseCreateLiveViewController *createLiveView = [[EaseCreateLiveViewController alloc] init];
    [self.navigationController pushViewController:createLiveView animated:NO];
}

#pragma mark - action

- (void)searchAction
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    EaseSearchDisplayController *searchDisplay = [[EaseSearchDisplayController alloc] initWithCollectionViewLayout:flowLayout];
    searchDisplay.searchSource = [NSMutableArray arrayWithArray:self.dataArray];
    [self.navigationController pushViewController:searchDisplay animated:YES];
}

- (void)logoutAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"退出中..." toView:nil];
    [[EMClient sharedClient] logout:NO];
    [hud hideAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@NO];
}

#pragma mark - notification

- (void)refreshList:(NSNotification*)notify
{
    BOOL ret = YES;
    if (notify) {
        ret = [notify.object boolValue];
    }
    if (ret) {
        _noMore = NO;
        _cursor = @"";
    }
    [self loadData:ret];
}


#pragma mark - private

- (void)_collectionViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    __weak EaseLiveTVListViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload) {
            [weakSelf.collectionView reloadData];
        }
        
        if (isHeader) {
            [_refreshHeader endRefreshing];
        }
        else{
            [_refreshFooter endRefreshing];
        }
    });
}

@end
