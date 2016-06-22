//
//  ViewController.m
//  H264EncodeProject
//
//  Created by yisanmao on 15-3-18.
//  Copyright (c) 2015年 yisanmao. All rights reserved.
//



/**
 *  注意 关于推流路径和播放路径设置
 *  要修改textField中的推流ID同时保证推流端和播放端的ID是一样的，不能多个手机使用一个推流路径，可以多个手机播放一个路径
 */


#import "ViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "FilterManager.h"
#import "sys/utsname.h"
#import "NSString+UCloudCameraCode.h"


#define SysVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL isload;
    BOOL isShutDown;
    UCloudGPUImageView *_frontImageView;
    
    UIView *blackView;
}
@property (weak, nonatomic) IBOutlet UIButton    *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton    *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton    *playBtn;
@property (weak, nonatomic) IBOutlet UITextField *pathTextField;
@property (weak, nonatomic) IBOutlet UILabel     *ptsLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *sysVerLabel;
@property (weak, nonatomic) IBOutlet UISlider    *slider;
@property (weak, nonatomic) IBOutlet UIButton    *changeBtn;
@property (weak, nonatomic) IBOutlet UILabel *port;
@property (weak, nonatomic) IBOutlet UIButton *btnShutdown;

@property (strong, nonatomic) UIPickerView    *pickerView;
@property (strong, nonatomic) NSMutableArray  *filters;
@property (strong, nonatomic) FilterManager   *filterManager;
@property (strong, nonatomic) UIView          *videoView;
@property (strong, nonatomic) NSString        *pathStr;
@property (strong, nonatomic) AVCaptureDevice *currentDev;
@property (assign, nonatomic) BOOL            shouldAutoStarted;

@property (strong, nonatomic) NSTimer *timer;

- (IBAction)btnShutdownTouchUpInside:(id)sender;


@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UCloudMoviePlayerClickBack object:nil];
    
    
    
    srand((unsigned)time(NULL));
    NSInteger num = rand()%10000;
//    NSInteger num = 4000;
    self.pathTextField.text = [NSString stringWithFormat:@"%ld", (long)num];
    struct utsname systemInfo;
    uname(&systemInfo);
    self.modelLabel.adjustsFontSizeToFitWidth = YES;
    self.modelLabel.text =  [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];//[[UIDevice currentDevice] model];
    self.sysVerLabel.text =  [[UIDevice currentDevice] systemVersion];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(screenFrame.size.width - 200 - 8, 150, 200, 100)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [self.view addSubview:pickerView];
    self.pickerView = pickerView;
    [self setBtnStateInSel:1];
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

- (void)setBtnStateInSel:(NSInteger)num
{
    if (num == 1)
    {
        //初始状态
        self.recordBtn.hidden     = NO;
        self.stopBtn.hidden       = YES;
        self.playBtn.hidden       = NO;
        self.ptsLabel.hidden      = YES;
        self.port.hidden          = YES;
        self.pathTextField.hidden = NO;
        self.slider.hidden        = YES;
        self.pickerView.hidden    = YES;
        self.changeBtn.hidden     = YES;
        self.btnShutdown.hidden     = YES;
    }
    else if (num == 2)
    {
        //选择play
        self.recordBtn.hidden     = YES;
        self.stopBtn.hidden       = YES;
        self.playBtn.hidden       = YES;
        self.ptsLabel.hidden      = YES;
        self.port.hidden          = YES;
        self.pathTextField.hidden = YES;
        self.slider.hidden        = YES;
        self.pickerView.hidden    = YES;
        self.changeBtn.hidden     = YES;
        self.codeLabel.hidden     = YES;
        self.modelLabel.hidden    = YES;
        self.sysVerLabel.hidden   = YES;
        self.btnShutdown.hidden   = NO;
    }
    else if (num == 3)
    {
        //选择camera
        self.recordBtn.hidden     = YES;
        self.stopBtn.hidden       = NO;
        self.playBtn.hidden       = YES;
        self.ptsLabel.hidden      = NO;
        self.codeLabel.hidden     = NO;
        self.modelLabel.hidden    = NO;
        self.sysVerLabel.hidden   = NO;
        self.port.hidden          = NO;
        self.pathTextField.hidden = YES;
        self.slider.hidden        = NO;
        self.changeBtn.hidden     = NO;
        self.btnShutdown.hidden   = YES;
        if (self.filters.count > 0)
        {
            self.pickerView.hidden = NO;
            self.slider.hidden     = NO;
        }
        else
        {
            self.pickerView.hidden = YES;
            self.slider.hidden     = YES;
        }
    }
}

