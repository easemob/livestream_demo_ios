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
#import "FilterManager.h"
#import "EaseChatView.h"
#import "EaseTextView.h"
#import "EaseHeartFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "EaseEndLiveView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveCastView.h"
#import "EaseAdminView.h"
#import "UIViewController+DismissKeyboard.h"
#import "EaseLiveRoom.h"
#import "EaseCreateLiveViewController.h"

#define kDefaultTop 30.f
#define kDefaultLeft 10.f

@interface EasePublishViewController () <EaseChatViewDelegate,UITextViewDelegate,EMChatroomManagerDelegate,EaseEndLiveViewDelegate,TapBackgroundViewDelegate,EaseLiveHeaderListViewDelegate,EaseProfileLiveViewDelegate,UIAlertViewDelegate,EMClientDelegate>
{
    BOOL _isload;
    BOOL _isShutDown;
    
    UIView *_blackView;
    
    BOOL _isPublish;
    
    EaseLiveRoom *_room;
}

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;
@property (nonatomic, strong) EaseEndLiveView *endLiveView;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UIWindow *subWindow;

//直播相关
@property (strong, nonatomic) FilterManager *filterManager;
@property (strong, nonatomic) NSMutableArray *filters;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) AVCaptureDevice *currentDev;
@property (nonatomic, assign) BOOL shouldAutoStarted;

@property (strong, nonatomic) UITapGestureRecognizer *singleTapGR;

//聊天室
@property (strong, nonatomic) EaseChatView *chatview;

@end

@implementation EasePublishViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room
{
    self = [super init];
    if (self) {
        _room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    [self.view addSubview:self.closeBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self setupForDismissKeyboard];
    
    [self.view addSubview:self.chatview];
    [self.view addSubview:self.headerListView];
    [self.chatview joinChatroomWithIsCount:NO
                                completion:^(BOOL success) {
                                    if (success) {
                                        [self.headerListView loadHeaderListWithChatroomId:_room.chatroomId];
                                    }
                                }];
    [self.view addSubview:self.roomNameLabel];
    [self.view layoutSubviews];
    [self setBtnStateInSel:1];
    [self startAction];
}

- (void)dealloc
{
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient] removeDelegate:self];
    
    _chatview.delegate = nil;
    
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
        _endLiveView = [[EaseEndLiveView alloc] initWithUsername:[EMClient sharedClient].currentUsername audience:@"265381人看过"];
        _endLiveView.delegate = self;
    }
    return _endLiveView;
}

- (EaseLiveHeaderListView*)headerListView
{
    if (_headerListView == nil) {
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, KScreenWidth - 50, 30.f) room:_room];
        _headerListView.delegate = self;
    }
    return _headerListView;
}

- (UILabel*)roomNameLabel
{
    if (_roomNameLabel == nil) {
        _roomNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 69.f, KScreenWidth - 20.f, 15)];
        _roomNameLabel.text = [NSString stringWithFormat:@"%@: %@" ,NSLocalizedString(@"live.room.name", @"Room ID") ,_room.roomId];
        _roomNameLabel.font = [UIFont systemFontOfSize:12.f];
        _roomNameLabel.textAlignment = NSTextAlignmentRight;
        _roomNameLabel.textColor = [UIColor whiteColor];
    }
    return _roomNameLabel;
}

- (EaseChatView*)chatview
{
    if (_chatview == nil) {
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 200, CGRectGetWidth(self.view.bounds), 200) room:_room isPublish:YES];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (UIButton*)closeBtn
{
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(KScreenWidth - 40, kDefaultTop, 30, 30);
        [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeLiveAction) forControlEvents:UIControlEventTouchUpInside];
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

//点击屏幕点赞特效
-(void)showTheLoveAction
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [_chatview addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), _chatview.height);
    heart.center = fountainSource;
    [heart animateInView:_chatview];
}

- (void)changeAction
{
    [[CameraServer server] changeCamera];
}

- (void)closeLiveAction
{
    [self stopCameraAction];
}

//停止直播
- (void)stopCameraAction
{
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] getLiveRoomCurrentWithRoomId:_room.roomId
                                                        completion:^(EaseLiveSession *session, BOOL success) {
                                                            if (success) {
                                                                [weakSelf _shutDownLive];
                                                                [weakSelf.endLiveView setAudience:[NSString stringWithFormat:@"%ld%@",(long)session.totalWatchCount,NSLocalizedString(@"endview.live.watch", @" Watched")]];
                                                                [self.view addSubview:self.endLiveView];
                                                                [self.view bringSubviewToFront:self.endLiveView];
                                                            }
                                                        }];
}

