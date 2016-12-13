//
//  EaseLiveTVListViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#define kCollectionCellDefaultHeight 150

#define kCollectionIdentifier @"collectionCell"

#import "EaseLiveTVListViewController.h"
#import "EaseLiveCollectionViewCell.h"
#import "EasePublishModel.h"
#import "EaseLiveViewController.h"
#import "SRRefreshView.h"
#import "EaseSelectHeaderView.h"
#import "EaseParseManager.h"

@interface EaseLiveTVListViewController () <UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SRRefreshDelegate,EaseSelectHeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) EaseSelectHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *collectionHotView;
@property (nonatomic, strong) UICollectionView *collectionStarView;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@end

@implementation EaseLiveTVListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"home.tabbar.finder", @"Finder");
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    [self setupCollectionView];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadData
{
    __weak EaseLiveTVListViewController *weakSelf = self;/*
    [self showHudInView:self.view hint:@"加载播放列表"];
    [[EaseParseManager sharedInstance] fetchLiveListInBackgroundWithCompletion:^(NSArray *liveList, NSError *error) {
        [weakSelf hideHud];
        if (!error) {
            weakSelf.dataArray = [NSMutableArray arrayWithArray:liveList];
        } else {
            [weakSelf showHint:@"列表加载失败"];
            //为了演示
            weakSelf.dataArray = [NSMutableArray arrayWithArray:@[[[EasePublishModel alloc] initWithName:@"Test1" number:@"100人" headImageName:@"1" streamId:@"em_10001"],[[EasePublishModel alloc] initWithName:@"Test2" number:@"100人" headImageName:@"2" streamId:@"em_10001"],[[EasePublishModel alloc] initWithName:@"Test3" number:@"100人" headImageName:@"3" streamId:@"em_10001"],[[EasePublishModel alloc] initWithName:@"Test4" number:@"100人" headImageName:@"4" streamId:@"em_10001"],[[EasePublishModel alloc] initWithName:@"Test5" number:@"100人" headImageName:@"5" streamId:@"em_10001"],[[EasePublishModel alloc] initWithName:@"Test6" number:@"100人" headImageName:@"6" streamId:@"em_10001"]]];
        }
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionHotView reloadData];
        [weakSelf.collectionStarView reloadData];
    }];*/
    
    //为了演示
    weakSelf.dataArray = [NSMutableArray arrayWithArray:@[
                                                          [[EasePublishModel alloc] initWithName:@"Test1" number:@"100人" headImageName:@"1" streamId:@"em_100001" chatroomId:@"218746635482562996"],
                                                          [[EasePublishModel alloc] initWithName:@"Test2" number:@"100人" headImageName:@"2" streamId:@"em_100002" chatroomId:@"218747106892972464"],
                                                          [[EasePublishModel alloc] initWithName:@"Test3" number:@"100人" headImageName:@"3" streamId:@"em_100003" chatroomId:@"218747152489251244"],
                                                          [[EasePublishModel alloc] initWithName:@"Test4" number:@"100人" headImageName:@"4" streamId:@"em_100004" chatroomId:@"218747179836113332"],
                                                          [[EasePublishModel alloc] initWithName:@"Test5" number:@"100人" headImageName:@"5" streamId:@"em_100005" chatroomId:@"218747226120257964"],
                                                          [[EasePublishModel alloc] initWithName:@"Test6" number:@"100人" headImageName:@"6" streamId:@"em_100006" chatroomId:@"218747262707171768"]]];
    [weakSelf.collectionView reloadData];
    [weakSelf.collectionHotView reloadData];
    [weakSelf.collectionStarView reloadData];
}

- (void)setupCollectionView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.collectionView];
    [self.mainScrollView addSubview:self.collectionHotView];
    [self.mainScrollView addSubview:self.collectionStarView];
}

#pragma mark - getter

- (UIScrollView*)mainScrollView
{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetHeight(self.headerView.frame) - 49.f)];
        [_mainScrollView setContentSize:CGSizeMake(self.view.bounds.size.width*3, 0)];
        _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        _mainScrollView.tag = 1000;
        
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
    }
    
    return _mainScrollView;
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, CGRectGetHeight(self.mainScrollView.frame)) collectionViewLayout:flowLayout];
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
        
        [_collectionView addSubview:self.slimeView];
    }
    return _collectionView;
}

- (UICollectionView*)collectionHotView
{
    if (_collectionHotView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionHotView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, CGRectGetHeight(self.mainScrollView.frame)) collectionViewLayout:flowLayout];
        _collectionHotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionHotView registerClass:[EaseLiveCollectionViewCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
        [_collectionHotView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionHotView.backgroundColor = [UIColor clearColor];
        _collectionHotView.delegate = self;
        _collectionHotView.dataSource = self;
        _collectionHotView.showsVerticalScrollIndicator = NO;
        _collectionHotView.showsHorizontalScrollIndicator = NO;
        _collectionHotView.alwaysBounceVertical = YES;
        _collectionHotView.pagingEnabled = NO;
        _collectionHotView.userInteractionEnabled = YES;
    }
    return _collectionHotView;
}

- (UICollectionView*)collectionStarView
{
    if (_collectionStarView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionStarView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 2, 0, self.view.bounds.size.width, CGRectGetHeight(self.mainScrollView.frame)) collectionViewLayout:flowLayout];
        _collectionStarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionStarView registerClass:[EaseLiveCollectionViewCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
        [_collectionStarView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionStarView.backgroundColor = [UIColor clearColor];
        _collectionStarView.delegate = self;
        _collectionStarView.dataSource = self;
        _collectionStarView.showsVerticalScrollIndicator = NO;
        _collectionStarView.showsHorizontalScrollIndicator = NO;
        _collectionStarView.alwaysBounceVertical = YES;
        _collectionStarView.pagingEnabled = NO;
        _collectionStarView.userInteractionEnabled = YES;
    }
    return _collectionStarView;
}

- (EaseSelectHeaderView*)headerView
{
    if (_headerView == nil) {
        _headerView = [[EaseSelectHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 48.f)];
        _headerView.delegate = self;
    }
    return _headerView;
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
    [cell setModel:[self.dataArray objectAtIndex:indexPath.row]];
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
    return CGSizeMake(CGRectGetWidth(self.view.frame)/2, 300.f);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EasePublishModel *model = [self.dataArray objectAtIndex:indexPath.row];
    EaseLiveViewController *view = [[EaseLiveViewController alloc] initWithStreamModel:model];
    [self.navigationController presentViewController:view animated:YES completion:NULL];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1000)
    {
        NSInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
        index = index > 0 ? index : 0;
        NSLog(@"%f-----%@",scrollView.contentOffset.x,@(index));
        [_headerView setSelectWithIndex:index];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [_slimeView endRefresh];
    [self loadData];
}

#pragma mark - EaseSelectHeaderViewDelegate

- (void)didSelectButtonWithIndex:(NSInteger)index
{
    [self.mainScrollView setContentOffset:CGPointMake(index * CGRectGetWidth(self.view.frame), 0) animated:YES];
}

@end
