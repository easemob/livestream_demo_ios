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
#import "PlayerManager.h"
#import "FilterManager.h"
#import "EaseChatView.h"
#import "EaseTextView.h"
#import "UIViewController+DismissKeyboard.h"
#import "EaseParseManager.h"
#import "PFObject.h"
#import "EaseHeartFlyView.h"
#import "EaseGiftFlyView.h"
#import "EaseBarrageFlyView.h"

#define kDefaultStreamId @"1111"

@interface EasePublishViewController () <EaseChatViewDelegate,UITextViewDelegate>
{
    BOOL _isload;
    BOOL _isShutDown;
    
    UIView *_blackView;
    NSTimer *_burstTimer;
}

//发布直播
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *changeBtn;
@property (nonatomic, strong) UIView *publishView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) EaseTextView *pathTextField;

//直播相关
@property (strong, nonatomic) PlayerManager *playerManager;
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
    
    [self.view addSubview:self.publishView];
    [self.publishView addSubview:self.headImageView];
    [self.publishView addSubview:self.startButton];
    [self.publishView addSubview:self.pathTextField];
    [self.view addSubview:self.chatview];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.changeBtn];
    [self setBtnStateInSel:1];
    
//    self.streamId = [NSString stringWithFormat:@"%@",@((long long)([[NSDate date] timeIntervalSince1970]*1000))];
    self.streamId = @"em_10001";
    [self startAction];
}

- (void)dealloc
{
    [_burstTimer invalidate];
    _burstTimer = nil;
}

- (UIView*)publishView
{
    if (_publishView == nil) {
        _publishView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 200)];
        _publishView.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.view.bounds)-10, 1)];
        line.backgroundColor = RGBACOLOR(255, 255, 255, 0.5);
        [_publishView addSubview:line];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.headImageView.frame) + 10.f, CGRectGetWidth(self.view.bounds)-10, 1)];
        line2.backgroundColor = RGBACOLOR(255, 255, 255, 0.5);
        [_publishView addSubview:line2];
    }
    return _publishView;
}

- (EaseChatView*)chatview
{
    if (_chatview == nil) {
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 230, CGRectGetWidth(self.view.bounds), 260) chatroomId:@"203138578711052716" isPublish:YES];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (UIImageView*)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(10, 10, 120, 120);
        _headImageView.image = [UIImage imageNamed:@"1"];
        _headImageView.layer.masksToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headImageView;
}

- (EaseTextView*)pathTextField
{
    if (_pathTextField == nil) {
        _pathTextField = [[EaseTextView alloc] init];
        _pathTextField.placeHolder = @"输入标题更吸引粉丝";
        _pathTextField.textAlignment = NSTextAlignmentLeft;
        _pathTextField.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 5, CGRectGetMinY(self.headImageView.frame) , CGRectGetWidth(self.view.frame) - 20 - CGRectGetWidth(self.headImageView.frame), 150);
        _pathTextField.backgroundColor = [UIColor clearColor];
        _pathTextField.returnKeyType = UIReturnKeyDone;
        _pathTextField.delegate = self;
    }
    return _pathTextField;
}

- (UIButton*)startButton
{
    if (_startButton == nil) {
        _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _startButton.frame = CGRectMake(60, CGRectGetMaxY(self.headImageView.frame) + 20, CGRectGetWidth(self.view.frame) - 120, 40);
        [_startButton setBackgroundColor:RGBACOLOR(0xfe, 0x64, 0x50, 1)];
        [_startButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
        _startButton.layer.cornerRadius = 5.f;
    }
    return _startButton;
}

- (UIButton*)changeBtn
{
    if (_changeBtn == nil) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.frame = CGRectMake(10, 20, 40, 40);
        _changeBtn.titleLabel.font = [UIFont fontWithName:kEaseDefaultIconFont size:40];
        [_changeBtn setTitle:kEaseCameraButton forState:UIControlStateNormal];
//        [_changeBtn setImage:[UIImage imageNamed:@"live_rotate_top_pressed"] forState:UIControlStateHighlighted];
//        [_changeBtn setImage:[UIImage imageNamed:@"live_rotate_top"] forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeBtn;
}

- (UIButton*)closeBtn
{
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(KScreenWidth - 50, 20, 40, 40);
        _closeBtn.titleLabel.font = [UIFont fontWithName:kEaseDefaultIconFont size:40];
        [_closeBtn setTitle:kEaseCloseButton forState:UIControlStateNormal];
//        [_closeBtn setImage:[UIImage imageNamed:@"live_close_top_pressed"] forState:UIControlStateHighlighted];
//        [_closeBtn setImage:[UIImage imageNamed:@"live_close_top"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(stopCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

-(void)showTheLoveAction
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [self.chatview addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), CGRectGetHeight(self.chatview.frame) - 60);
    heart.center = fountainSource;
    [heart animateInView:self.chatview];
}

- (void)changeAction
{
    [[CameraServer server] changeCamera];
}

//停止直播
- (void)stopCameraAction
{
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
        
        self.closeBtn.enabled = YES;
        [weakSelf setBtnStateInSel:1];
    }];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self removeNoti];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.chatview leaveChatroom];
    });
    [[EaseParseManager sharedInstance] closePublishLiveInBackgroundWithCompletion:NULL];
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    if (![self checkPath]) {
        return;
    }
    
    __weak EasePublishViewController *weakSelf = self;
    [self showHudInView:self.view hint:@"发布直播"];
    [[EaseParseManager sharedInstance] publishLiveInBackgroundWithText:self.pathTextField.text
                                                              streamId:self.streamId
                                                            completion:^(PFObject *pfuser, NSError *error) {
        [weakSelf hideHud];
        if (pfuser) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf.chatview joinChatroom];
            });
            [weakSelf setBtnStateInSel:2];
        } else {
            [weakSelf showHint:@"发布失败"];
        }
    }];
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
                                                [[CameraServer server] cameraStart];
                                                weakSelf.startButton.enabled = YES;
                                                
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

#pragma mark - EaseChatViewDelegate

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight
{
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

- (void)didPressPrintScreenButton
{
    
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

#pragma mark - private

- (void)startPreview
{
    UIView *cameraView = [[CameraServer server] getCameraView];
    cameraView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cameraView];
    [self.view sendSubviewToBack:cameraView];
    self.videoView = cameraView;
}

- (BOOL)checkPath
{
    if (self.pathTextField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入标题" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView becomeFirstResponder];
        return NO;
    } else {
        return YES;
    }
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
        self.publishView.hidden = NO;
        self.chatview.hidden = YES;
    } else {
        self.publishView.hidden = YES;
        [self.pathTextField resignFirstResponder];
        self.chatview.hidden = NO;
    }
}


- (void)noti:(NSNotification *)noti
{
    NSLog(@"noti name :%@",noti.name);
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if ([noti.name isEqualToString:UCloudMoviePlayerClickBack]) {
        self.playerManager = nil;
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


@end