- (BOOL)checkPath
{
    if (self.pathTextField.text.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Path can not null" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView becomeFirstResponder];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - 录制

- (IBAction)record:(id)sender
{
    self.port.text = [NSString stringWithFormat:@"streamID:%@", self.pathTextField.text];
    [self addNoti];
    self.shouldAutoStarted = YES;
    if (self.filterManager)
    {
        //        [self.videoView removeFromSuperview];
        //        self.videoView = nil;
    }
    
    if ([self checkPath])
    {
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
        [self.pickerView reloadAllComponents];
        
        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
        
        [[CameraServer server] setSecretkey:CGIKey];
        //11.4  4.05 2.05 1.75
        [[CameraServer server] setBitrate:3.05];
        //UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"注意" message:@"网络带宽不够，建议降低fps、分辨率" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        NSString *path = RecordDomain(self.pathTextField.text);
        
        __weak ViewController *weakSelf = self;
        
        self.recordBtn.enabled = NO;
        NSArray *filters = [self.filterManager filters];
        [[CameraServer server] configureCameraWithOutputUrl:path
                                                     filter:filters
                                            messageCallBack:^(UCloudCameraCode code, NSInteger arg1, NSInteger arg2, id data){
                                                
                                                //                                                NSLog(@"%s_code:%ld arg1:%ld arg2:%ld", __func__, (long)code, (long)arg1, (long)arg2);
                                                
                                                NSString *codeStr = [NSString stringWithFormat:@"%ld",(unsigned long)code];
                                                
                                                
                                                self.codeLabel.text = [NSString stringWithFormat:@"state:%@",[codeStr cameraCodeToMessage]];
                                                
                                                if (code == UCloudCamera_BUFFER_OVERFLOW)
                                                {
                                                    static BOOL viewShowed = NO;
                                                    if (arg1 == 1 && !viewShowed)
                                                    {
                                                        //                                                        [view show];
                                                        viewShowed = YES;
                                                    }
                                                    else
                                                    {
                                                        if (viewShowed)
                                                        {
                                                            //                                                            [view dismissWithClickedButtonIndex:0 animated:YES];
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
                                                    //                                                    [blackView removeFromSuperview];
                                                    [self.videoView removeFromSuperview];
                                                    self.videoView = nil;
                                                    [weakSelf startPreview];
                                                }
                                                else if (code == UCloudCamera_PublishOk)
                                                {
                                                    [[CameraServer server] cameraStart];
                                                    [weakSelf setBtnStateInSel:3];
                                                    weakSelf.recordBtn.enabled = YES;
                                                    
                                                    [weakSelf.filterManager setCurrentValue:weakSelf.filters];
                                                }
                                                else if (code == UCloudCamera_StartPublish)
                                                {
                                                    weakSelf.recordBtn.enabled = YES;
                                                }
                                                else if (code == UCloudCamera_Permission)
                                                {
                                                    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"相机授权" message:@"没有权限访问您的相机，请在“设置－隐私－相机”中允许使用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                                                    [alterView show];
                                                    weakSelf.recordBtn.enabled = YES;
                                                }
                                                else if (code == UCloudCamera_Micphone)
                                                {
                                                    [[[UIAlertView alloc] initWithTitle:@"麦克风授权" message:@"没有权限访问您的麦克风，请在“设置－隐私－麦克风”中允许使用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil] show];
                                                    weakSelf.recordBtn.enabled = YES;
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
                                                        
                                                        [weakSelf pickerView:weakSelf.pickerView didSelectRow:0 inComponent:0];
                                                    }
                                                    
                                                }cameraData:^CMSampleBufferRef(CMSampleBufferRef buffer) {
                                                    /**
                                                     *  若果不需要裸流，不建议在这里执行操作，讲增加额外的功耗
                                                     */
                                                    
                                                    return nil;
                                                }];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        if (!self.timer)
        {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getBitRate) userInfo:nil repeats:YES];
        }
    }
}

- (IBAction)stopCamera:(id)sender
{
    self.shouldAutoStarted = NO;
    self.stopBtn.enabled = NO;
    __weak ViewController *weakSelf = self;
    [self.timer invalidate];
    self.timer = nil;
    [[CameraServer server] shutdown:^{
        if (weakSelf.videoView)
        {
            [weakSelf.videoView removeFromSuperview];
        }
        weakSelf.videoView = nil;
        
        self.stopBtn.enabled = YES;
        [weakSelf setBtnStateInSel:1];
    }];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self removeNoti];
}

- (IBAction)changeCamera:(id)sender
{
    self.changeBtn.enabled = NO;
    [[CameraServer server] changeCamera];
    self.changeBtn.enabled = YES;
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    //    NSLog(@"value:%f", sender.value);
    NSDictionary *info = [self.filters objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    NSMutableDictionary *mutableInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    mutableInfo[@"current"] = @(sender.value);
    [self.filters replaceObjectAtIndex:[self.filters indexOfObject:info] withObject:mutableInfo];
    
    NSString *name = info[@"type"];
    float a = sender.value;
    //    if ([name isEqualToString:@"ISO"])
    //    {
    //        [[CameraServer server] changeISO:a];
    //    }
    //    else
    //    {
    [self.filterManager valueChange:name value:a];
    //    }
}

- (void)getBitRate
{
    NSString *str = [[CameraServer server] biteRate];
    self.ptsLabel.text = [NSString stringWithFormat:@"bitrate:%@", str];
}

- (void) startPreview
{
    UIView *cameraView = [[CameraServer server] getCameraView];
    cameraView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cameraView];
    [self.view sendSubviewToBack:cameraView];
    self.videoView = cameraView;
}

#pragma mark - picker view
- (void)buildData
{
    self.filters = [self.filterManager buildData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.filters.count;
}

//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSDictionary *info = [self.filters objectAtIndex:row];
//    return info[@"name"];
//}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSDictionary *info = [self.filters objectAtIndex:row];
    NSString *title = info[@"name"];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    
    return attString;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.filters.count > row)
    {
        NSDictionary *info = [self.filters objectAtIndex:row];
        float min                = [info[@"min"] floatValue];
        float max                = [info[@"max"] floatValue];
        float current            = [info[@"current"] floatValue];
        
        self.slider.minimumValue = min;
        self.slider.maximumValue = max;
        self.slider.value        = current;
    }
}

#pragma mark - 播放
- (IBAction)play:(id)sender
{
    if ([self checkPath])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        delegate.vc = self;
        self.playerManager = [[PlayerManager alloc] init];
        self.playerManager.view = self.view;
        self.playerManager.viewContorller = self;
        //        [self.playerManager setSupportAutomaticRotation:YES];
        //        [self.playerManager setSupportAngleChange:YES];
        float height = self.view.frame.size.height;
        [self.playerManager setPortraitViewHeight:height];
        [self.playerManager buildMediaPlayer:self.pathTextField.text];
        [self setBtnStateInSel:2];
    }
    [self.view bringSubviewToFront:_btnShutdown];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.playerManager)
    {
        return self.playerManager.supportInterOrtation;
    }
    else
    {
        /**
         *  这个在播放之外的程序支持的设备方向
         */
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.playerManager rotateEnd];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.playerManager rotateBegain:toInterfaceOrientation];
}

