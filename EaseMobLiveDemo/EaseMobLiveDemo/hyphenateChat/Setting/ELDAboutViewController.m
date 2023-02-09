/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "ELDAboutViewController.h"
#import "ELDSettingTitleValueCell.h"


#import <UIKit/UIKit.h>

@interface ELDAboutViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;

@end

@implementation ELDAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    [self setupNavbar];
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupNavbar {
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [ELDUtil customLeftButtonItem:NSLocalizedString(@"profile.about", nil) action:@selector(backAction) actionTarget:self];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ELDSettingTitleValueCell *cell = [tableView dequeueReusableCellWithIdentifier:[ELDSettingTitleValueCell reuseIdentifier]];
    if (!cell) {
        cell = [[ELDSettingTitleValueCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ELDSettingTitleValueCell reuseIdentifier]];
    }
    
    if (indexPath.row == 0) {
        cell.nameLabel.attributedText = [self titleAttribute:NSLocalizedString(@"about.sdkVersion", nil)];
        NSString *detailContent = [NSString stringWithFormat:@"V %@",[[EMClient sharedClient] version]];
        cell.detailLabel.attributedText = [self detailAttribute:detailContent];
    } else if (indexPath.row == 1) {
        cell.nameLabel.attributedText = [self titleAttribute:NSLocalizedString(@"about.UIVersion", nil)];
        NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString *detailContent = [NSString stringWithFormat:@"V %@",ver];
        cell.detailLabel.attributedText = [self detailAttribute:detailContent];
        
    }else if (indexPath.row == 2) {
        
        cell.nameLabel.attributedText = [self titleAttribute:NSLocalizedString(@"about.more", nil)];
        
        NSAttributedString *attributeString = [ELDUtil attributeContent:@"Easemob.com" color:COLOR_HEX(0x2F80ED) font:Font(@"PingFang SC",16.0)];
        cell.detailLabel.attributedText = attributeString;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 2) {
        [self goAgoraOffical];
    }
}

- (void)goAgoraOffical {
    NSString *urlString = @"https://www.easemob.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    
}

- (NSAttributedString *)titleAttribute:(NSString *)title {
    return [ELDUtil attributeContent:title color:TextLabelWhiteColor font:Font(@"PingFang SC",16.0)];
}

- (NSAttributedString *)detailAttribute:(NSString *)detail {
    return [ELDUtil attributeContent:detail color:[UIColor colorWithWhite:255/255 alpha:0.74] font:Font(@"PingFang SC",16.0)];
}

- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = ViewControllerBgBlackColor;
        [_table registerClass:[ELDSettingTitleValueCell class] forCellReuseIdentifier:[ELDSettingTitleValueCell reuseIdentifier]];
        _table.rowHeight = [ELDSettingTitleValueCell height];
    }
    return _table;
}


@end