//切换摄像头
- (void)changeCameraAction
{
    [[CameraServer server] changeCamera];
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
    
    [[CameraServer server] setSecretKey:CGIKey];
    //11.4  4.05 2.05 1.75
    [[CameraServer server] setBitrate:UCloudVideoBitrateLow];
    //
    NSString *path = _room.session.mobilepushstream;
    
    __weak EasePublishViewController *weakSelf = self;
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
                                                [[CameraServer server] cameraPrepare];
                                                [weakSelf.filterManager setCurrentValue:weakSelf.filters];
                                                [weakSelf.closeBtn addTarget:self action:@selector(closeLiveAction) forControlEvents:UIControlEventTouchUpInside];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf setBtnStateInSel:2];
                                                });
                                                [[CameraServer server] cameraStart];
                                            }
                                            else if (code == UCloudCamera_StartPublish)
                                            {
                                                _isPublish = YES;
                                            }
                                            else if (code == UCloudCamera_Permission)
                                            {
                                                UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"相机授权" message:@"没有权限访问您的相机，请在“设置－隐私－相机”中允许使用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                                                [alterView show];
                                            }
                                            else if (code == UCloudCamera_Micphone)
                                            {
                                                [[[UIAlertView alloc] initWithTitle:@"麦克风授权" message:@"没有权限访问您的麦克风，请在“设置－隐私－麦克风”中允许使用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
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
}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.subWindow isKeyWindow]) {
        [self closeAction];
        return;
    }
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:username
                                                                              chatroomId:_room.chatroomId
                                                                                 isOwner:YES];
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
    __weak EasePublishViewController *weakSelf = self;
    
    dispatch_block_t block = ^{
        [weakSelf.chatview leaveChatroomWithIsCount:NO
                                         completion:^(BOOL success) {
                                             if (success) {
                                                 [[EMClient sharedClient].chatManager deleteConversation:_room.chatroomId isDeleteMessages:YES completion:NULL];
                                             } else {
                                                 [weakSelf showHint:@"退出聊天室失败"];
                                             }
                                             if (weakSelf.videoView)
                                             {
                                                 [weakSelf.videoView removeFromSuperview];
                                             }
                                             weakSelf.videoView = nil;
                                             weakSelf.closeBtn.enabled = YES;
                                             
                                             [UIApplication sharedApplication].idleTimerDisabled = NO;
                                             [weakSelf removeNoti];
                                             [weakSelf dismissViewControllerAnimated:YES completion:^{
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshList object:@(YES)];
                                             }];
                                         }];
    };
    
    [[EaseHttpManager sharedInstance] modifyLiveRoomStatusWithRoomId:_room.roomId
                                                              status:EaseLiveSessionCompleted
                                                          completion:^(BOOL success) {
                                                              if (!success) {
                                                                  [weakSelf showHint:@"更新失败"];
                                                              }
                                                              block();
                                                          }];
    
    self.shouldAutoStarted = NO;
    self.closeBtn.enabled = NO;
}

- (void)didClickContinueButton
{
    [self _recoverLive];
}

#pragma mark - EaseChatViewDelegate

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight
{
    if ([self.subWindow isKeyWindow]) {
        return;
    }
    
    if (toHeight == 200) {
        [self.view removeGestureRecognizer:self.singleTapGR];
    } else {
        [self.view addGestureRecognizer:self.singleTapGR];
    }
    
    if (!self.chatview.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.chatview.frame;
            rect.origin.y = self.view.frame.size.height - toHeight;
            self.chatview.frame = rect;
        }];
    }
}

- (void)didReceivePraiseWithCMDMessage:(EMMessage *)message
{
    [self showTheLoveAction];
}

- (void)didSelectUserWithMessage:(EMMessage *)message
{
    [self.view endEditing:YES];
    EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:message.from
                                                                              chatroomId:_room.chatroomId
                                                                                 isOwner:YES];
    profileLiveView.profileDelegate = self;
    profileLiveView.delegate = self;
    [profileLiveView showFromParentView:self.view];
}

- (void)didSelectChangeCameraButton
{
    [[CameraServer server] changeCamera];
}

- (void)didSelectAdminButton:(BOOL)isOwner
{
    EaseAdminView *adminView = [[EaseAdminView alloc] initWithChatroomId:_room.chatroomId
                                                                 isOwner:isOwner];
    adminView.delegate = self;
    [adminView showFromParentView:self.view];
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

#pragma mark - EMChatroomManagerDelegate

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if (![aChatroom.owner isEqualToString:aUsername]) {
            [_headerListView joinChatroomWithUsername:aUsername];
        }
    }
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if (![aChatroom.owner isEqualToString:aUsername]) {
            [_headerListView leaveChatroomWithUsername:aUsername];
        }
    }
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMutes) {
            [text appendString:name];
        }
        [self showHint:[NSString stringWithFormat:@"禁言成员:%@",text]];
    }
}

- (void)chatroomMuteListDidUpdate:(EMChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMutes) {
            [text appendString:name];
        }
        [self showHint:[NSString stringWithFormat:@"解除禁言:%@",text]];
    }
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"聊天室创建者有更新:%@",aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self didClickEndButton];
        }];
        
        [alert addAction:ok];
    }
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"被踢出直播聊天室" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    [self _shutDownLive];
    [self didClickEndButton];
}

#pragma mark - EMClientDelegate

- (void)userAccountDidLoginFromOtherDevice
{
    [self _shutDownLive];
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
        self.chatview.hidden = YES;
        self.headerListView.hidden = YES;
    } else {
        self.chatview.hidden = NO;
        self.headerListView.hidden = NO;
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
        [self _shutDownLive];
    }
    else if ([noti.name isEqualToString:UIApplicationDidBecomeActiveNotification])
    {
        [self _recoverLive];
    }
}

- (void)_shutDownLive;
{
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

- (void)_recoverLive
{
    while (!_isload) {
        [self startAction];
        _isShutDown = NO;
        _isload = YES;
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

#pragma mark - override

- (void)setupForDismissKeyboard
{
    _singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(tapAnywhereToDismissKeyboard:)];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
    [self.chatview endEditing:YES];
}

@end
