//
//  EasePublishViewController.m
//
//  Created by EaseMob on 16/6/3.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EasePublishViewController.h"

#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "EaseChatView.h"
#import "EaseHeartFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveCastView.h"
#import "EaseAdminView.h"
#import "EaseLiveRoom.h"
#import "EaseAnchorCardView.h"
#import "EaseCreateLiveViewController.h"
#import "EaseDefaultDataHelper.h"
#import "EaseAudienceBehaviorView.h"
#import "EaseGiftListView.h"
#import "EaseCustomMessageHelper.h"
#import "EaseFinishLiveView.h"
#import "EaseCustomMessageHelper.h"
#import "EaseLiveViewController.h"

#import <PLMediaStreamingKit/PLMediaStreamingKit.h>
#import "PLPermissionRequestor.h"

#import <AgoraRtcKit/AgoraRtcEngineKit.h>

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import <CallKit/CXCallObserver.h>

#define kDefaultTop 35.f
#define kDefaultLeft 10.f

@interface EasePublishViewController () <EaseChatViewDelegate,UITextViewDelegate,EMChatroomManagerDelegate,TapBackgroundViewDelegate,EaseLiveHeaderListViewDelegate,EaseProfileLiveViewDelegate,UIAlertViewDelegate,EMClientDelegate,EaseCustomMessageHelperDelegate,PLMediaStreamingSessionDelegate,AgoraRtcEngineDelegate>
{
    BOOL _isload;
    BOOL _isShutDown;
    
    UIView *_blackView;
    
    BOOL _isPublish;
    
    BOOL _isAllMute;
    
    BOOL _isFinishBroadcast;
        
    NSInteger _praiseNum;//赞
    NSInteger _giftsNum;//礼物份数
    NSInteger _totalGifts;//礼物合计总数
    
    EaseCustomMessageHelper *_customMsgHelper;//自定义消息帮助
    
    NSURL *_streamCloudURL;
    NSURL *_streamURL;
    
    PLVideoCaptureConfiguration *videoCaptureConfiguration;
    PLAudioCaptureConfiguration *audioCaptureConfiguration;
    PLVideoStreamingConfiguration *videoStreamingConfiguration;
    PLAudioStreamingConfiguration *audioStreamingConfiguration;
}

@property (nonatomic, strong) EaseLiveRoom *room;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UIWindow *subWindow;

@property (strong, nonatomic) UITapGestureRecognizer *singleTapGR;

//聊天室
@property (strong, nonatomic) EaseChatView *chatview;
@property(nonatomic,strong) UIImageView *backImageView;

//七牛媒体流
@property (nonatomic, strong) PLMediaStreamingSession *session;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *agoraLocalVideoView;

@property (nonatomic, strong) CTCallCenter *callCenter;

@end

@implementation EasePublishViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room
{
    self = [super init];
    if (self) {
        _room = room;
        _customMsgHelper = [[EaseCustomMessageHelper alloc]initWithCustomMsgImp:self chatId:_room.chatroomId];
        _praiseNum = [EaseDefaultDataHelper.shared.praiseStatisticstCount intValue];
        _giftsNum = [EaseDefaultDataHelper.shared.giftNumbers intValue];
        _totalGifts = [EaseDefaultDataHelper.shared.totalGifts intValue];
        _isFinishBroadcast = NO;
        EaseDefaultDataHelper.shared.currentRoomId = _room.roomId;
        [EaseDefaultDataHelper.shared archive];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.view insertSubview:self.backImageView atIndex:0];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self setupForDismissKeyboard];
    
    [self.view addSubview:self.headerListView];
    [self.view addSubview:self.chatview];
    [self.chatview joinChatroomWithIsCount:NO
                                completion:^(BOOL success) {
                                    if (success) {
                                        [self.headerListView loadHeaderListWithChatroomId:_room.chatroomId];
                                    }
                                }];
    //[self.view addSubview:self.roomNameLabel];
    [self.view layoutSubviews];
    [self setBtnStateInSel:0];
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
        [self _setupAgoreKit];
    }
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
        [self _prepareForCameraSetting];
        [self actionPushStream];
        [self monitorCall];
    }
}

