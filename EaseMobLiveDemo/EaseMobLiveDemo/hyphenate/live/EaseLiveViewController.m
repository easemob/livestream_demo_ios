//
//  EaseLiveViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveViewController.h"

#import "UCloudMediaPlayer.h"
#import "CameraServer.h"
#import "UCloudMediaViewController.h"
#import "PlayerManager.h"
#import "EaseChatView.h"
#import "UIViewController+DismissKeyboard.h"
#import "EasePublishModel.h"
#import "EaseChatViewController.h"
#import "AppDelegate.h"
#import "EaseHeartFlyView.h"
#import "EaseGiftFlyView.h"
#import "EaseBarrageFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "EasePrintImageView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveGiftView.h"
#import "EaseChatViewController.h"
#import "EaseLiveCastView.h"
#import "EaseConversationViewController.h"

#define kDefaultTop 31.f
#define kDefaultLeft 18.f

@interface EaseLiveViewController () <EaseChatViewDelegate,EaseLiveHeaderListViewDelegate,TapBackgroundViewDelegate,EaseLiveGiftViewDelegate,EMChatroomManagerDelegate,EaseProfileLiveViewDelegate>
{
    NSTimer *_burstTimer;
    EasePublishModel* _model;
}

@property (nonatomic, strong) PlayerManager *playerManager;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) EaseChatView *chatview;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;
@property (nonatomic, strong) EaseLiveCastView *castView;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *liveView;
@property (nonatomic, strong) EasePrintImageView *printImageView;

@end

@implementation EaseLiveViewController

- (instancetype)initWithStreamModel:(EasePublishModel*)model
{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.liveView];
    
    [self.liveView addSubview:self.castView];
    [self.liveView addSubview:self.chatview];
    [self.liveView addSubview:self.closeButton];
    [self.liveView addSubview:self.headerListView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UCloudPlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    self.playerManager = [[PlayerManager alloc] init];
    self.playerManager.view = self.view;
    self.playerManager.viewContorller = self;
    float height = self.view.frame.size.height;
    [self.playerManager setPortraitViewHeight:height];

    __weak EaseLiveViewController *weakSelf = self;
    [self.playerManager buildMediaPlayer:_model.streamId completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view bringSubviewToFront:weakSelf.liveView];
            [weakSelf.view layoutSubviews];
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL ret = [weakSelf.chatview joinChatroom];
        if (ret) {
            [weakSelf.headerListView loadHeaderListWithChatroomId:kDefaultChatroomId];
        }
    });
    
    _burstTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTheLoveAction) userInfo:nil repeats:YES];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTheLoveAction)];
//    [self.view addGestureRecognizer:tap];
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    
    [self setupForDismissKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    _chatview.delegate = nil;
}

#pragma mark - getter

- (UIWindow*)window
{
    if (_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _window;
}

- (EaseLiveCastView*)castView
{
    if (_castView == nil) {
        _castView = [[EaseLiveCastView alloc] initWithFrame:CGRectMake(kDefaultLeft, kDefaultTop, 120.f, 30.f) model:_model];
        _castView.delegate = self;
    }
    return _castView;
}

- (UIView*)liveView
{
    if (_liveView == nil) {
        _liveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _liveView.backgroundColor = [UIColor clearColor];
    }
    return _liveView;
}

- (EaseLiveHeaderListView*)headerListView
{
    if (_headerListView == nil) {
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(kDefaultLeft, 71.f, KScreenWidth - 30.f, 30.f)];
        _headerListView.delegate = self;
    }
    return _headerListView;
}

- (EaseChatView*)chatview
{
    if (_chatview == nil) {
        NSString *chatroomId = kDefaultChatroomId;
        if (_model.chatroomId.length > 0) {
            chatroomId = [_model.chatroomId copy];
        }
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 200, CGRectGetWidth(self.view.frame), 200) chatroomId:chatroomId];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (UIButton*)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(KScreenWidth - 40.f, kDefaultTop, 30.f, 30.f);
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (EasePrintImageView*)printImageView
{
    if (_printImageView == nil) {
        _printImageView = [[EasePrintImageView alloc] init];
    }
    return _printImageView;
}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:username];
    profileLiveView.delegate = self;
    [profileLiveView showFromParentView:self.view];
}

