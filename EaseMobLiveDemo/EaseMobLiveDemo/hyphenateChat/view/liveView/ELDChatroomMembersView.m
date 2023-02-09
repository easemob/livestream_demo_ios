//
//  ELDChatroomMembersView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/12.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatroomMembersView.h"
#import "MISScrollPage.h"
#import "ELDLiveroomMembersViewController.h"

#define kViewTopPadding  200.0f

@interface ELDChatroomMembersView ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate>
@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic,strong) ELDLiveroomMembersViewController *allVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *adminListVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *allowListVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *mutedListVC;
@property (nonatomic,strong) ELDLiveroomMembersViewController *blockListVC;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *alphaBgView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIImageView *topBgImageView;
@property (nonatomic, strong) EMChatroom *chatroom;

@property (nonatomic, strong) NSMutableArray *navTitleArray;
@property (nonatomic, strong) NSMutableArray *contentVCArray;
@property (nonatomic, strong) UILabel *viewerTitleLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;


@end

@implementation ELDChatroomMembersView
- (instancetype)initWithChatroom:(EMChatroom *)aChatroom {
    self = [self init];
    if (self) {
        self.chatroom = aChatroom;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatroomUpdateNotification:) name:ELDChatroomUpdateNotification object:nil];
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviewsForMember {
        
    [self.containerView addSubview:self.topBgImageView];
    [self.containerView addSubview:self.viewerTitleLabel];
    [self.containerView addSubview:self.allVC.view];
    
    
    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.left.right.equalTo(self.containerView);
    }];
    
    [self.viewerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgImageView.mas_bottom);
        make.left.right.equalTo(self.containerView);
    }];
    
    [self.allVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.viewerTitleLabel.mas_bottom);
        make.left.right.bottom.equalTo(self.containerView);
    }];
}


- (void)placeAndLayoutSubviewsForAdmin {
    [self.containerView addSubview:self.topBgImageView];
    [self.containerView addSubview:self.segView];
    [self.containerView addSubview:self.contentView];
    
    
    [self.topBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.left.right.equalTo(self.containerView);
    }];
    
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBgImageView.mas_bottom);
        make.left.equalTo(self.containerView);
        make.right.equalTo(self.containerView);
        make.height.equalTo(@50);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segView.mas_bottom);
        make.left.equalTo(self.containerView);
        make.right.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView);
    }];
}


- (void)placeAndLayoutSubviews {

    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self addSubview:self.bgView];
    [self addSubview:self.alphaBgView];
    [self addSubview:self.containerView];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.alphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(kViewTopPadding, 0, 0, 0));
    }];
    
    if ([self isAdmin]) {
        [self placeAndLayoutSubviewsForAdmin];
    }else {
        [self placeAndLayoutSubviewsForMember];
    }
    
    [self.pageController reloadData];
}


- (void)updateWithChatroom:(EMChatroom *)aChatroom {
    self.chatroom = aChatroom;
    
    [self removeAllSubviews];
    [self placeAndLayoutSubviews];

    [self.allVC updateUIWithChatroom:self.chatroom];
    [self.adminListVC updateUIWithChatroom:self.chatroom];
    [self.allowListVC updateUIWithChatroom:self.chatroom];
    [self.blockListVC updateUIWithChatroom:self.chatroom];
    [self.mutedListVC updateUIWithChatroom:self.chatroom];
}


#pragma mark private method
- (void)tapGestureAction {
    [self removeFromSuperview];
}


- (BOOL)isAdmin {
    return (self.chatroom.permissionType == EMGroupPermissionTypeOwner || self.chatroom.permissionType == EMGroupPermissionTypeAdmin );
}


- (void)handleSelectedWithUserId:(NSString *)userId memberVCType:(ELDMemberVCType)memberVCType {
    if (self.selectedUserDelegate && [self.selectedUserDelegate respondsToSelector:@selector(selectedUser:memberVCType:chatRoom:)]) {
        [self.selectedUserDelegate selectedUser:userId memberVCType:memberVCType chatRoom:self.chatroom];
    }
}


#pragma mark Notification
- (void)chatroomUpdateNotification:(EMChatroom *)chatroom {
    [self updateWithChatroom:chatroom];
}

#pragma mark - scrool pager data source and delegate
- (NSUInteger)numberOfChildViewControllers {
    return self.navTitleArray.count;
}

- (NSArray*)titlesOfSegmentView {
    return self.navTitleArray;
}


- (NSArray*)childViewControllersOfContentView {
    return self.contentVCArray;
}

#pragma mark -
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index {
    self.currentPageIndex = index;
}


#pragma mark - setter or getter
- (MISScrollPageController*)pageController {
    if(!_pageController){
        MISScrollPageStyle* style = [[MISScrollPageStyle alloc] init];
        style.showCover = YES;
        style.coverBackgroundColor = COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = COLOR_HEX(0x999999);
        style.selectedTitleColor = COLOR_HEX(0x000000);
        style.scrollLineColor = COLOR_HEXA(0x000000, 0.5);

        style.scaleTitle = YES;
        style.autoAdjustTitlesWidth = YES;
        style.titleBigScale = 1.05;
        style.titleFont = Font(@"PingFang SC",14.0);
        style.showSegmentViewShadow = YES;
        _pageController = [MISScrollPageController scrollPageControllerWithStyle:style dataSource:self delegate:self];
    }
    return _pageController;
}

