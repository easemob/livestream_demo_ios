//
//  EaseLiveTVListViewController.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#define kCollectionCellDefaultHeight 150
#define kDefaultPageSize 20
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

@interface EaseLiveTVListViewController () <UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SRRefreshDelegate,EMClientDelegate>
{
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
@property (nonatomic) kTabbarItemBehavior tabBarBehavior; //tabbar行为：看直播/开播/设置

@end

@implementation EaseLiveTVListViewController

- (instancetype)initWithBehavior:(kTabbarItemBehavior)tabBarBehavior
{
    self = [super init];
       if (self) {
           _tabBarBehavior = tabBarBehavior;
           if (_tabBarBehavior == kTabbarItemTag_Broadcast) {
               self.title = @"选择直播间开始直播";
           } else {
               self.title = nil;
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
    
    [self setup];
    
    if ([[EMClient sharedClient] isConnected]) {
        [self loadData:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:kNotificationRefreshList object:nil];
}

- (void)viewWillLayoutSubviews
{
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([[EMClient sharedClient] isConnected]) {
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

- (void)setup
{
    _cursor = @"";
}

- (void)loadData:(BOOL)isHeader
{
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    __weak EaseLiveTVListViewController *weakSelf = self;
    if (self.tabBarBehavior == kTabbarItemTag_Live) {
        [[EaseHttpManager sharedInstance] fetchLiveRoomsOngoingWithCursor:nil
                                                                       limit:8
                                                                  completion:^(EMCursorResult *result, BOOL success) {
                                                                      if (success) {
                                                                          if (isHeader) {
                                                                              [weakSelf.dataArray removeAllObjects];
                                                                              [weakSelf.dataArray addObjectsFromArray:result.list];
                                                                              [weakSelf.collectionView reloadData];
                                                                          } else {
                                                                              [weakSelf.dataArray addObjectsFromArray:result.list];
                                                                              [weakSelf.collectionView reloadData];
                                                                          }
                                                                          //_cursor = result.cursor;
                                                                          
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
    } else if (self.tabBarBehavior == kTabbarItemTag_Broadcast) {
        [[EaseHttpManager sharedInstance] fetchLiveRoomsWithCursor:nil limit:8 completion:^(EMCursorResult *result, BOOL success) {
            if (success) {
                if (isHeader) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf.dataArray addObjectsFromArray:result.list];
                    [weakSelf.collectionView reloadData];
                } else {
                    [weakSelf.dataArray addObjectsFromArray:result.list];
                    [weakSelf.collectionView reloadData];
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
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:room.coverPictureUrl];
    if (!image) {
        __weak typeof(self) weakSelf = self;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:room.coverPictureUrl]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:NULL
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                UIImage *backimage = nil;
                                                                if (image) {
                                                                    backimage = image;
                                                                } else {
                                                                    backimage = [UIImage imageNamed:@"default_back_image"];
                                                                }
                                                                [[SDImageCache sharedImageCache] storeImage:backimage forKey:room.coverPictureUrl toDisk:NO completion:^{
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        [weakSelf.collectionView reloadData];
                                                                    });
                                                                }];
                                                            }];
    }
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
    return CGSizeMake(CGRectGetWidth(self.view.frame)/2 - 1.5f, CGRectGetWidth(self.view.frame)/2 - 1.5f);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveRoom *room = [self.dataArray objectAtIndex:indexPath.row];
    UIViewController *view;
    if (self.tabBarBehavior == kTabbarItemTag_Live) {
        view = [[EaseLiveViewController alloc] initWithLiveRoom:room];
        view.modalPresentationStyle = 0;
        [self.navigationController presentViewController:view animated:YES completion:NULL];
    } else if (self.tabBarBehavior == kTabbarItemTag_Broadcast) {
        view = [[EaseCreateLiveViewController alloc]initWithLiveroom:room];
        [self.navigationController pushViewController:view animated:NO];
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