#pragma  mark - TapBackgroundViewDelegate

- (void)didTapBackgroundView:(EaseBaseSubView *)profileView
{
    [profileView removeFromParentView];
}

#pragma mark - EaseChatViewDelegate

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight
{
    if ([self.window isKeyWindow]) {
        return;
    }
    if (!self.chatview.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.chatview.frame;
            rect.origin.y = self.view.frame.size.height - toHeight;
            self.chatview.frame = rect;
        }];
    }
}

- (void)didReceiveGiftWithCMDMessage:(EMMessage *)message
{
    EaseGiftFlyView *flyView = [[EaseGiftFlyView alloc] initWithMessage:message];
    [self.view addSubview:flyView];
    [flyView animateInView:self.view];
}

- (void)didReceiveBarrageWithCMDMessage:(EMMessage *)message
{
    EaseBarrageFlyView *barrageFlyView = [[EaseBarrageFlyView alloc] initWithMessage:message];
    [self.view addSubview:barrageFlyView];
    [barrageFlyView animateInView:self.view];
}

- (void)didSelectGiftButton
{
    EaseLiveGiftView *giftView = [[EaseLiveGiftView alloc] init];
    giftView.delegate = self;
    giftView.giftDelegate = self;
    [giftView showFromParentView:self.view];
}

- (void)didSelectPrintScreenButton
{
    UIGraphicsBeginImageContext(self.liveView.bounds.size);
    [self.liveView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image1= UIGraphicsGetImageFromCurrentImageContext();
    UIImage *image2 = [self.playerManager.mediaPlayer.player thumbnailImageAtCurrentTime];
    UIImage *image = [UIImage addImage:image2 toImage:image1];

    self.printImageView.image = image;
    [self.view addSubview:_printImageView];
}

- (void)didSelectMessageButton
{
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(0, 0, 44, 44);
    [titleButton setImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    EaseConversationViewController *conversationList = [[EaseConversationViewController alloc] init];
    conversationList.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleButton];
    UINavigationController *navigationController = nil;
    navigationController = [[UINavigationController alloc] initWithRootViewController:conversationList];
    [navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kDefaultSystemTextColor, NSForegroundColorAttributeName, [UIFont systemFontOfSize:18.0], NSFontAttributeName, nil]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    [self.view addSubview:self.window];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.window.top = KScreenHeight - self.window.height;
    }];
}

- (void)didSelectUserWithMessage:(EMMessage *)message
{
    [self.view endEditing:YES];
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:message.from];
    profileLiveView.delegate = self;
    [profileLiveView showFromParentView:self.view];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        [_printImageView removeFromSuperview];
        if (buttonIndex == 1) {
            UIImageWriteToSavedPhotosAlbum(_printImageView.image, self, nil, nil);
        }
        _printImageView = nil;
        
    }
}

#pragma mark - EaseLiveGiftViewDelegate

- (void)didSelectGiftWithGiftId:(NSString *)giftId
{
    if (_chatview) {
        [_chatview sendGiftWithId:giftId];
    }
}

#pragma mark - EaseProfileLiveViewDelegate

- (void)didSelectReplyWithUsername:(NSString*)username
{
    if (_chatview) {
        [_chatview sendMessageAtWithUsername:username];
    }
}