- (void)dealloc
{
    /**
     @property (nonatomic, strong) NSString *praiseStatisticstCount;//点赞统计
     @property (nonatomic, strong) NSMutableDictionary *giftStatisticsCount;//礼物统计
     @property (nonatomic, strong) NSMutableArray *rewardCount;//打赏人列表
     @property (nonatomic, strong) NSString *giftNumbers;//礼物份数
     @property (nonatomic, strong) NSString *totalGifts;//礼物总数合计
     */
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient] removeDelegate:self];
    [_headerListView stopTimer];
    _chatview.delegate = nil;
    
    EaseDefaultDataHelper.shared.praiseStatisticstCount = @"";
    [EaseDefaultDataHelper.shared.giftStatisticsCount removeAllObjects];
    [EaseDefaultDataHelper.shared.rewardCount removeAllObjects];
    EaseDefaultDataHelper.shared.giftNumbers = @"";
    EaseDefaultDataHelper.shared.totalGifts = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.chatview endEditing:YES];
}

//检测来电
- (void)monitorCall
{
    __weak typeof(self) weakSelf = self;
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"电话结束或挂断电话");
            [weakSelf connectionStateDidChange:EMConnectionConnected];
        } else if (call.callState == CTCallStateConnected){
            NSLog(@"电话接通");
        } else if(call.callState == CTCallStateIncoming) {
            NSLog(@"来电话");
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                [weakSelf.agoraKit muteLocalVideoStream:YES];
                [weakSelf.agoraKit muteLocalAudioStream:YES];
            }
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
                [weakSelf.session stopStreaming];
            }
        } else if (call.callState ==CTCallStateDialing) {
            NSLog(@"拨号打电话(在应用内调用打电话功能)");
        }
    };
}

- (void)_setupAgoreKit
{
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"b79a23d7b1074ed9b0c756c63fd4fa81" delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster options:nil];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    [self _setupLocalVideo];
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
            [weakSelf.agoraKit muteAllRemoteAudioStreams:YES];
            [weakSelf.agoraKit muteAllRemoteVideoStreams:YES];
        }];
    }];
}

- (void)_setupLocalVideo {
    self.agoraLocalVideoView = [[UIView alloc]init];
    self.agoraLocalVideoView.frame = self.view.bounds;
    [self.view insertSubview:self.agoraLocalVideoView atIndex:0];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    videoCanvas.view = self.agoraLocalVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    // 设置本地视图。
    [self.agoraKit setupLocalVideo:videoCanvas];
}

#pragma mark - AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine connectionChangedToState:(AgoraConnectionStateType)state reason:(AgoraConnectionChangedReason)reason
{
    if (reason == AgoraConnectionChangedTokenExpired || reason == AgoraConnectionChangedInvalidToken) {
        __weak typeof(self) weakSelf = self;
        [self fetchAgoraRtcToken:^(NSString *rtcToken) {
            [weakSelf.agoraKit renewToken:rtcToken];
        }];
    }
    if (state == AgoraConnectionStateConnected) {
        [self.backImageView removeFromSuperview];
        [self.view insertSubview:self.agoraLocalVideoView atIndex:0];
    }
    if (state == AgoraConnectionStateConnecting || state == AgoraConnectionStateReconnecting) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在连接..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
        [self.agoraLocalVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
    }
    if (state == AgoraConnectionStateFailed) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"连接失败,请重新创建直播间。" toView:self.view];
        [self.agoraLocalVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:2.0];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine tokenPrivilegeWillExpire:(NSString *)token
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken) {
        [weakSelf.agoraKit renewToken:rtcToken];
    }];
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        }];
    }];
}

- (void)fetchAgoraRtcToken:(void (^)(NSString *rtcToken))aCompletionBlock;
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString* strUrl = [NSString stringWithFormat:@"http://a1.easemob.com/token/liveToken?userAccount=%@&channelName=%@&appkey=%@&uid=%d",[EMClient sharedClient].currentUsername, _room.channel, [EMClient sharedClient].options.appkey, 0];
    NSString*utf8Url = [strUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:utf8Url];
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlReq setValue:[NSString stringWithFormat:@"Bearer %@",[EMClient sharedClient].accessUserToken ] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data) {
            NSDictionary* body = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@",body);
            if(body) {
                NSString* resCode = [body objectForKey:@"code"];
                if([resCode isEqualToString:@"RES_0K"]) {
                    NSString* rtcToken = [body objectForKey:@"accessToken"];
                    if (aCompletionBlock)
                        aCompletionBlock(rtcToken);
                }
            }
        }
    }];

    [task resume];
}

