//
//  EaseSearchViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSearchViewController.h"

#import "EaseSearchDisplayController.h"
#import "RealtimeSearchUtil.h"
#import "EasePublishModel.h"
#import "EaseLiveViewController.h"
#import "UIViewController+DismissKeyboard.h"
#import "EaseListCell.h"

@interface EaseSearchViewController () <UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) EaseSearchDisplayController *searchController;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation EaseSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar addSubview:self.searchBar];
//    self.navigationItem.titleView = self.searchBar;
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];  
    
    //测试数据
    self.dataSource = [NSMutableArray arrayWithArray:@[
                                                       [[EasePublishModel alloc] initWithName:@"Test1" number:@"100人" headImageName:@"1" streamId:@"em_100001" chatroomId:@"218746635482562996"],
                                                       [[EasePublishModel alloc] initWithName:@"Test2" number:@"100人" headImageName:@"2" streamId:@"em_100002" chatroomId:@"218747106892972464"],
                                                       [[EasePublishModel alloc] initWithName:@"Test3" number:@"100人" headImageName:@"3" streamId:@"em_100003" chatroomId:@"218747152489251244"],
                                                       [[EasePublishModel alloc] initWithName:@"Test4" number:@"100人" headImageName:@"4" streamId:@"em_100004" chatroomId:@"218747179836113332"],
                                                       [[EasePublishModel alloc] initWithName:@"Test5" number:@"100人" headImageName:@"5" streamId:@"em_100005" chatroomId:@"218747226120257964"],
                                                       [[EasePublishModel alloc] initWithName:@"Test6" number:@"100人" headImageName:@"6" streamId:@"em_100006" chatroomId:@"218747262707171768"]]];
    
    [self setupSearchBar];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [self setupForDismissKeyboard];
}

- (void)dealloc
{
    _searchBar.delegate = nil;
    _searchController.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_searchBar resignFirstResponder];
}

#pragma mark - getter

- (NSMutableArray*)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)setupSearchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60.f, 0, KScreenWidth - 60.f, 44)];
        _searchBar.delegate = self;
        _searchBar.searchBarStyle = UISearchBarStyleDefault;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
        _searchBar.showsCancelButton = NO;
        _searchBar.tintColor = [UIColor whiteColor];
        [_searchBar sizeToFit];
        
        _searchController = [[EaseSearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchController.active = NO;
        _searchController.delegate = self;
        _searchController.searchResultsTableView.tableFooterView = [UIView new];
        _searchController.displaysSearchBarInNavigationBar = YES;
        _searchController.searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _searchController.searchResultsTableView.backgroundColor = RGBACOLOR(230, 230, 235, 1);
        
        [_searchController setActive:YES animated:YES];
        [_searchController.searchBar becomeFirstResponder];
        
        __weak typeof(self) weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            EaseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[EaseListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
            }
            
            EasePublishModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            [cell setName:model.name];
            [cell setContent:model.streamId];
            [cell setHeadImage:[UIImage imageNamed:model.headImageName]];
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 54.f;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            
            EasePublishModel *model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            EaseLiveViewController *view = [[EaseLiveViewController alloc] initWithStreamModel:model];
            [weakSelf.navigationController presentViewController:view animated:YES completion:NULL];
        }];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
//    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:searchText collationStringSelector:@selector(name) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchController.resultsSource removeAllObjects];
                [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                [weakSelf.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
//    [searchBar setShowsCancelButton:NO animated:YES];
}

@end