- (MISScrollPageSegmentView*)segView{
    if(!_segView){
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    }
    return _segView;
}

- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, KScreenWidth, KScreenHeight-64-kViewTopPadding)];
        _contentView.backgroundColor = UIColor.whiteColor;
    }
    return _contentView;
}


- (ELDLiveroomMembersViewController *)allVC {
    if (_allVC == nil) {
        _allVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom withMemberType:ELDMemberVCTypeAll];
        ELD_WS
        _allVC.selectedUserBlock = ^(NSString * _Nonnull userId, ELDMemberVCType memberVCType) {
            [weakSelf handleSelectedWithUserId:userId memberVCType:memberVCType];
        };
    }
    return _allVC;
}

- (ELDLiveroomMembersViewController *)adminListVC {
    if (_adminListVC == nil) {
        _adminListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom withMemberType:ELDMemberVCTypeAdmin];
        ELD_WS
        _adminListVC.selectedUserBlock = ^(NSString * _Nonnull userId, ELDMemberVCType memberVCType) {
            [weakSelf handleSelectedWithUserId:userId memberVCType:memberVCType];
        };
    }
    return _adminListVC;
}

- (ELDLiveroomMembersViewController *)allowListVC {
    if (_allowListVC == nil) {
        _allowListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom withMemberType:ELDMemberVCTypeAllow];
        ELD_WS
        _allowListVC.selectedUserBlock = ^(NSString * _Nonnull userId, ELDMemberVCType memberVCType) {
            [weakSelf handleSelectedWithUserId:userId memberVCType:memberVCType];
        };
    }
    return _allowListVC;
}

- (ELDLiveroomMembersViewController *)mutedListVC {
    if (_mutedListVC == nil) {
        _mutedListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom withMemberType:ELDMemberVCTypeMute];
        ELD_WS
        _mutedListVC.selectedUserBlock = ^(NSString * _Nonnull userId, ELDMemberVCType memberVCType) {
            [weakSelf handleSelectedWithUserId:userId memberVCType:memberVCType];
        };

    }
    return _mutedListVC;
}

- (ELDLiveroomMembersViewController *)blockListVC {
    if (_blockListVC == nil) {
        _blockListVC = [[ELDLiveroomMembersViewController alloc] initWithChatroom:self.chatroom withMemberType:ELDMemberVCTypeBlock];
        ELD_WS
        _blockListVC.selectedUserBlock = ^(NSString * _Nonnull userId, ELDMemberVCType memberVCType) {
            [weakSelf handleSelectedWithUserId:userId memberVCType:memberVCType];
        };

    }
    return _blockListVC;
}

- (UIImageView*)topBgImageView
{
    if (_topBgImageView == nil) {
        _topBgImageView = [[UIImageView alloc] init];
        _topBgImageView.image = [UIImage imageNamed:@"member_bg_top"];
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.layer.masksToBounds = YES;
    }
    return _topBgImageView;
}


- (NSMutableArray *)navTitleArray {
    if (_navTitleArray == nil) {
        _navTitleArray = NSMutableArray.new;
    }
    return _navTitleArray;
}

- (NSMutableArray *)contentVCArray {
    if (_contentVCArray == nil) {
        _contentVCArray = NSMutableArray.new;
    }
    return _contentVCArray;
}

- (void)setChatroom:(EMChatroom *)chatroom {
    _chatroom = chatroom;
    
    if ([self isAdmin]) {
        self.navTitleArray = [
            @[NSLocalizedString(@"live.all", nil),
              NSLocalizedString(@"live.Moderators", nil),
              NSLocalizedString(@"live.Allowed", nil),
              NSLocalizedString(@"live.Mutes", nil),
              NSLocalizedString(@"live.bannedList", nil)] mutableCopy];
        self.contentVCArray = [@[self.allVC,self.adminListVC,self.allowListVC,self.mutedListVC,self.blockListVC] mutableCopy];
    }
    
    self.allVC.isAdmin = [self isAdmin];
    
}


- (UIView *)alphaBgView {
    if (_alphaBgView == nil) {
        _alphaBgView = [[UIView alloc] init];
        _alphaBgView.backgroundColor = UIColor.blackColor;
        _alphaBgView.alpha = 0.01;
    }
    return _alphaBgView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.userInteractionEnabled = YES;
        [_bgView addGestureRecognizer:self.tapGestureRecognizer];
    }
    return _bgView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self    action:@selector(tapGestureAction)];
    }
    return _tapGestureRecognizer;
}

- (UILabel *)viewerTitleLabel {
    if (_viewerTitleLabel == nil) {
        _viewerTitleLabel = [[UILabel alloc] init];
        _viewerTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16.0f];
        _viewerTitleLabel.textColor = TextLabelBlackColor;
        _viewerTitleLabel.textAlignment = NSTextAlignmentCenter;
        _viewerTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _viewerTitleLabel.text = NSLocalizedString(@"main.allViewers", nil);
        _viewerTitleLabel.backgroundColor = UIColor.whiteColor;
    }
    return _viewerTitleLabel;
}

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}


@end

#undef kViewTopPadding