#pragma mark - EMClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState
{
    __weak typeof(self) weakSelf = self;
    //断网重连后，修改直播间状态为ongoing并重新推流&加入聊天室
    if (aConnectionState == EMConnectionConnected) {
        [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:_room completion:^(EaseLiveRoom *room, BOOL success) {
            if (success)
                _room = room;
            [weakSelf.chatview joinChatroomWithIsCount:NO
                                        completion:^(BOOL success) {
                                            if (success) {
                                                [weakSelf.headerListView loadHeaderListWithChatroomId:_room.chatroomId];
                                            }
                                        }];
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                [weakSelf.agoraKit enableLocalVideo:YES];
                [weakSelf.agoraKit enableLocalAudio:YES];
            }
            if ([weakSelf.room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
                [weakSelf.session restartStreamingWithPushURL:_streamURL feedback:^(PLStreamStartStateFeedback feedback) {}];
            }
        }];
    }
}

#pragma mark - PLMediaStreamingSessionDelegate

- (void)mediaStreamingSession:(PLMediaStreamingSession *)session streamStateDidChange:(PLStreamState)state
{
    if ((state == PLStreamStateDisconnected || state == PLStreamStateDisconnecting || state == PLStreamStateAutoReconnecting) && _isFinishBroadcast == NO) {
        [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:_room completion:^(EaseLiveRoom *room, BOOL success) {}];
    }
}

#pragma mark - mediastream

- (PLMediaStreamingSession *)session
{
    if (_session == nil) {
        videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
        videoCaptureConfiguration.position = AVCaptureDevicePositionFront;
        audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
        audioCaptureConfiguration.acousticEchoCancellationEnable = YES;
        videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
        audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
        _session = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:nil];
        _session.delegate = self;
        _session.autoReconnectEnable = YES;//掉线重连
    }
    return _session;
}
//摄像头权限
- (void)_prepareForCameraSetting
{
    PLPermissionRequestor *permission = [[PLPermissionRequestor alloc] init];
    __weak typeof(self) weakSelf = self;
    permission.permissionGranted = ^{
        UIView *previewView = _session.previewView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view insertSubview:weakSelf.session.previewView atIndex:0];
            [previewView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.and.right.equalTo(weakSelf.view);
            }];
        });
    };
    [permission checkAndRequestPermission];
}

- (void)actionPushStream {
    [EaseHttpManager.sharedInstance getLiveRoomPushStreamUrlWithRoomId:_room.chatroomId completion:^(NSString *pushUrl) {
        if (!pushUrl) {
            return;
        }
        _streamURL = [NSURL URLWithString:pushUrl];
        [self.session startStreamingWithPushURL:_streamURL feedback:^(PLStreamStartStateFeedback feedback) {
           NSString *log = [NSString stringWithFormat:@"session start state %lu",(unsigned long)feedback];
           dispatch_async(dispatch_get_main_queue(), ^{
               NSLog(@"%@", log);
           });
        }];
    }];
}

//切换前后摄像头
- (void)didSelectChangeCameraButton
{
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
        [self.session toggleCamera];
    }
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
        [self.agoraKit switchCamera];
    }
}

- (UIWindow*)subWindow
{
    if (_subWindow == nil) {
        _subWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _subWindow;
}

- (UIImageView*)backImageView
{
    if (_backImageView == nil) {
        _backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:_room.coverPictureUrl];
        __weak typeof(self) weakSelf = self;
        if (!image) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_room.coverPictureUrl]
                                                                     options:SDWebImageDownloaderUseNSURLCache
                                                                    progress:NULL
                                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                       if (image) {
                                                                           [[SDImageCache sharedImageCache] storeImage:image forKey:_room.coverPictureUrl toDisk:NO completion:^{
                                                                               weakSelf.backImageView.image = image;
                                                                           }];
                                                                       } else {
                                                                           weakSelf.backImageView.image = [UIImage imageNamed:@"default_back_image"];
                                                                       }
                                                                   }];
           }
        _backImageView.image = image;
    }
    return _backImageView;
}

