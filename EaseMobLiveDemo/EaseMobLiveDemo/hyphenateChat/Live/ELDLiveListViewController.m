//
//  ALSLiveListViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/28.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDLiveListViewController.h"
#import "EaseLiveCollectionViewCell.h"
#import "EaseLiveViewController.h"
#import "SRRefreshView.h"
#import "MJRefresh.h"
#import "EaseHttpManager.h"
#import "EaseLiveRoom.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "ELDNoDataPlaceHolderView.h"
#import "ELDHintGoLiveView.h"

#define kCollectionCellDefaultHeight 150
#define kDefaultPageSize 8
#define kCollectionIdentifier @"collectionCell"

#import "ELDPublishLiveViewController.h"

@interface ELDLiveListViewController () <UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SRRefreshDelegate,EMClientDelegate>
{
    NSString *_videoType;
    
    NSString *_cursor;
    BOOL _noMore;
    BOOL _isLoading;
    
    MJRefreshHeader *_refreshHeader;
    MJRefreshFooter *_refreshFooter;
}

@property (nonatomic, strong) ELDNoDataPlaceHolderView *noDataPromptView;
@property (nonatomic, strong) ELDHintGoLiveView *hintGoLiveView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic) kTabbarItemBehavior tabBarBehavior; //tabbar行为：看直播/开播


@end

@implementation ELDLiveListViewController

- (instancetype)initWithBehavior:(kTabbarItemBehavior)tabBarBehavior video_type:(NSString *)video_type
{
    self = [super init];
       if (self) {
           _videoType = video_type;
           _tabBarBehavior = tabBarBehavior;
           
           [[EMClient sharedClient] removeDelegate:self];
           [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
           
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:kNotificationRefreshList object:nil];

           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChangedNotify:) name:ELDloginStateChange object:nil];
       }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = ViewControllerBgBlackColor;
        
    [self setupCollectionView];
    
    [self setRefreshHeaderAndFooter];
 
    [self loadData:YES];
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
    EASELIVEDEMO_REMOVENOTIFY(self);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark private method

