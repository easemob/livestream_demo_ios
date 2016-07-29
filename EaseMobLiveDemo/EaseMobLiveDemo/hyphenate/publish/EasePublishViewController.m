//
//  EasePublishViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/3.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EasePublishViewController.h"

#import "UCloudMediaPlayer.h"
#import "CameraServer.h"
#import "UCloudMediaViewController.h"
#import "FilterManager.h"
#import "EaseChatView.h"
#import "EaseTextView.h"
#import "UIViewController+DismissKeyboard.h"
#import "EaseParseManager.h"
#import "PFObject.h"
#import "EaseHeartFlyView.h"
#import "EaseGiftFlyView.h"
#import "EaseBarrageFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "EasePrintImageView.h"
#import "EaseEndLiveView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveCastView.h"
#import "EasePublishModel.h"
#import "EaseConversationViewController.h"
#import "EaseChatViewController.h"

#define kDefaultTop 31.f
#define kDefaultLeft 18.f

@interface EasePublishViewController () <EaseChatViewDelegate,UITextViewDelegate,EMChatroomManagerDelegate,EaseEndLiveViewDelegate,TapBackgroundViewDelegate,EaseLiveHeaderListViewDelegate,EaseProfileLiveViewDelegate>
{
    BOOL _isload;
    BOOL _isShutDown;
    
    UIView *_blackView;
    NSTimer *_burstTimer;
    
    BOOL _isPublish;
    
    EasePublishModel *_model;
}

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *changeBtn;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *microphoneBtn;

@property (nonatomic, strong) EaseLiveCastView *castView;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;
@property (nonatomic, strong) EasePrintImageView *printImageView;
@property (nonatomic, strong) EaseEndLiveView *endLiveView;
@property (nonatomic, strong) UIWindow *subWindow;

//发布直播
@property (nonatomic, strong) UIButton *startButton;

//直播相关
@property (strong, nonatomic) FilterManager *filterManager;
@property (strong, nonatomic) NSMutableArray *filters;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) AVCaptureDevice *currentDev;
@property (nonatomic, assign) BOOL shouldAutoStarted;

@property (strong, nonatomic) NSTimer *timer;

//聊天室
@property (strong, nonatomic) EaseChatView *chatview;
@property (copy, nonatomic) NSString *streamId;

@end

