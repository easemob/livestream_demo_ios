//
//  MainViewController.m
//
//  Created by EaseMob on 16/5/30.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseMainViewController.h"

#import "EaseLiveTVListViewController.h"
#import "EasePublishViewController.h"
#import "UIImage+Color.h"
#import "EaseCreateLiveViewController.h"
#import "EaseSearchDisplayController.h"
#import "Masonry.h"
#import "EaseSettingsViewController.h"
#import "EaseDefaultDataHelper.h"

#define IS_iPhoneX (\
{\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);}\
)
#define EMVIEWTOPMARGIN (IS_iPhoneX ? 22.f : 0.f)
#define EMVIEWBOTTOMMARGIN (IS_iPhoneX ? 34.f : 0.f)

@interface EaseMainViewController () <UITabBarDelegate>
{
    EaseLiveTVListViewController *_liveTVListViewController;
    EaseLiveTVListViewController *_broadCastViewController;
    EaseSettingsViewController *_settingsViewController;
    CGFloat broadCastBtnScale;//比例
}
@property (nonatomic, strong) UIView *addView;
@property (nonatomic, strong) UITabBar *tabBar;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIButton *broadCastBtn;
@end

@implementation EaseMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    UIColor* color = [UIColor blackColor];
    NSDictionary* dict=[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    broadCastBtnScale = 0.9;
    [self setupSubviews];
    [self fetchLiveroomStatus];
}

//判断之前之前直播的直播间是否正直播
- (void)fetchLiveroomStatus
{
    [[EaseHttpManager sharedInstance] fetchLiveroomDetail:EaseDefaultDataHelper.shared.currentRoomId completion:^(EaseLiveRoom *room, BOOL success) {
        if (success) {
            if (room.status == ongoing && [room.anchor isEqualToString:EMClient.sharedClient.currentUsername]) {
                EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:room];
                publishView.modalPresentationStyle = 0;
                [self presentViewController:publishView animated:YES completion:^{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }];
            }
        }
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.title = @"直播大厅";
    NSInteger tag = item.tag;
    UIView *tmpView = nil;
    if (tag == kTabbarItemTag_Live) {
        tmpView = _liveTVListViewController.view;
    } else if (tag == kTabbarItemTag_Broadcast) {
        //tmpView = broadCastViewController.view;
    } else if (tag == kTabbarItemTag_Settings) {
        self.title = @"设置";
        tmpView = _settingsViewController.view;
    }
    
    if (self.addView == tmpView) {
        return;
    } else {
        [self.addView removeFromSuperview];
        self.addView = nil;
    }
    
    self.addView = tmpView;
    if (self.addView) {
        //[self.view addSubview:self.addView];
        [self.view insertSubview:self.addView belowSubview:self.broadCastBtn];
        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.tabBar.mas_top);
        }];
    }
}


- (void)setupSubviews
{
    self.tabBar = [[UITabBar alloc] init];
    self.tabBar.delegate = self;
    self.tabBar.translucent = NO;
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.tabBar setTintColor:kDefaultSystemBgColor];
    [self.tabBar setBarTintColor:[UIColor whiteColor]];
    [self.view addSubview:self.tabBar];
    [self.tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-EMVIEWBOTTOMMARGIN);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(50);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.tabBar addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabBar.mas_top);
        make.left.equalTo(self.tabBar.mas_left);
        make.right.equalTo(self.tabBar.mas_right);
        make.height.equalTo(@1);
    }];
    
    [self _setupChildController];
    [self.view addSubview:self.broadCastBtn];
    [self.broadCastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@70);
        make.top.equalTo(self.tabBar.mas_top).offset(-30);
        make.centerX.equalTo(self.view);
    }];
}

