//
//  ACDSettingsViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDSettingViewController.h"
#import "ELDSettingAvatarTitleValueAccessCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ELDUserHeaderView.h"


#define kInfoHeaderViewHeight 150.0
#define kHeaderInSectionHeight  20.0


@interface ELDSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) ELDUserHeaderView *userHeaderView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) ELDSettingAvatarTitleValueAccessCell *aboutCell;
@property (nonatomic, strong) EMUserInfo *userInfo;


@end

@implementation ELDSettingViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:ELDUSERINFO_UPDATE object:nil];
        
    }
    return self;
}

- (void)dealloc {
    EASELIVEDEMO_REMOVENOTIFY(self);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ViewControllerBgBlackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavbar];
    [self.view addSubview:self.table];
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self fetchUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)setupNavbar {
    self.prompt.text = NSLocalizedString(@"profile.title", nil);
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.prompt];
    self.navigationItem.rightBarButtonItem = [ELDUtil customBarButtonItemImage:@"setting_edit" action:@selector(goEditUserInfoPage) actionTarget:self];

}

- (void)fetchUserInfo {
    [[EMClient.sharedClient userInfoManager] fetchUserInfoById:@[EMClient.sharedClient.currentUsername] completion:^(NSDictionary *aUserDatas, EMError *aError) {
        if(!aError) {
            self.userInfo = [aUserDatas objectForKey:[EMClient sharedClient].currentUsername];
            [self updateUserHeaderView];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ELDFetchUserInfoNotification object:self.userInfo];
        }
    }];
}

- (void)updateUserHeaderView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userHeaderView.nameLabel.text = self.userInfo.nickname ?:self.userInfo.userId;
        if(self.userInfo && self.userInfo.avatarUrl) {
            NSURL* url = [NSURL URLWithString:self.userInfo.avatarUrl];
            [self.userHeaderView.avatarImageView sd_setImageWithURL:url placeholderImage:kDefultUserImage];
        }
    });
}

- (void)updateUIWithUserInfo:(EMUserInfo *)userInfo {
    self.userInfo = userInfo;
    [self updateUserHeaderView];
}


#pragma mark Notification
- (void)updateUserInfo:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        EMUserInfo *userInfo = notify.object;
        self.userInfo = userInfo;
        self.userHeaderView.nameLabel.text = self.userInfo.nickname;

    });
}

#pragma mark public method
- (void)goAboutPage {
    if (self.goAboutBlock) {
        self.goAboutBlock();
    }
    
//    ELDAboutViewController *vc = [[ELDAboutViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
////    [self.navigationController pushViewController:vc animated:YES];
//
//    AppDelegate *appdelegate =(AppDelegate *) [UIApplication sharedApplication].delegate;
//    UIViewController *rootViewController1 = appdelegate.window.rootViewController;
//    [rootViewController1.navigationController pushViewController:vc animated:YES];
    
}

- (void)goEditUserInfoPage {
//    ELDEditUserInfoViewController *vc = [[ELDEditUserInfoViewController alloc] init];
//    vc.userInfo = self.userInfo;
//    ELD_WS
//    vc.updateUserInfoBlock = ^(EMUserInfo * _Nonnull userInfo) {
//        weakSelf.userInfo = userInfo;
//        [weakSelf updateUserHeaderView];
//    };
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderInSectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kHeaderInSectionHeight)];
    
    UILabel *label = [self sectionTitleLabel];
    label.text = NSLocalizedString(@"profile.settings", nil);
    [sectionView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sectionView);
        make.left.equalTo(sectionView).offset(16.0);
    }];
    
    return sectionView;
}

- (UILabel *)sectionTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor = TextLabelGrayColor;
    label.text = @"setting";
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.aboutCell;
}



#pragma mark getter and setter
- (UITableView *)table {
    if (_table == nil) {
        _table     = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _table.delegate        = self;
        _table.dataSource      = self;
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _table.backgroundColor = ViewControllerBgBlackColor;
        _table.tableHeaderView = [self headerView];
        [_table registerClass:[ELDSettingAvatarTitleValueAccessCell class] forCellReuseIdentifier:[ELDSettingAvatarTitleValueAccessCell reuseIdentifier]];
        _table.rowHeight = [ELDSettingAvatarTitleValueAccessCell height];
    }
    return _table;
}


- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, kInfoHeaderViewHeight)];
        [_headerView addSubview:self.userHeaderView];
        [self.userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerView);
        }];
    }
    return _headerView;
}


- (ELDUserHeaderView *)userHeaderView {
    if (_userHeaderView == nil) {
        _userHeaderView = [[ELDUserHeaderView alloc] initWithFrame:CGRectZero isEditable:NO];
    }
    return _userHeaderView;
}


- (ELDSettingAvatarTitleValueAccessCell *)aboutCell {
    if (_aboutCell == nil) {
        _aboutCell = [[ELDSettingAvatarTitleValueAccessCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ELDSettingAvatarTitleValueAccessCell reuseIdentifier]];
        [_aboutCell.iconImageView setImage:ImageWithName(@"about_icon")];
        _aboutCell.nameLabel.text= NSLocalizedString(@"profile.about", nil);
        NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString *detailContent = [NSString stringWithFormat:@"V %@",ver];
        _aboutCell.detailLabel.text = detailContent;
        ELD_WS
        _aboutCell.tapCellBlock = ^{
            [weakSelf goAboutPage];
        };
    }
    return  _aboutCell;
}



@end
#undef kInfoHeaderViewHeight
#undef kHeaderInSectionHeight