@implementation EasePublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布直播";
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    [self setupForDismissKeyboard];
    
    [self.view addSubview:self.castView];
    
    [self.view addSubview:self.startButton];
    
    [self.view addSubview:self.chatview];
    [self.view addSubview:self.headerListView];
    [self.view addSubview:self.flashBtn];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.changeBtn];
    [self.view addSubview:self.microphoneBtn];
    [self setBtnStateInSel:1];
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    
    self.streamId = @"em_10001";
    if ([[EMClient sharedClient].currentUsername isEqualToString:@"test2"]) {
        self.streamId = @"em_10002";
    } else if ([[EMClient sharedClient].currentUsername isEqualToString:@"test3"]) {
        self.streamId = @"em_10003";
    } else if ([[EMClient sharedClient].currentUsername isEqualToString:@"test4"]) {
        self.streamId = @"em_10004";
    } else if ([[EMClient sharedClient].currentUsername isEqualToString:@"test5"]) {
        self.streamId = @"em_10005";
    } else if ([[EMClient sharedClient].currentUsername isEqualToString:@"test6"]) {
        self.streamId = @"em_10006";
    }
    
    [self startAction];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].roomManager removeDelegate:self];
    
    _chatview.delegate = nil;
    
    if (_burstTimer) {
        [_burstTimer invalidate];
        _burstTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (UIWindow*)subWindow
{
    if (_subWindow == nil) {
        _subWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _subWindow;
}

- (EaseEndLiveView*)endLiveView
{
    if (_endLiveView == nil) {
        _endLiveView = [[EaseEndLiveView alloc] initWithUsername:[EMClient sharedClient].currentUsername like:@"6851" time:@"54:12" audience:@"265381" comments:@"75192"];
        _endLiveView.delegate = self;
    }
    return _endLiveView;
}

- (EasePrintImageView*)printImageView
{
    if (_printImageView == nil) {
        _printImageView = [[EasePrintImageView alloc] init];
    }
    return _printImageView;
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
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 200, CGRectGetWidth(self.view.bounds), 200) chatroomId:kDefaultChatroomId isPublish:YES];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (EaseLiveCastView*)castView
{
    if (_castView == nil) {
        _model = [[EasePublishModel alloc] init];
        _model.name = [EMClient sharedClient].currentUsername;
        _castView = [[EaseLiveCastView alloc] initWithFrame:CGRectMake(kDefaultLeft, kDefaultTop, 120.f, 30.f) model:_model];
        _castView.delegate = self;
    }
    return _castView;
}

- (UIButton*)startButton
{
    if (_startButton == nil) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 54.f, CGRectGetWidth(self.view.frame), 54.f);
        [_startButton setBackgroundColor:kDefaultSystemBgColor];
        [_startButton setTitle:NSLocalizedString(@"publish.button.live", @"Publish Live") forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton*)microphoneBtn
{
    if(_microphoneBtn == nil) {
        _microphoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _microphoneBtn.frame = CGRectMake(KScreenWidth - 160, kDefaultTop, 30, 30);
        [_microphoneBtn setImage:[UIImage imageNamed:@"live_mac"] forState:UIControlStateNormal];
        [_microphoneBtn setImage:[UIImage imageNamed:@"live_mac_close"] forState:UIControlStateSelected];
        [_microphoneBtn addTarget:self action:@selector(macAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _microphoneBtn;
}

- (UIButton*)flashBtn
{
    if (_flashBtn == nil) {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashBtn.frame = CGRectMake(KScreenWidth - 120, kDefaultTop, 30, 30);
        [_flashBtn setImage:[UIImage imageNamed:@"live_flash"] forState:UIControlStateNormal];
        [_flashBtn setImage:[UIImage imageNamed:@"live_flash_close"] forState:UIControlStateSelected];
        [_flashBtn addTarget:self action:@selector(flashAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}

- (UIButton*)changeBtn
{
    if (_changeBtn == nil) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.frame = CGRectMake(KScreenWidth - 80, kDefaultTop, 30, 30);
        [_changeBtn setImage:[UIImage imageNamed:@"live_cam"] forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeBtn;
}

- (UIButton*)closeBtn
{
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(KScreenWidth - 40, kDefaultTop, 30, 30);
        [_closeBtn setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(stopCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)closeAction
{
    [self.subWindow resignKeyWindow];
    [UIView animateWithDuration:0.3 animations:^{
        self.subWindow.top = KScreenHeight;
    } completion:^(BOOL finished) {
        self.subWindow.hidden = YES;
        [self.view.window makeKeyAndVisible];
    }];
}

- (void)didSelectHeadImage
{
    if ([self.subWindow isKeyWindow]) {
        [self closeAction];
        return;
    }
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:[EMClient sharedClient].currentUsername];
    profileLiveView.delegate = self;
    [profileLiveView showFromParentView:self.view];
}

- (void)flashAction
{
    _flashBtn.selected = !_flashBtn.selected;
    if (_flashBtn.selected) {
        [[CameraServer server] setFlashState:UCloudCameraCode_On];
    } else {
        [[CameraServer server] setFlashState:UCloudCameraCode_Off];
    }
}

- (void)macAction
{
    _microphoneBtn.selected = !_microphoneBtn.selected;
}

//点击屏幕点赞特效
-(void)showTheLoveAction
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [_chatview addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), _chatview.height - 100);
    heart.center = fountainSource;
    [heart animateInView:_chatview];
}

- (void)changeAction
{
    [[CameraServer server] changeCamera];
}

//停止直播
- (void)stopCameraAction
{
    if (_burstTimer) {
        [_burstTimer invalidate];
        _burstTimer = nil;
    }
    
    self.shouldAutoStarted = NO;
    self.closeBtn.enabled = NO;
    __weak EasePublishViewController *weakSelf = self;
    [self.timer invalidate];
    self.timer = nil;
    [[CameraServer server] shutdown:^{
        if (weakSelf.videoView)
        {
            [weakSelf.videoView removeFromSuperview];
        }
        weakSelf.videoView = nil;
        
        weakSelf.closeBtn.enabled = YES;
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [weakSelf removeNoti];
        
        if (_isPublish) {
            [weakSelf.view addSubview:self.endLiveView];
            [weakSelf.view bringSubviewToFront:self.endLiveView];
        } else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

//切换摄像头
- (void)changeCameraAction
{
    self.changeBtn.enabled = NO;
    [[CameraServer server] changeCamera];
    self.changeBtn.enabled = YES;
}

- (void)publishAction
{
    _isPublish = YES;
    __weak EasePublishViewController *weakSelf = self;
    [_closeBtn addTarget:self action:@selector(stopCameraAction) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.chatview joinChatroom];
        [weakSelf.headerListView loadHeaderListWithChatroomId:kDefaultChatroomId];
    });
    [self setBtnStateInSel:2];
}

//发布直播
- (void)startAction
{
    [self removeNoti];
    [self addNoti];
    self.shouldAutoStarted = YES;
    if (self.filterManager)
    {
    }
    
    if ([[CameraServer server] lowThan5])
    {
        //5以下支持4：3
        [[CameraServer server] setHeight:640];
        [[CameraServer server] setWidth:480];
    }
    else
    {
        //5以上的支持16：9
        [[CameraServer server] setHeight:640];
        [[CameraServer server] setWidth:360];
    }
    
    [[CameraServer server] setFps:15];
    [[CameraServer server] setSupportFilter:YES];
    
    self.filterManager = [[FilterManager alloc] init];
    
    [self buildData];
    
    [[CameraServer server] setSecretkey:CGIKey];
    //11.4  4.05 2.05 1.75
    [[CameraServer server] setBitrate:3.05];
    //
    NSString *path = RecordDomain(self.streamId);
    
    __weak EasePublishViewController *weakSelf = self;
    
    self.startButton.enabled = NO;
    NSArray *filters = [self.filterManager filters];
    [[CameraServer server] configureCameraWithOutputUrl:path
                                                 filter:filters
                                        messageCallBack:^(UCloudCameraCode code, NSInteger arg1, NSInteger arg2, id data){
                                            if (code == UCloudCamera_BUFFER_OVERFLOW)
                                            {
                                                static BOOL viewShowed = NO;
                                                if (arg1 == 1 && !viewShowed)
                                                {
                                                    viewShowed = YES;
                                                }
                                                else
                                                {
                                                    if (viewShowed)
                                                    {
                                                        viewShowed = NO;
                                                    }
                                                };
                                            }
                                            else if (code == UCloudCamera_SecretkeyNil)
                                            {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"密钥为空" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                [alert show];
                                                [weakSelf setBtnStateInSel:1];
                                            }
                                            else if (code == UCloudCamera_PreviewOK)
                                            {
                                                [self.videoView removeFromSuperview];
                                                self.videoView = nil;
                                                [weakSelf startPreview];
                                            }
                                            else if (code == UCloudCamera_PublishOk)
                                            {
                                                weakSelf.startButton.enabled = YES;
                                                [[CameraServer server] cameraStart];
                                                [weakSelf.filterManager setCurrentValue:weakSelf.filters];
                                            }
                                            else if (code == UCloudCamera_StartPublish)
                                            {
                                                weakSelf.startButton.enabled = YES;
                                            }
                                            else if (code == UCloudCamera_Permission)
                                            {
                                                UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"相机授权" message:@"没有权限访问您的相机，请在“设置－隐私－相机”中允许使用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                                                [alterView show];
                                                weakSelf.startButton.enabled = YES;
                                            }
                                            else if (code == UCloudCamera_Micphone)
                                            {
                                                [[[UIAlertView alloc] initWithTitle:@"麦克风授权" message:@"没有权限访问您的麦克风，请在“设置－隐私－麦克风”中允许使用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
                                                weakSelf.startButton.enabled = YES;
                                            }
                                            
                                        }
                                            deviceBlock:^(AVCaptureDevice *dev) {
                                                weakSelf.currentDev = dev;
                                                
                                                BOOL containISO = NO;
                                                for (NSDictionary *fil in weakSelf.filters)
                                                {
                                                    NSString *type = fil[@"type"];
                                                    if ([type isEqualToString:@"ISO"])
                                                    {
                                                        containISO = YES;
                                                    }
                                                }
                                                
                                                if (SysVersion >= 8.f && containISO)
                                                {
                                                    AVCaptureDeviceFormat *format = dev.activeFormat;
                                                    
                                                    float minISO = format.minISO;
                                                    NSDictionary *iso = [weakSelf.filters lastObject];
                                                    NSMutableDictionary *newIso = [NSMutableDictionary dictionaryWithDictionary:iso];
                                                    newIso[@"min"] = @(minISO);
                                                    newIso[@"max"] = @(200.f);
                                                    newIso[@"current"] = @(57.7);
                                                    [weakSelf.filters replaceObjectAtIndex:[self.filters indexOfObject:iso] withObject:newIso];
                                                }
                                                
                                            }cameraData:^CMSampleBufferRef(CMSampleBufferRef buffer) {
                                                /**
                                                 *  若果不需要裸流，不建议在这里执行操作，讲增加额外的功耗
                                                 */
                                                
                                                return nil;
                                            }];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    if (_burstTimer == nil) {
        _burstTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(showTheLoveAction) userInfo:nil repeats:YES];
    }
}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.subWindow isKeyWindow]) {
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

#pragma mark - EaseEndLiveViewDelegate

- (void)didClickEndButton
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.chatview leaveChatroom];
    });
    
    [_burstTimer invalidate];
    _burstTimer = nil;
    
    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - EaseChatViewDelegate

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight
{
    if ([self.subWindow isKeyWindow]) {
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

- (void)didSelectPrintScreenButton
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image1= UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsBeginImageContext([[CameraServer server] getCameraView].bounds.size);
    [[[CameraServer server] getCameraView].layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();;
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
    [self.subWindow setRootViewController:navigationController];
    [self.subWindow makeKeyAndVisible];
    [self.view addSubview:self.subWindow];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.subWindow.top = KScreenHeight - self.subWindow.height;
    }];
}

- (void)didSelectUserWithMessage:(EMMessage *)message
{
    [self.view endEditing:YES];
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:message.from];
    profileLiveView.delegate = self;
    [profileLiveView showFromParentView:self.view];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
    chatview.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleButton];
    chatview.navigationItem.leftBarButtonItem = nil;
    UINavigationController *navigationController = nil;
    navigationController = [[UINavigationController alloc] initWithRootViewController:chatview];
    [navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kDefaultSystemTextColor, NSForegroundColorAttributeName, [UIFont systemFontOfSize:18.0], NSFontAttributeName, nil]];
    [self.subWindow setRootViewController:navigationController];
    [self.subWindow makeKeyAndVisible];
    [self.view addSubview:self.subWindow];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.subWindow.top = KScreenHeight - self.subWindow.height;
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

#pragma mark - private

- (void)startPreview
{
    UIView *cameraView = [[CameraServer server] getCameraView];
    cameraView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cameraView];
    [self.view sendSubviewToBack:cameraView];
    self.videoView = cameraView;
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UCloudNeedRestart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removeNoti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UCloudNeedRestart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)buildData
{
    self.filters = [self.filterManager buildData];
}

- (void)setBtnStateInSel:(NSInteger)num
{
    if (num == 1) {
        self.startButton.hidden = NO;
        self.chatview.hidden = YES;
        self.headerListView.hidden = YES;
        self.microphoneBtn.hidden = YES;
    } else {
        self.startButton.hidden = YES;
        self.chatview.hidden = NO;
        self.headerListView.hidden = NO;
        self.microphoneBtn.hidden = NO;
    }
}


- (void)noti:(NSNotification *)noti
{
    NSLog(@"noti name :%@",noti.name);
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if ([noti.name isEqualToString:UCloudMoviePlayerClickBack]) {
        [self setBtnStateInSel:1];
    }
    else if ([noti.name isEqualToString:UCloudNeedRestart])
    {
        if (self.shouldAutoStarted)
        {
            NSLog(@"restart");
            [self startAction];
        }
    }
    else if ([noti.name isEqualToString:UIApplicationDidEnterBackgroundNotification] || [noti.name isEqualToString:UIApplicationWillResignActiveNotification])
    {
        [_burstTimer invalidate];
        _burstTimer = nil;
        while (!_isShutDown) {
            [[CameraServer server] shutdown:^{
                _blackView = [[CameraServer server] createBlurringScreenshot];
                _blackView.backgroundColor = [UIColor blackColor];
                [self.videoView addSubview:_blackView];
                
                UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]init];
                activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
                activity.center = _blackView.center;
                [activity startAnimating];
                [_blackView addSubview:activity];
                
            }];
            _isShutDown = YES;
        }
        _isload = NO;
    }
    else if ([noti.name isEqualToString:UIApplicationDidBecomeActiveNotification])
    {
        while (!_isload) {
            [self startAction];
            _isShutDown = NO;
            _isload = YES;
        }
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = endFrame.origin.y;
    
    if ([self.subWindow isKeyWindow]) {
        if (y == KScreenHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.subWindow.top = KScreenHeight - 290.f;
                self.subWindow.height = 290.f;
            }];
        } else  {
            [UIView animateWithDuration:0.3 animations:^{
                self.subWindow.top = 0;
                self.subWindow.height = KScreenHeight;
            }];
        }
    }
}


@end