- (void)didSelectMessageWithUsername:(NSString *)username
{
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.frame = CGRectMake(0, 0, 44, 44);
    [titleButton setImage:[UIImage imageNamed:@"popup_close"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    EaseChatViewController *chatview = [[EaseChatViewController alloc] initWithConversationChatter:username conversationType:EMConversationTypeChat];
    [chatview setIsHideLeftBarItem:YES];
    chatview.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleButton];
    chatview.navigationItem.leftBarButtonItem = nil;
    UINavigationController *navigationController = nil;
    navigationController = [[UINavigationController alloc] initWithRootViewController:chatview];
    [navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kDefaultSystemTextColor, NSForegroundColorAttributeName, [UIFont systemFontOfSize:18.0], NSFontAttributeName, nil]];
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    [self.view addSubview:self.window];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.window.top = KScreenHeight - self.window.height;
    }];
}

#pragma mark - EMChatroomManagerDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom username:(NSString *)aUsername
{
    if ([aChatroom.chatroomId isEqualToString:kDefaultChatroomId]) {
        [_headerListView joinChatroomWithUsername:aUsername];
    }
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom username:(NSString *)aUsername
{
    if ([aChatroom.chatroomId isEqualToString:kDefaultChatroomId]) {
        [_headerListView leaveChatroomWithUsername:aUsername];
    }
}

#pragma mark - Action

- (void)closeAction
{
    [self.window resignKeyWindow];
    [UIView animateWithDuration:0.3 animations:^{
        self.window.top = KScreenHeight;
    } completion:^(BOOL finished) {
        self.window.hidden = YES;
        [self.view.window makeKeyAndVisible];
    }];
}

- (void)didSelectHeadImage
{
    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:_model.name];
    profileLiveView.delegate = self;
    [profileLiveView showFromParentView:self.view];
}

-(void)showTheLoveAction
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [_chatview addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), _chatview.height - 100);
    heart.center = fountainSource;
    [heart animateInView:_chatview];
}

- (void)sendButtonAction
{
    EaseChatViewController *messageView = [[EaseChatViewController alloc] initWithConversationChatter:_model.userId conversationType:EMConversationTypeChat];
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (delegate.mainVC) {
        [delegate.mainVC.navigationController pushViewController:messageView animated:YES];
    }
}

- (void)closeButtonAction
{
    [self.playerManager.mediaPlayer.player.view removeFromSuperview];
    [self.playerManager.controlVC.view removeFromSuperview];
    [self.playerManager.mediaPlayer.player shutdown];
    self.playerManager.mediaPlayer = nil;

//    {
//        self.playerManager.supportInterOrtation = UIInterfaceOrientationMaskPortrait;
//        [self.playerManager awakeSupportInterOrtation:self.playerManager.viewContorller completion:^{
//            self.playerManager.supportInterOrtation = UIInterfaceOrientationMaskAllButUpsideDown;
//        }];
//    }
    
    self.playerManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UCloudPlayerPlaybackDidFinishNotification object:nil];
    
    __weak typeof(self) weakSelf =  self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *chatroomId = [_model.chatroomId copy];
        EMError *error = nil;
        [[EMClient sharedClient].roomManager leaveChatroom:chatroomId error:&error];
        if (!error) {
            [[EMClient sharedClient].chatManager deleteConversation:chatroomId deleteMessages:YES];
        }
    });
    
    [_burstTimer invalidate];
    _burstTimer = nil;
    
    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
}

- (void)noti:(NSNotification *)noti
{
    if ([noti.name isEqualToString:UCloudPlayerPlaybackDidFinishNotification]) {
        MPMovieFinishReason reson = [[noti.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
        if (reson == MPMovieFinishReasonPlaybackEnded) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"直播中断" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
//            [self closeButtonAction];
        }
        else if (reson == MPMovieFinishReasonPlaybackError) {
//            [self closeButtonAction];
        }
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endFrame.origin.y;
    
    if ([self.window isKeyWindow]) {
        if (y == KScreenHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.window.top = KScreenHeight - 290.f;
                self.window.height = 290.f;
            }];
        } else  {
            [UIView animateWithDuration:0.3 animations:^{
                self.window.top = 0;
                self.window.height = KScreenHeight;
            }];
        }
    }
}

@end