- (void)loadData:(BOOL)isHeader
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    
    ELD_WS
    if (self.tabBarBehavior == kTabbarItemTag_Live) {
        if (isHeader) {
            //获取vod点播房间列表
            if ([_videoType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
                [[EaseHttpManager sharedInstance] fetchVodRoomWithCursor:0 limit:10 video_type:_videoType completion:^(EMCursorResult *result, BOOL success) {
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


//- (void)loadData:(BOOL)isHeader
//{
//    if (_isLoading) {
//        return;
//    }
//    _isLoading = YES;
//
//    ELD_WS
//    if (self.tabBarBehavior == kTabbarItemTag_Live) {
//        if (isHeader) {
//            //获取vod点播房间列表
//            if ([_videoType isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
//                [[EaseHttpManager sharedInstance] fetchVodRoomWithCursor:0 limit:2 video_type:kLiveBroadCastingTypeAgoraVOD completion:^(EMCursorResult *result, BOOL success) {
//                        [weakSelf getOngoingLiveroom:YES vodList:result.list];
//                }];
//            }
////            //获取agora_vod点播房间列表
////            if ([_videoType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
////                [[EaseHttpManager sharedInstance] fetchVodRoomWithCursor:0 limit:2 video_type:kLiveBroadCastingTypeAgoraVOD completion:^(EMCursorResult *result, BOOL success) {
////                        [weakSelf getOngoingLiveroom:YES vodList:result.list];
////                }];
////            }
////            if ([_videoType isEqualToString:kLiveBroadCastingTypeAGORA_INTERACTION_LIVE]) {
////                [EaseHttpManager.sharedInstance fetchVodRoomWithCursor:0 limit:2 video_type:kLiveBroadCastingTypeAgoraInteractionVOD completion:^(EMCursorResult *result, BOOL success) {
////                    [weakSelf getOngoingLiveroom:YES vodList:result.list];
////                }];
////            }
//        } else {
//            [self getOngoingLiveroom:NO vodList:nil];
//        }
//    } else if (self.tabBarBehavior == kTabbarItemTag_Broadcast) {
//        [[EaseHttpManager sharedInstance] fetchLiveRoomsWithCursor:_cursor limit:8 completion:^(EMCursorResult *result, BOOL success) {
//            if (success) {
//                if (isHeader) {
//                    [weakSelf.dataArray removeAllObjects];
//                    [weakSelf.dataArray addObjectsFromArray:result.list];
//                } else {
//                    [weakSelf.dataArray addObjectsFromArray:result.list];
//                }
//                _cursor = result.cursor;
//
//                if ([result.list count] < kDefaultPageSize) {
//                    _noMore = YES;
//                }
//                if (_noMore) {
//                    weakSelf.collectionView.mj_footer = nil;
//                } else {
//                    weakSelf.collectionView.mj_footer = _refreshFooter;
//                }
//            }
//
//            [weakSelf _collectionViewDidFinishTriggerHeader:isHeader reload:YES];
//            _isLoading = NO;
//        }];
//    }
//}

- (void)getOngoingLiveroom:(BOOL)isHeader vodList:(NSArray*)vodList
{
    ELD_WS
    //获取正在直播的直播间列表
    [[EaseHttpManager sharedInstance] fetchLiveRoomsOngoingWithCursor:_cursor limit:8 video_type:_videoType
                                          completion:^(EMCursorResult *result, BOOL success) {
          if (success) {
              if (isHeader) {
                  [weakSelf.dataArray removeAllObjects];
                  NSMutableDictionary* dic = [NSMutableDictionary dictionary];
                  for (EaseLiveRoom* room in vodList) {
                      if (room.roomId.length > 0) {
                          [dic setObject:room forKey:room.roomId];
                      }
                  }
                  [weakSelf.dataArray addObjectsFromArray:vodList];
                  for (EaseLiveRoom* room in result.list) {
                      if (room.roomId.length > 0 && ![dic objectForKey:room.roomId]) {
                          [weakSelf.dataArray addObject:room];
                      }
                  }
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
    [self.view setBackgroundColor:ViewControllerBgBlackColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.noDataPromptView];
    [self.view addSubview:self.hintGoLiveView];
    
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-kEaseLiveDemoPadding*4);
        make.centerX.left.right.equalTo(self.view);
    }];
    
    [self.hintGoLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-kEaseLiveDemoPadding*3);
        make.centerX.left.right.equalTo(self.view);
    }];
    
}

- (void)setRefreshHeaderAndFooter {
    ELD_WS
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


#pragma mark Notification
- (void)loginStateChangedNotify:(NSNotification *)notify {
    [self loadData:YES];
}

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


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveRoom *room = [self.dataArray objectAtIndex:indexPath.row];
    if (self.tabBarBehavior == kTabbarItemTag_Live) {
        
        ELD_WS
        [[EaseHttpManager sharedInstance] fetchLiveroomDetail:room.roomId completion:^(EaseLiveRoom *room, BOOL success) {
            if (!success) {
                [weakSelf showHint:NSLocalizedString(@"live.fetchDetail.failed", nil)];
                return;
            }
            
            if (room.status == ongoing && [room.anchor isEqualToString:EMClient.sharedClient.currentUsername]) {
                if (weakSelf.selfLiveRoomSelectedBlock) {
                    weakSelf.selfLiveRoomSelectedBlock(room);
                }
                
            } else {
                
                if (weakSelf.liveRoomSelectedBlock) {
                    weakSelf.liveRoomSelectedBlock(room);
                }
            }
        }];
    } else if (self.tabBarBehavior == kTabbarItemTag_Broadcast) {
        __weak typeof(self) weakSelf = self;
        room.anchor = [EMClient sharedClient].currentUsername;
        [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:room completion:^(EaseLiveRoom *room, BOOL success) {
            if (success) {
                ELDPublishLiveViewController *publishView = [[ELDPublishLiveViewController alloc] initWithLiveRoom:room];
                publishView.modalPresentationStyle = 0;
                [weakSelf presentViewController:publishView
                                       animated:YES
                                     completion:^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                                     }];
            } else {
                UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"hint" message:@"The current room is live！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *conform = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                [alertControler addAction:conform];
                [weakSelf presentViewController:alertControler animated:YES completion:nil];
            }
        }];
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

#pragma mark - private
- (void)_collectionViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    ELD_WS
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload) {
            
            [weakSelf.collectionView reloadData];
            weakSelf.noDataPromptView.hidden = weakSelf.dataArray.count > 0 ? YES : NO;
            weakSelf.hintGoLiveView.hidden = weakSelf.dataArray.count > 0 ? YES : NO;
        }
        
        if (isHeader) {
            [_refreshHeader endRefreshing];
        }
        else{
            [_refreshFooter endRefreshing];
        }
    });
}

#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:self.collectionViewLayout];
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

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat itemWidth = (KScreenWidth - 16.0 *2 - 4.0) * 0.5;
    CGFloat itemHeight = itemWidth;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayout.minimumLineSpacing = 4.0;
    flowLayout.minimumInteritemSpacing = 4.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 16.0, 0, 16.0);
    
    return flowLayout;
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

- (ELDNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = ELDNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:ImageWithName(@"livelist_placeHolder")];
        _noDataPromptView.prompt.text = @"No Streamer Live now";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

- (ELDHintGoLiveView *)hintGoLiveView {
    if (_hintGoLiveView == nil) {
        _hintGoLiveView = ELDHintGoLiveView.new;
        _hintGoLiveView.hidden = YES;
    }
    return _hintGoLiveView;
}
@end


