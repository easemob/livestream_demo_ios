//
//  EaseBroadCastTabViewController.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2021/3/23.
//  Copyright © 2021 zmw. All rights reserved.
//

#import "EaseBroadCastTabViewController.h"
#import "EaseBroadCastTabCell.h"
#import "EaseBoradCastCard.h"
#import "EaseLiveTVListViewController.h"
#import <Masonry/Masonry.h>

NSArray<NSString*> *titleArray;
NSArray<NSString*> *descArray;
NSArray<UIImage*> *cardImgArray;

@interface EaseBroadCastTabViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataAry;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation EaseBroadCastTabViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initDefaultInfo];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataAry count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseBroadCastTabCell *cell = [EaseBroadCastTabCell tableView:tableView];
    EaseBoradCastCard *model = self.dataAry[indexPath.section];
    cell.model = model;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = 8;
    if (section == 0)
        height = 13;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, height)];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 13;
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseBoradCastCard *model = [self.dataAry objectAtIndex:indexPath.section];
    EaseLiveTVListViewController *liveTVListVC;
    if ([model.broadCastType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE])
        liveTVListVC = [[EaseLiveTVListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeAGORA_SPEED_LIVE];
    if ([model.broadCastType isEqualToString:kLiveBroadCastingTypeLIVE])
        liveTVListVC = [[EaseLiveTVListViewController alloc]initWithBehavior:kTabbarItemTag_Live video_type:kLiveBroadCastingTypeLIVE];
    
    [self.navigationController pushViewController:liveTVListVC animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 125;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.scrollEnabled = NO;
    }
    
    return _tableView;
}

- (void)initDefaultInfo
{
    NSArray *broadCastTypeArray = @[kLiveBroadCastingTypeLIVE,kLiveBroadCastingTypeAGORA_SPEED_LIVE];
    titleArray = @[@"传统直播",@"极速直播"];
    descArray = @[@"单直播间百万观众，适合弱互动，对延迟没有要求的场景",@"直播延时小于 3 秒，适用于直播答题，互动大班课"];
    cardImgArray = @[[UIImage imageNamed:@"traditionalBroadCast"],[UIImage imageNamed:@"rapidBroadCast"]];
    
    EaseBoradCastCard *model;
    self.dataAry = [[NSMutableArray<EaseBoradCastCard*> alloc]init];
    for (int index = 0; index < [titleArray count]; index++) {
        model = [[EaseBoradCastCard alloc] initWithInfo:cardImgArray[index] title:titleArray[index] desc:descArray[index] type:broadCastTypeArray[index]];
        [self.dataAry addObject:model];
    }
}


@end
