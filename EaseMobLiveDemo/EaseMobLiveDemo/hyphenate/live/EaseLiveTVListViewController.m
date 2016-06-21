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

@interface EaseLiveTVListViewController () <UICollectionViewDelegate,UICollectionViewDataSource,SRRefreshDelegate,EaseSelectHeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) SRRefreshView *slimeView;

@property (nonatomic, strong) EaseSelectHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation EaseLiveTVListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"广场";
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    [self setupCollectionView];
    [self loadData];
    [self.collectionView addSubview:self.slimeView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.collectionView setContentOffset:CGPointMake(0, -64) animated:YES];
}

- (void)loadData
{
    __weak EaseLiveTVListViewController *weakSelf = self;
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
    }];
}

- (void)setupCollectionView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(self.headerView.frame) - 49.f) collectionViewLayout:flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.collectionView registerClass:[EaseLiveCollectionViewCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.pagingEnabled = NO;
    self.collectionView.userInteractionEnabled = YES;
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.collectionView];
}

- (EaseSelectHeaderView*)headerView
{
    if (_headerView == nil) {
        _headerView = [[EaseSelectHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 35)];
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
    return CGSizeMake(CGRectGetWidth(self.view.frame)/2, CGRectGetWidth(self.view.frame)/2);
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
    
}

@end