- (void)noti:(NSNotification *)noti
{
    NSLog(@"noti name :%@",noti.name);
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if ([noti.name isEqualToString:UCloudMoviePlayerClickBack])
    {
        self.playerManager = nil;
        [self setBtnStateInSel:1];
    }
    else if ([noti.name isEqualToString:UCloudNeedRestart])
    {
        if (self.shouldAutoStarted)
        {
            NSLog(@"restart");
            [self record:nil];
        }
    }
    else if ([noti.name isEqualToString:UIApplicationDidEnterBackgroundNotification] || [noti.name isEqualToString:UIApplicationWillResignActiveNotification])
    {
        while (!isShutDown) {
            [[CameraServer server] shutdown:^{
//                _frontImageView = [[CameraServer server] createBlurringScreenshot];
//                [self.view addSubview:_frontImageView];
//                _frontImageView.alpha = 1;
                blackView = [[UIView alloc]initWithFrame:self.videoView.frame];
                blackView.backgroundColor = [UIColor blackColor];
                [self.videoView addSubview:blackView];
                
                UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]init];
                activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
                activity.center = blackView.center;
                [activity startAnimating];
                [blackView addSubview:activity];
                
            }];
//            [[CameraServer server] cameraPause];
            isShutDown = YES;
        }
        isload = NO;
    }
    else if ([noti.name isEqualToString:UIApplicationDidBecomeActiveNotification])
    {
        while (!isload) {
            
            [self record:nil];
//            [UIView animateWithDuration:3.0 animations:^{
//                _frontImageView.alpha = 0;
//            } completion:^(BOOL finished) {
//                [_frontImageView removeFromSuperview];
//            }];
//            [[CameraServer server] cameraResuse];
            isShutDown = NO;
            isload = YES;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.pathTextField isFirstResponder])
    {
        [self.pathTextField resignFirstResponder];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UCloudMoviePlayerClickBack object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnShutdownTouchUpInside:(id)sender
{
    [self.playerManager.mediaPlayer.player.view removeFromSuperview];
    [self.playerManager.controlVC.view removeFromSuperview];
    [self.playerManager.mediaPlayer.player shutdown];
    self.playerManager.mediaPlayer = nil;
    
    {
        self.playerManager.supportInterOrtation = UIInterfaceOrientationMaskPortrait;
        [self.playerManager awakeSupportInterOrtation:self.playerManager.viewContorller completion:^{
            self.playerManager.supportInterOrtation = UIInterfaceOrientationMaskAllButUpsideDown;
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UCloudMoviePlayerClickBack object:self.playerManager];
    
}
@end