- (UIButton *)broadCastBtn
{
    if (_broadCastBtn == nil) {
        _broadCastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_broadCastBtn setImage:[UIImage imageNamed:@"Logo"] forState:UIControlStateNormal];
        [_broadCastBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        _broadCastBtn.layer.cornerRadius = 35;
        _broadCastBtn.backgroundColor = [UIColor whiteColor];
        [_broadCastBtn addTarget:self action:@selector(broadCastFeedBack:) forControlEvents:UIControlEventTouchDown];
        [_broadCastBtn addTarget:self action:@selector(createBroadcastRoom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _broadCastBtn;
}

- (void)broadCastFeedBack:(UIButton *)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        sender.transform = CGAffineTransformMakeScale(broadCastBtnScale, broadCastBtnScale);
    }];
}

- (void)createBroadcastRoom
{
    EaseCreateLiveViewController *createLiveView = [[EaseCreateLiveViewController alloc] init];
    createLiveView.modalPresentationStyle = 0;
    [self presentViewController:createLiveView animated:YES completion:nil];
    //[self.navigationController pushViewController:createLiveView animated:NO];
}

//主播大厅
- (void)anchorHall:(UIButton *)sender
{
    [UIView animateWithDuration:0.25 animations:^{
         sender.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        _broadCastViewController = [[EaseLiveTVListViewController alloc] initWithBehavior:kTabbarItemTag_Broadcast];
        [self.navigationController pushViewController:_broadCastViewController animated:YES];
    }];
}

- (void)_setupChildController
{
    _liveTVListViewController = [[EaseLiveTVListViewController alloc] initWithBehavior:kTabbarItemTag_Live];//看直播
    UITabBarItem *liveItem = [self _setupTabBarItemWithTitle:nil imgName:@"icon-liveList-unSelected" selectedImgName:@"icon-liveList-selected" tag:kTabbarItemTag_Live];
    _liveTVListViewController.tabBarItem = liveItem;
    [self addChildViewController:_liveTVListViewController];
    
    /*_broadCastViewController = [[EaseLiveTVListViewController alloc] initWithBehavior:kTabbarItemTag_Broadcast]; //开播
    UITabBarItem *borderCastItem = [self _setupTabBarItemWithTitle:nil imgName:@"Logo" selectedImgName:@"Logo" tag:kTabbarItemTag_Broadcast];
    broadCastViewController.tabBarItem = liveItem;
    [self addChildViewController:broadCastViewController];*/
    
    _settingsViewController = [[EaseSettingsViewController alloc]init];
    UITabBarItem *settingsItem = [self _setupTabBarItemWithTitle:nil imgName:@"icon-setting-unSelected" selectedImgName:@"icon-setting-selected" tag:kTabbarItemTag_Settings];
    _settingsViewController.tabBarItem = liveItem;
    [self addChildViewController:_settingsViewController];
    
    self.viewControllers = @[_liveTVListViewController,_settingsViewController];
    
    //占位item
    UITabBarItem *blankBar = [[UITabBarItem alloc]init];
    blankBar.enabled = NO;
    [self.tabBar setItems:@[liveItem,blankBar,settingsItem]];
    self.tabBar.selectedItem = liveItem;
    [self tabBar:self.tabBar didSelectItem:liveItem];
}

- (UITabBarItem *)_setupTabBarItemWithTitle:(NSString *)aTitle
                                    imgName:(NSString *)aImgName
                            selectedImgName:(NSString *)aSelectedImgName
                                        tag:(NSInteger)aTag
{
    UITabBarItem *retItem = [[UITabBarItem alloc] initWithTitle:aTitle image:[UIImage imageNamed:aImgName] selectedImage:[[UIImage imageNamed:aSelectedImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    retItem.tag = aTag;
    /*
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor lightGrayColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [retItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:13], NSFontAttributeName, [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];*/
    return retItem;
}
/*
#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController.tabBarItem.tag == 1) {
        EasePublishViewController *publishViewController = [[EasePublishViewController alloc] init];
        [self presentViewController:publishViewController animated:YES completion:NULL];
        return NO;
    }
    return YES;
}*/

@end