- (EaseLiveHeaderListView*)headerListView
{
    if (_headerListView == nil) {
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, KScreenWidth, 40.f) room:_room];
        _headerListView.delegate = self;
        [_headerListView setLiveCastDelegate];
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
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 208, CGRectGetWidth(self.view.bounds), 200) room:_room isPublish:YES customMsgHelper:_customMsgHelper];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (CTCallCenter *)callCenter {
    if (!_callCenter) {
        _callCenter = [[CTCallCenter alloc] init];
    }
    return _callCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didSelectedExitButton
{
    EaseFinishLiveView *finishView = [[EaseFinishLiveView alloc]initWithTitleInfo:@"确定结束直播?"];
    [self.view addSubview:finishView];
    [finishView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.equalTo(@220);
        make.center.equalTo(self.view);
    }];
    __weak EaseFinishLiveView *weakFinishView = finishView;
    __weak EasePublishViewController *weakSelf = self;
    [finishView setDoneCompletion:^(BOOL isFinish) {
        if (isFinish) {
            _isFinishBroadcast = YES;
            _session.delegate = nil;
            [weakSelf didClickFinishButton];
        }
        [weakFinishView removeFromSuperview];
    }];
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

- (void)didClickFinishButton
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
                                             
                                             [UIApplication sharedApplication].idleTimerDisabled = NO;
                                             [weakSelf dismissViewControllerAnimated:YES completion:^{
                                                 if (_finishBroadcastCompletion) {
                                                     _finishBroadcastCompletion(YES);
                                                 }
                                             }];
                                         }];
    };
    [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOffline:_room completion:^(EaseLiveRoom *room, BOOL success) {
        if (success) {
            _room = room;
            if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
                [weakSelf.session stopStreaming];//结束推流
                [weakSelf.session destroy];
            }
            if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                [weakSelf.agoraKit leaveChannel:nil];
                [AgoraRtcEngineKit destroy];
            }
            _isFinishBroadcast = YES;
            //重置本地保存的直播间id
            EaseDefaultDataHelper.shared.currentRoomId = @"";
            [EaseDefaultDataHelper.shared archive];
        }
        block();
    }];
}

- (void)didClickContinueButton
{
    [self _recoverLive];
}

#pragma mark - EaseChatViewDelegate

//礼物列表
- (void)didSelectGiftButton:(BOOL)isOwner
{
    if (isOwner) {
        EaseGiftListView *giftListView = [[EaseGiftListView alloc]init];
        giftListView.delegate = self;
        [giftListView showFromParentView:self.view];
    }
}

//有观众送礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count
{
    [_customMsgHelper userSendGifts:msg count:count backView:self.view];
    
    EMCustomMessageBody *msgBody = (EMCustomMessageBody*)msg.body;
    NSString *giftid = [msgBody.ext objectForKey:@"id"];
    
    _totalGifts += count;
    ++_giftsNum;
    [self.headerListView.liveCastView setNumberOfGift:_totalGifts];
    //礼物份数
    EaseDefaultDataHelper.shared.giftNumbers = [NSString stringWithFormat:@"%ld",(long)_giftsNum];
    //礼物合计总数
    EaseDefaultDataHelper.shared.totalGifts = [NSString stringWithFormat:@"%ld",(long)_totalGifts];
    //送礼物人列表
    if (![EaseDefaultDataHelper.shared.rewardCount containsObject:msg.from]) {
        [EaseDefaultDataHelper.shared.rewardCount addObject:msg.from];
    }
    NSMutableDictionary *giftDetailDic = (NSMutableDictionary*)[EaseDefaultDataHelper.shared.giftStatisticsCount objectForKey:giftid];
    if (!giftDetailDic) giftDetailDic = [[NSMutableDictionary alloc]init];
    long long num = [(NSString*)[giftDetailDic objectForKey:msg.from] longLongValue];
    [giftDetailDic setObject:[NSString stringWithFormat:@"%lld",(num+count)] forKey:msg.from];
    //礼物统计字典
    [EaseDefaultDataHelper.shared.giftStatisticsCount setObject:giftDetailDic forKey:giftid];
    [EaseDefaultDataHelper.shared archive];
}

