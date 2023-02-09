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
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

@interface EaseSearchDisplayController () <UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) kTabbarItemBehavior tabBarBehavior;
@property (nonatomic, strong) UILabel *prompt;

@end

@implementation EaseSearchDisplayController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout liveBehavior:(kTabbarItemBehavior)liveBehavior
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _tabBarBehavior = liveBehavior;
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
    self.view.backgroundColor = ViewControllerBgBlackColor;
//    self.navigationItem.hidesBackButton = YES;
    
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgWhiteColor];
    [self.navigationItem setTitleView:self.searchBar];
        
    self.navigationItem.leftBarButtonItem = [ELDUtil customBarButtonItemImage:@"back_icon_white" action:@selector(backAction) actionTarget:self];
    
    [self.searchBar becomeFirstResponder];
    
    [self.view addSubview:self.prompt];
    [self.prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
}


#pragma mark private method
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
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
    [cell setLiveRoom:room liveBehavior:self.tabBarBehavior];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:room.coverPictureUrl];
    if (!image) {
        __weak typeof(self) weakSelf = self;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:room.coverPictureUrl]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:NULL
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                if (image) {
                                                                    [[SDImageCache sharedImageCache] storeImage:image forKey:room.coverPictureUrl toDisk:NO completion:^{
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            [weakSelf.collectionView reloadData];
                                                                        });
                                                                    }];
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
    view.modalPresentationStyle = 0;
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
        
        ELD_WS
        [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.searchSource searchText:searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIWithResults:results searchText:searchBar.text];
            });
        }];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if (searchBar.text.length == 0) {
        [self.resultsSource removeAllObjects];
        [self.collectionView reloadData];
    } else {
        
        [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.searchSource searchText:searchBar.text collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIWithResults:results searchText:searchBar.text];
            });
            
        }];
    }
    
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    
}


- (void)updateUIWithResults:(NSArray *)results
                 searchText:(NSString *)searchText {
    if (results) {
        [self.resultsSource removeAllObjects];
        [self.resultsSource addObjectsFromArray:results];
        if (self.resultsSource.count > 0) {
            [self.collectionView reloadData];
            self.prompt.hidden = YES;

        }else {
            [self.collectionView reloadData];
            self.prompt.hidden = NO;
            self.prompt.text = [NSString stringWithFormat:NSLocalizedString(@"search.noresultfor", nil),searchText];

        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    self.prompt.hidden = YES;
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark getter and setter
- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kSearchBarHeight)];
        _searchBar.placeholder = NSLocalizedString(@"search.title", nil);
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundColor = UIColor.blackColor;
        [_searchBar setTintColor:UIColor.whiteColor];

        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(10, 0)];
        
        [_searchBar setImage:ImageWithName(@"searchBar_icon") forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
          if (searchField) {
                  if (@available(iOS 13.0, *)){
                      _searchBar.searchTextField.backgroundColor= COLOR_HEX(0x212226);
                  }else{
                      searchField.backgroundColor = COLOR_HEX(0x212226);
                  }

              searchField.layer.cornerRadius = 8.0f;
              searchField.layer.masksToBounds = YES;
              searchField.textColor = UIColor.whiteColor;
          }
        
    }
    return _searchBar;
}

#pragma mark - getter
- (UILabel *)prompt {
    if (_prompt == nil) {
        _prompt = UILabel.new;
        _prompt.textColor = COLOR_HEX(0xBDBDBD);
        _prompt.font = NFont(18.0);
        _prompt.textAlignment = NSTextAlignmentCenter;
        _prompt.hidden = YES;
    }
    return _prompt;
}


@end
