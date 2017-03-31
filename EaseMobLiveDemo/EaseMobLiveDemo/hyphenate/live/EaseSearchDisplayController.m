//
//  EaseSearchDisplayController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/22.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSearchDisplayController.h"

#import "EaseLiveCollectionViewCell.h"
#import "EaseLiveViewController.h"
#import "RealtimeSearchUtil.h"

@interface EaseSearchDisplayController () <UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation EaseSearchDisplayController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _resultsSource = [[NSMutableArray alloc] init];
        _searchSource = [[NSMutableArray alloc] init];
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.collectionView registerClass:[EaseLiveCollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.alwaysBounceVertical = YES;
        self.collectionView.pagingEnabled = NO;
        self.collectionView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setTitleView:self.searchBar];
    
    [self.searchBar becomeFirstResponder];
}

- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.showsCancelButton = YES;
        _searchBar.placeholder = NSLocalizedString(@"search.placeholder", @"Input Room ID");
        _searchBar.delegate = self;
        _searchBar.searchBarStyle = UISearchBarStyleDefault;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
        _searchBar.tintColor = [UIColor whiteColor];
    }
    return _searchBar;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.resultsSource count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    EaseLiveRoom *room = [self.resultsSource objectAtIndex:indexPath.row];
    [cell setLiveRoom:room];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:room.coverPictureUrl];
    if (!image) {
        __weak typeof(self) weakSelf = self;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:room.coverPictureUrl]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:NULL
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                if (image) {
                                                                    [[SDImageCache sharedImageCache] storeImage:image forKey:room.coverPictureUrl toDisk:NO];
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        [weakSelf.collectionView reloadData];
                                                                    });
                                                                }
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
    return CGSizeMake(CGRectGetWidth(self.view.frame)/2 - 0.5f, CGRectGetWidth(self.view.frame)/2 - 0.5f);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    EaseLiveRoom *room = [self.resultsSource objectAtIndex:indexPath.row];
    EaseLiveViewController *view = [[EaseLiveViewController alloc] initWithLiveRoom:room];
    [self.navigationController presentViewController:view animated:YES completion:NULL];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        [self.resultsSource removeAllObjects];
        [self.collectionView reloadData];
    } else {
//        __weak typeof(self) weakSelf = self;
//        [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.searchSource searchText:searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
//            if (results) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.resultsSource removeAllObjects];
//                    [weakSelf.resultsSource addObjectsFromArray:results];
//                    [weakSelf.collectionView reloadData];
//                });
//            }
//        }];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] getLiveRoomWithRoomId:searchBar.text
                                                 completion:^(EaseLiveRoom *room, BOOL success) {
                                                     if (success) {
                                                         [weakSelf.resultsSource removeAllObjects];
                                                         if (room.chatroomId.length > 0) {
                                                             [[EaseHttpManager sharedInstance] getLiveRoomCurrentWithRoomId:searchBar.text
                                                                                                                 completion:^(EaseLiveSession *session, BOOL success) {
                                                                                                                     if (success) {
                                                                                                                         room.session.currentUserCount = session.currentUserCount;
                                                                                                                     }
                                                                                                                     [weakSelf.resultsSource addObject:room];
                                                                                                                     [weakSelf.collectionView reloadData];
                                                                                                                 }];
                                                             
                                                         } else {
                                                             [weakSelf.collectionView reloadData];
                                                         }
                                                     } else {
                                                         [weakSelf.resultsSource removeAllObjects];
                                                         [weakSelf.collectionView reloadData];
                                                     }
                                                 }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