//弹幕
- (void)didSelectedBarrageSwitch:(EMMessage*)msg
{
    [_customMsgHelper barrageAction:msg backView:self.view];
}

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

//收到点赞
- (void)didReceivePraiseMessage:(EMMessage *)message
{
    [_customMsgHelper praiseAction:_chatview];
    EMCustomMessageBody *customBody = (EMCustomMessageBody*)message.body;
    _praiseNum += [(NSString*)[customBody.ext objectForKey:@"num"] integerValue];
    [self.headerListView.liveCastView setNumberOfPraise:_praiseNum];
    EaseDefaultDataHelper.shared.praiseStatisticstCount = [NSString stringWithFormat:@"%ld",(long)_praiseNum];
    [EaseDefaultDataHelper.shared archive];
}

//操作观众对象
- (void)didSelectUserWithMessage:(EMMessage *)message
{
    [self.view endEditing:YES];
    if (![message.from isEqualToString:_room.anchor]) {
        EaseAudienceBehaviorView *audienceBehaviorView = [[EaseAudienceBehaviorView alloc]initWithOperateUser:message.from chatroomId: _room.chatroomId];
        audienceBehaviorView.delegate = self;
        [audienceBehaviorView showFromParentView:self.view];
    }
}

//主播信息卡片
- (void)didClickAnchorCard:(EaseLiveRoom *)room
{
    [self.view endEditing:YES];
    EaseAnchorCardView *anchorCardView = [[EaseAnchorCardView alloc]initWithLiveRoom:room];
    anchorCardView.delegate = self;
    [anchorCardView showFromParentView:self.view];
}

//成员列表
- (void)didSelectMemberListButton:(BOOL)isOwner currentMemberList:(NSMutableArray*)currentMemberList
{
    [self.view endEditing:YES];
    EaseAdminView *adminView = [[EaseAdminView alloc] initWithChatroomId:_room
                                                                 isOwner:isOwner
                                                                currentMemberList:currentMemberList];
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

extern bool isAllTheSilence;
- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    isAllTheSilence = aMuted;
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if (aMuted) {
            [self showHint:@"全员禁言开启！"];
        } else {
            [self showHint:@"解除全员禁言！"];
        }
    }
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self showHint:[NSString stringWithFormat:@"被加入白名单:%@",text]];
    }
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self showHint:[NSString stringWithFormat:@"从白名单移除:%@",text]];
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
    __weak EasePublishViewController *weakSelf = self;
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"聊天室创建者有更新:%@",aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([aOldOwner isEqualToString:EMClient.sharedClient.currentUsername]) {
                if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeLIVE]) {
                    [weakSelf.session stopStreaming];//结束推流
                    [weakSelf.session destroy];
                }
                if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {
                    [weakSelf.agoraKit leaveChannel:nil];
                    [AgoraRtcEngineKit destroy];
                }
                _isFinishBroadcast = YES;
                //重置本地保存的直播间id
                EaseDefaultDataHelper.shared.currentRoomId = @"";
                [EaseDefaultDataHelper.shared archive];
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    UIViewController *view = [[EaseLiveViewController alloc] initWithLiveRoom:_room];
                    view.modalPresentationStyle = 0;
                    [weakSelf.navigationController presentViewController:view animated:YES completion:NULL];
                    if (_finishBroadcastCompletion) {
                        _finishBroadcastCompletion(YES);
                    }
                }];
            }
        }];
        
        [alert addAction:ok];
        alert.modalPresentationStyle = 0;
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom reason:(EMChatroomBeKickedReason)aReason
{
    if (aReason == 0)
        [MBProgressHUD showMessag:[NSString stringWithFormat:@"被移出直播聊天室 %@", aChatroom.subject] toView:nil];
    if (aReason == 1)
        [MBProgressHUD showMessag:[NSString stringWithFormat:@"直播聊天室 %@ 已解散", aChatroom.subject] toView:nil];
    if (aReason == 2)
        [MBProgressHUD showMessag:@"您的账号已离线" toView:nil];
    [self didClickFinishButton];
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

- (void)_recoverLive
{
    while (!_isload) {
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
