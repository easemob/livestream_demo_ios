//
//  EaseLiveViewController.m
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveViewController.h"

#import "EaseChatView.h"
#import "EaseHeartFlyView.h"
#import "EaseGiftFlyView.h"
#import "EaseBarrageFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveGiftView.h"
#import "EaseLiveRoom.h"
#import "EaseLiveGiftView.h"
#import "EaseGiftConfirmView.h"
#import "EaseGiftCell.h"
#import "EaseCustomKeyBoardView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "EaseDefaultDataHelper.h"

#import "UIImageView+WebCache.h"
#import "EaseCustomMessageHelper.h"

#import <AgoraMediaPlayer/AgoraMediaPlayerKit.h>

#import "ELDChatroomMembersView.h"

#import "ELDUserInfoView.h"

#import "EaseLiveCastView.h"

#import "ELDNotificationView.h"

#import "ELDTwoBallAnimationView.h"

#import "ELDChatView.h"
#import "ELDChatViewHelper.h"
#import "EaseUserInfoManagerHelper.h"
#import "EMError+localizedString.h"


#define kDefaultTop 35.f


@interface EaseLiveViewController () <EaseLiveHeaderListViewDelegate,TapBackgroundViewDelegate,EaseLiveGiftViewDelegate,EMChatroomManagerDelegate,EaseProfileLiveViewDelegate,EMClientDelegate,EaseCustomMessageHelperDelegate,AgoraRtcEngineDelegate,ELDChatroomMembersViewDelegate,ELDUserInfoViewDelegate,AgoraMediaPlayerDelegate,ELDChatViewDelegate>
{
    NSTimer *_burstTimer;
    EaseLiveRoom *_room;
    BOOL _enableAdmin;
    EaseCustomMessageHelper *_customMsgHelper;
    NSTimer *_timer;
    NSInteger _clock; //重复次数时钟
    id _observer;
}

@property (nonatomic, strong) EMChatroom *chatroom;

@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) ELDChatView *chatview;

@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *liveView;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGR;

/** gifimage */
@property(nonatomic,strong) UIImageView *backgroudImageView;

@property (nonatomic, strong) AgoraMediaPlayer  *player;
@property (nonatomic, strong) UIView *mediaPlayerView;


@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avLayer;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *agoraRemoteVideoView;

@property (nonatomic, strong) ELDChatroomMembersView *memberView;
@property (nonatomic, strong) ELDUserInfoView *userInfoView;
@property (nonatomic, strong) EaseLiveGiftView *giftView;

@property (nonatomic, strong) ELDNotificationView *notificationView;

@property (nonatomic, strong) ELDTwoBallAnimationView *twoBallAnimationView;

@property (nonatomic, strong) UIView  *blurBgView;
@property (nonatomic, strong) UILabel *liveHintLabel;

@end

@implementation EaseLiveViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room
{
    self = [super init];
    if (self) {
        _room = room;
        _customMsgHelper = [[EaseCustomMessageHelper alloc]initWithCustomMsgImp:self chatId:_room.chatroomId];
        _clock = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view insertSubview:self.backgroudImageView atIndex:0];
    
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    [self joinChatroom];
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    [self setupForDismissKeyboard];
    
    [self _setupAgoreKit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication  sharedApplication].idleTimerDisabled =YES;    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [UIApplication  sharedApplication].idleTimerDisabled =NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient] removeDelegate:self];
    [_headerListView stopTimer];
    _chatview.easeChatView.delegate = nil;
    _chatview = nil;
    if (self.avPlayer)
        [self.avPlayer removeTimeObserver:_observer];
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)joinChatroom {
    ELD_WS
    [[ELDChatViewHelper sharedHelper] joinChatroomWithChatroomId:_room.chatroomId completion:^(EMChatroom * _Nonnull aChatroom, EMError * _Nonnull aError) {
        if (aError == nil) {
            [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_room.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
                if (aError == nil) {
                    weakSelf.chatroom = aChatroom;
                    
                    [self.view addSubview:self.liveView];
                    [weakSelf.view bringSubviewToFront:weakSelf.liveView];
                    [weakSelf updateUI];
                    [self showHint:NSLocalizedString(@"live.joinSuccess", nil)];

                }else {
                    [self showHint:aError.errorDescription];
                }
            }];

        } else {
            [self showHint:aError.localizedString];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)updateUI {
    [self.headerListView updateHeaderViewWithChatroom:self.chatroom];
    [self updateChatView];
}

- (void)updateChatView {
    self.chatview.chatroom = self.chatroom;
    
    if ([self.chatroom.muteList containsObject:EMClient.sharedClient.currentUsername] ||self.chatroom.isMuteAllMembers) {
        self.chatview.easeChatView.isMuted = YES;
        
        if (self.chatroom.isMuteAllMembers) {
            NSString *message = NSLocalizedString(@"live.steamerMuteAll", nil);
            [self showNotifactionMessage:message userId:self.chatroom.owner displayAllTime:YES];
            [self.chatview.easeChatView updateSendTextButtonHint:NSLocalizedString(@"live.allTimedOut", nil)];
        }else {
            [self.chatview.easeChatView updateSendTextButtonHint:@"You have been banned."];
        }
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.chatview endEditing:YES];
}

#pragma mark - fetchlivingstream

//拉取直播流
- (void)fetchLivingStream
{
    __weak typeof(self) weakSelf = self;
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeAGORA_SPEED_LIVE]) {

        return;
    }
    if ([_room.liveroomType isEqualToString:kLiveBroadCastingTypeVOD] || [_room.liveroomType isEqualToString:kLiveBroadCastingTypeAgoraVOD]) {
        NSURL *pushUrl = [NSURL URLWithString:[[_room.liveroomExt objectForKey:@"play"] objectForKey:@"m3u8"]];
        if (!pushUrl) {
            pushUrl = [NSURL URLWithString:[[_room.liveroomExt objectForKey:@"play"] objectForKey:@"rtmp"]];
            [self startPLayVideoStream:pushUrl];
        } else {
            [self startPlayVodStream:pushUrl];
        }
        return;
    }
    [EaseHttpManager.sharedInstance getLiveRoomPullStreamUrlWithRoomId:_room.chatroomId completion:^(NSString *pullStreamStr) {
        NSURL *pullStreamUrl = [NSURL URLWithString:pullStreamStr];
        [weakSelf startPLayVideoStream:pullStreamUrl];
    }];
}


#pragma mark - configAgroaKit

- (void)_setupAgoreKit
{
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AppId delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    AgoraClientRoleOptions *options = [[AgoraClientRoleOptions alloc]init];
    options.audienceLatencyLevel = AgoraAudienceLatencyLevelLowLatency;
    [self.agoraKit setClientRole:AgoraClientRoleAudience options:options];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:agoraUserId joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
            if ([_room.liveroomType
                 isEqualToString:kLiveBoardCastingTypeAGORA_CDN_LIVE]) {
                NSDictionary *paramtars = @{
                    @"protocol":@"rtmp",
                    @"domain":@"ws-rtmp-pull.easemob.com",
                    @"pushPoint":@"live",
                    @"streamKey":_room.channel ? _room.channel : _room.chatroomId
                };
                [EaseHttpManager.sharedInstance getAgroLiveRoomPlayStreamUrlParamtars:paramtars Completion:^(NSString *playStreamStr) {

                    AgoraLiveInjectStreamConfig *config = [[AgoraLiveInjectStreamConfig alloc] init];
                    config.videoGop=30;
                    config.videoBitrate=400;
                    config.videoFramerate=15;
                    config.audioBitrate=48;
                    config.audioSampleRate= AgoraAudioSampleRateType44100;
                    config.audioChannels=1;
                    [self.agoraKit addInjectStreamUrl:playStreamStr config:config];
                }];
                
            }
        }];
    }];
    self.agoraRemoteVideoView = [[UIView alloc]init];
    self.agoraRemoteVideoView.frame = self.view.bounds;
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine
remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state reason:(AgoraVideoRemoteReason)reason elapsed:(NSInteger)elapsed {
    if (state == AgoraVideoRemoteStateFailed || state == AgoraVideoRemoteStateStopped) {
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
    } else {
        [self.view insertSubview:self.agoraRemoteVideoView atIndex:0];
        [self.backgroudImageView removeFromSuperview];
        
    }
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.view = self.agoraRemoteVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    // 设置远端视图。
    [self.agoraKit setupRemoteVideo:videoCanvas];
}


//点播
- (void)startPlayVodStream:(NSURL *)vodStreamUrl
{
    //设置播放的项目
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:vodStreamUrl];
    //初始化player对象
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    //设置播放页面
    self.avLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    //设置播放页面的大小
    self.avLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.avLayer.backgroundColor = [UIColor clearColor].CGColor;
    //设置播放窗口和当前视图之间的比例显示内容
    self.avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.backgroudImageView removeFromSuperview];
    //添加播放视图到self.view
    [self.view.layer insertSublayer:self.avLayer atIndex:0];
    //设置播放的默认音量值
    self.avPlayer.volume = 1.0f;
    [self.avPlayer play];
    [self addProgressObserver: [vodStreamUrl absoluteString]];
}

// 视频循环播放
- (void)vodPlayDidEnd:(NSDictionary*)dic{
    [self.avLayer removeFromSuperlayer];
    self.avPlayer = nil;
    NSURL *pushUrl = [NSURL URLWithString:[dic objectForKey:@"pushurl"]];
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(0, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    AVPlayerItem *item = [dic objectForKey:@"playItem"];
    [item seekToTime:kCMTimeZero];
    [self startPlayVodStream:pushUrl];
}

-(void)addProgressObserver:(NSString*)url {
    __weak typeof(self) weakSelf = self;
    AVPlayerItem *playerItem=self.avPlayer.currentItem;
    _observer = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        if ((current > 0 && total > 0) && ((int)current == (int)total)) {
            [weakSelf vodPlayDidEnd:@{@"pushurl":url, @"playItem":weakSelf.avPlayer.currentItem}];
        }
    }];
}


//看直播
- (void)startPLayVideoStream:(NSURL *)streamUrl
{
    self.player = [[AgoraMediaPlayer alloc] initWithDelegate:self];
    [self.player setView:self.mediaPlayerView];
    [self.view insertSubview:self.mediaPlayerView atIndex:0];
    [self.mediaPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];

    if ([_room.liveroomType isEqual:kLiveBroadCastingTypeVOD])
        self.mediaPlayerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.player play];
}

#pragma mark - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine
                    connectionStateChanged:(AgoraConnectionState)state
           reason:(AgoraConnectionChangedReason)reason {
    
    if (reason == AgoraConnectionChangedReasonTokenExpired || reason == AgoraConnectionChangedReasonInvalidToken) {
        __weak typeof(self) weakSelf = self;
        [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
            [weakSelf.agoraKit renewToken:rtcToken];
        }];
    }
    if (state == AgoraConnectionStateConnected) {
        if (_clock > 0) {
            _clock = 0;
            [self stopTimer];
        }
        
        [self.twoBallAnimationView stopAnimation];
        self.blurBgView.hidden = YES;
    }
    
    if (state == AgoraConnectionStateConnecting || state == AgoraConnectionStateReconnecting) {
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
        
        [self.view addSubview:self.twoBallAnimationView];
        [self.twoBallAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.centerY.equalTo(self.view);
            make.height.equalTo(@(50.0));
        }];
        [self.twoBallAnimationView startAnimation];

    }
    
    if (state == AgoraConnectionStateFailed) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"Connection failed, please exit and re-enter the live room." toView:self.view];
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:2.0];
        if (_clock >= 5)
            return;
        ++_clock;
        [self startTimer];
    }
    
    if (state == AgoraConnectionStateDisconnected) {
        self.liveHintLabel.text = @"The Live Streamer is away and will be back soon...";
        self.blurBgView.hidden = YES;
    }
}



- (void)rtcEngine:(AgoraRtcEngineKit *)engine tokenPrivilegeWillExpire:(NSString *)token
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit renewToken:rtcToken];
    }];
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *)engine
{
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken,NSUInteger agoraUserId) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        }];
    }];
}

- (void)fetchAgoraRtcToken:(void (^)(NSString *rtcToken ,NSUInteger agoraUserId))aCompletionBlock;
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];

    NSString* strUrl = [NSString stringWithFormat:@"https://a1.easemob.com/token/rtcToken/v1?userAccount=%@&channelName=%@&appkey=%@",[EMClient sharedClient].currentUsername, _room.channel, [EMClient sharedClient].options.appkey];
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
                    NSUInteger agoraUserId = [[body objectForKey:@"agoraUserId"] integerValue];
                    if (aCompletionBlock)
                        aCompletionBlock(rtcToken,agoraUserId);
                }
            }
        }
    }];

    [task resume];
}

#pragma mark AgoraMediaPlayerDelegate
- (void)AgoraMediaPlayer:(AgoraMediaPlayer *_Nonnull)playerKit
       didChangedToState:(AgoraMediaPlayerState)state
                   error:(AgoraMediaPlayerError)error {
    
    if (state == AgoraMediaPlayerStatePlaying) {
        [self.backgroudImageView removeFromSuperview];
        if (_clock > 0) {
            _clock = 0;
            [self stopTimer];
        }
    } else if (state == AgoraMediaPlayerStateIdle) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"reconnecting..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
    } else if (state == AgoraMediaPlayerStateFailed) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"Error in playback, please exit and re-enter the live room." toView:self.view];
        [self.mediaPlayerView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:1.5];
    }
}

- (void)AgoraMediaPlayer:(AgoraMediaPlayer *_Nonnull)playerKit
           didOccurEvent:(AgoraMediaPlayerEvent)event {
    
    if (event == AgoraMediaPlayerEventSeekError) {
        [self.mediaPlayerView removeFromSuperview];
        [self.view insertSubview:self.backgroudImageView atIndex:0];
        if (_clock >= 5)
            return;
        ++_clock;
        [self startTimer];
    }
}

#pragma mark timer
- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(updateCountLabel) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)updateCountLabel {

}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    
    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithUsername:username chatroom:_chatroom memberVCType:ELDMemberVCTypeAll];
    userInfoView.delegate = self;
    userInfoView.userInfoViewDelegate = self;
    [userInfoView showFromParentView:self.view];
}

//chatroom owner userInfo
- (void)didClickAnchorCard:(EMUserInfo*)userInfo
{
    [self.view endEditing:YES];

    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithOwnerId:userInfo.userId chatroom:self.chatroom];
    userInfoView.delegate = self;
    [userInfoView showFromParentView:self.view];
}


- (void)didSelectMemberListButton:(BOOL)isOwner currentMemberList:(NSMutableArray*)currentMemberList
{
    [self.view endEditing:YES];
    [self.memberView showFromParentView:self.view];
}


- (void)willCloseChatroom {
    [self closeButtonAction];
}

#pragma  mark - TapBackgroundViewDelegate

- (void)didTapBackgroundView:(EaseBaseSubView *)profileView
{
    [profileView removeFromParentView];
}

#pragma  mark ELDChatroomMembersViewDelegate
- (void)selectedUser:(NSString *)userId memberVCType:(ELDMemberVCType)memberVCType chatRoom:(EMChatroom *)chatroom {
    
    [self.memberView removeFromParentView];
    
    self.userInfoView = [[ELDUserInfoView alloc] initWithUsername:userId chatroom:chatroom memberVCType:memberVCType];
    self.userInfoView.delegate = self;
    self.userInfoView.userInfoViewDelegate = self;
    [self.userInfoView showFromParentView:self.view];

}

#pragma mark ELDUserInfoViewDelegate
- (void)showAlertWithTitle:(NSString *)title messsage:(NSString *)messsage actionType:(ELDMemberActionType)actionType {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.userInfoView confirmActionWithActionType:actionType];
    }];

    [alertController addAction:okAction];

    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - EaseChatViewDelegate
- (void)liveRoomOwnerDidUpdate:(EMChatroom *)aChatroom newOwner:(NSString *)aNewOwner
{
    self.chatroom = aChatroom;
    _room.anchor = aNewOwner;
    [self fetchLivingStream];
}


#pragma mark - ELDChatViewDelegate
- (void)chatViewDidBottomOffset:(CGFloat)offSet
{
    if ([self.window isKeyWindow]) {
        return;
    }
    
    if (offSet > 0) {
        [self.chatview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_liveView).offset(-offSet);
        }];
    }else {
        [self.chatview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_liveView).offset(-kBottomSafeHeight);
        }];
    }
}


- (void)didSelectGiftButton
{
    [self.giftView showFromParentView:self.view];
}

- (void)didSelectUserWithMessage:(EMChatMessage *)message {

    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    
    ELDUserInfoView *userInfoView = [[ELDUserInfoView alloc] initWithUsername:message.from chatroom:_chatroom memberVCType:ELDMemberVCTypeAll];
    userInfoView.delegate = self;
    userInfoView.userInfoViewDelegate = self;
    [userInfoView showFromParentView:self.view];

}

- (void)chatViewDidSendMessage:(EMChatMessage *)message error:(EMError *)error {
    if (error) {
        [self showHint:error.errorDescription];
    }
}


#pragma mark - EaseCustomMessageHelperDelegate
- (void)steamerReceiveGiftId:(NSString *)giftId giftNum:(NSInteger)giftNum fromUser:(nonnull NSString *)userId {
    [self.chatview userSendGiftId:giftId giftNum:giftNum userId:userId backView:self.view];
}

//弹幕
- (void)didSelectedBarrageSwitch:(EMChatMessage*)msg
{
    [self.chatview barrageAction:msg backView:self.view];
}

//点赞
- (void)didReceivePraiseMessage:(EMChatMessage *)message
{
    [self.chatview praiseAction:_chatview];
}

#pragma mark - EaseLiveGiftViewDelegate
- (void)didConfirmGiftModel:(ELDGiftModel *)giftModel giftNum:(long)num {
    
    ELD_WS
    //send gift message
    [self.chatview.easeChatView sendGiftAction:giftModel.giftId num:num completion:^(BOOL success) {
        if (success) {
            //display gift UI
            
            [weakSelf.giftView resetWitGiftId:giftModel.giftId];
            
            [weakSelf.chatview showGiftModel:giftModel
                                     giftNum:num
                                    backView:self.view];
        }else {
            [self showHint:NSLocalizedString(@"live.sendGift.failed", nil)];
        }
    }];
}


//自定义礼物数量
- (void)giftNumCustom:(EaseLiveGiftView *)liveGiftView
{
    EaseCustomKeyBoardView *keyBoardView = [[EaseCustomKeyBoardView alloc]init];
    keyBoardView.customGiftNumDelegate = liveGiftView;
    keyBoardView.delegate = self;
    [keyBoardView showFromParentView:self.view];
}


#pragma mark - EMChatroomManagerDelegate
- (void)userDidJoinChatroom:(EMChatroom *)aChatroom user:(NSString *)aUsername {
    NSLog(@"userDidJoinChatroom: %s",__func__);
    if ([aChatroom.chatroomId isEqualToString:self.chatroom.chatroomId]) {
        [self fetchChatroomSpecificationWithRoomId:self.chatroom.chatroomId];
        [self.chatview insertJoinMessageWithChatroom:self.chatroom user:aUsername];
    }
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom user:(NSString *)aUsername {
    if ([aChatroom.chatroomId isEqualToString:self.chatroom.chatroomId]) {
        [self fetchChatroomSpecificationWithRoomId:self.chatroom.chatroomId];
        if ([self.chatroom.owner isEqualToString:aUsername]) {
            self.blurBgView.hidden = NO;
        
        }
    }
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom reason:(EMChatroomBeKickedReason)aReason
{
    if (aReason == 0)
    [self showHint:NSLocalizedString(@"live.beenKicked", nil)];
    
    if (aReason == 1)
    [self showHint:[NSString stringWithFormat:NSLocalizedString(@"live.beenEnd", nil),aChatroom.subject]];

    if (aReason == 2)
        [self showHint:NSLocalizedString(@"live.offline", nil)];

    [self closeButtonAction];
}

- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        
        if (aMuted) {
            self.chatview.easeChatView.isMuted = YES;
            [self.chatview.easeChatView updateSendTextButtonHint:NSLocalizedString(@"live.allTimedOut", nil)];

            NSString *message = NSLocalizedString(@"live.steamerMuteAll", nil);
            [self showNotifactionMessage:message userId:@"" displayAllTime:YES];

        } else {
            
            self.chatview.easeChatView.isMuted = NO;
            [self.chatview.easeChatView updateSendTextButtonHint:NSLocalizedString(@"message.sayHi", nil)];

            NSString *message = NSLocalizedString(@"live.steamerRemoteMuteAll", nil);
            [self showNotifactionMessage:message userId:@"" displayAllTime:NO];
        }
        
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
    }
}


- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin;
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            _enableAdmin = YES;
            
            [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];

            NSString *message = NSLocalizedString(@"live.beenModerator", NSLocalizedString(@"publish.ok", nil));
            [self showNotifactionMessage:message userId:@"" displayAllTime:NO];
        }
    }
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            _enableAdmin = NO;
                          
            [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
            
            NSString *message = NSLocalizedString(@"live.beenNotModerator", NSLocalizedString(@"publish.ok", nil));
            [self showNotifactionMessage:message userId:@"" displayAllTime:NO];
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
        
        self.chatview.easeChatView.isMuted = YES;
        [self.chatview.easeChatView updateSendTextButtonHint:NSLocalizedString(@"live.beenMute", NSLocalizedString(@"publish.ok", nil))];
        [self.chatview reloadTableView];
        
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
        
        NSString *message = NSLocalizedString(@"live.beenMute", NSLocalizedString(@"publish.ok", nil));
        [self showNotifactionMessage:message userId:@"" displayAllTime:NO];
      
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
        self.chatview.easeChatView.isMuted = NO;
        [self.chatview.easeChatView updateSendTextButtonHint:NSLocalizedString(@"message.sayHi", nil)];
        [self.chatview reloadTableView];

        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
   
        NSString *message = NSLocalizedString(@"live.beenNotMute", NSLocalizedString(@"publish.ok", nil));
        [self showNotifactionMessage:message userId:@"" displayAllTime:NO];
    }
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom addedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
        
        NSString *message = NSLocalizedString(@"live.beenWhite", NSLocalizedString(@"publish.ok", nil));
        [self showNotifactionMessage:message userId:@"" displayAllTime:NO];

    }
}

- (void)chatroomWhiteListDidUpdate:(EMChatroom *)aChatroom removedWhiteListMembers:(NSArray *)aMembers
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        NSMutableString *text = [NSMutableString string];
        for (NSString *name in aMembers) {
            [text appendString:name];
        }
        
        [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
                
        NSString *message = NSLocalizedString(@"live.beenNotWhite", NSLocalizedString(@"publish.ok", nil));
        [self showNotifactionMessage:message userId:@"" displayAllTime:NO];

    }
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    __weak typeof(self) weakSelf =  self;
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"live chatroom create update  :%@",aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", NSLocalizedString(@"publish.ok", nil)) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([aNewOwner isEqualToString:EMClient.sharedClient.currentUsername]) {
                [_burstTimer invalidate];
                _burstTimer = nil;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    _room.anchor = aChatroom.owner;
                    if (_chatroomUpdateCompletion) {
                        _chatroomUpdateCompletion(YES,_room);
                    }
                    [self fetchChatroomSpecificationWithRoomId:aChatroom.chatroomId];
                }];
            }
        }];
        
        [alert addAction:ok];
        alert.modalPresentationStyle = 0;
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)showNotifactionMessage:(NSString *)message
                        userId:(NSString *)userId
                displayAllTime:(BOOL)displayAllTime {
    
    if ([userId isEqualToString:@""]) {
        self.notificationView.hidden = NO;
        ELD_WS
        [self.notificationView showHintMessage:message
                                displayAllTime:displayAllTime
                                    completion:^(BOOL finish) {
            if (finish) {
                weakSelf.notificationView.hidden = YES;
            }
        }];
    }else {
        [EaseUserInfoManagerHelper fetchUserInfoWithUserIds:@[userId] completion:^(NSDictionary * _Nonnull userInfoDic) {
            EMUserInfo *userInfo = userInfoDic[userId];
            if (userInfo) {
                NSString *displayName = userInfo.nickname ?:userInfo.userId;

                NSString *displayMsg = [NSString stringWithFormat:@"%@ %@",displayName,message];
                self.notificationView.hidden = NO;
                ELD_WS
                [self.notificationView showHintMessage:displayMsg
                                        displayAllTime:displayAllTime
                                            completion:^(BOOL finish) {
                    if (finish) {
                        weakSelf.notificationView.hidden = YES;
                    }
                }];
            }
            
        }];
        
    }
}


- (void)fetchChatroomSpecificationWithRoomId:(NSString *)roomId {
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:roomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        if (aError == nil) {
            self.chatroom = aChatroom;
            //reset memberView
            self.memberView = nil;
            [self.headerListView updateHeaderViewWithChatroom:self.chatroom];
        }else {
            [self showHint:aError.errorDescription];
        }
    }];
}


#pragma mark - EMClientDelegate

- (void)userAccountDidLoginFromOtherDevice
{
    [self closeButtonAction];
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

- (void)closeButtonAction
{
    ELD_WS
    [[ELDChatViewHelper sharedHelper] leaveChatroomId:_room.chatroomId completion:^(BOOL success) {
        if (success) {
            [[EMClient sharedClient].chatManager deleteConversation:_room.chatroomId isDeleteMessages:YES completion:NULL];
        }

        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    }];
    
    
    [self.agoraKit leaveChannel:nil];
    [_burstTimer invalidate];
    _burstTimer = nil;
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

#pragma mark - tapGesture
- (void)setupForDismissKeyboard
{
    self.singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    [self.view addGestureRecognizer:self.singleTapGR];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
    [self.chatview endEditing:YES];
}

#pragma mark - getter and setter
- (UIWindow*)window
{
    if (_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _window;
}

- (UIImageView*)backgroudImageView
{
    if (_backgroudImageView == nil) {
        _backgroudImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _backgroudImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_backgroudImageView sd_setImageWithURL:[NSURL URLWithString:_room.coverPictureUrl] placeholderImage:ImageWithName(@"default_back_image")];
        
    }
    return _backgroudImageView;
}

- (UIView*)liveView
{
    if (_liveView == nil) {
        _liveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _liveView.backgroundColor = [UIColor clearColor];
        
        [_liveView addSubview:self.blurBgView];
        [_liveView addSubview:self.headerListView];
        [_liveView addSubview:self.notificationView];
        [_liveView addSubview:self.chatview];
        
        [self.blurBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_liveView);
        }];

        [self.headerListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_liveView).offset(kDefaultTop);
            make.left.right.equalTo(_liveView);
            make.height.equalTo(@(kLiveHeaderViewHeight));
        }];
        
        [self.notificationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerListView.mas_bottom).offset(5.0);
            make.left.right.equalTo(_liveView);
            make.height.equalTo(@(kLiveNotifacationViewHeight));
        }];

        [self.chatview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_liveView);
            make.height.equalTo(@(kChatViewHeight));
            make.bottom.equalTo(_liveView).offset(-kBottomSafeHeight);
        }];
        
    }
    return _liveView;
}

- (EaseLiveHeaderListView*)headerListView
{
    if (_headerListView == nil) {
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, CGRectGetWidth(self.view.frame), 50.0f) chatroom:self.chatroom isPublish:NO];
        _headerListView.delegate = self;
        [_headerListView setLiveCastDelegate];
    }
    return _headerListView;
}

- (ELDChatView*)chatview
{
    if (_chatview == nil) {
        _chatview = [[ELDChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - kChatViewHeight, CGRectGetWidth(self.view.frame), kChatViewHeight) chatroom:self.chatroom isPublish:NO customMsgHelper:_customMsgHelper];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (ELDChatroomMembersView *)memberView {
    if (_memberView == nil) {
        _memberView = [[ELDChatroomMembersView alloc] initWithChatroom:self.chatroom];
        _memberView.delegate = self;
        _memberView.selectedUserDelegate = self;
    }
    return _memberView;
}

- (EaseLiveGiftView *)giftView {
    if (_giftView == nil) {
        _giftView = [[EaseLiveGiftView alloc]init];
        _giftView.giftDelegate = self;
        _giftView.delegate = self;
    }
    return _giftView;
}


- (ELDNotificationView *)notificationView {
    if (_notificationView == nil) {
        _notificationView = [[ELDNotificationView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerListView.frame), KScreenWidth, kLiveNotifacationViewHeight)];
        _notificationView.hidden = YES;

    }
    return _notificationView;
}


- (ELDTwoBallAnimationView *)twoBallAnimationView {
    if (_twoBallAnimationView == nil) {
        _twoBallAnimationView = [[ELDTwoBallAnimationView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50.0)];
    }
    return _twoBallAnimationView;
}


- (UIView *)mediaPlayerView {
    if (_mediaPlayerView == nil) {
        _mediaPlayerView = [[UIView alloc] init];
    }
    return _mediaPlayerView;
}

- (UILabel *)liveHintLabel {
    if (_liveHintLabel == nil) {
        _liveHintLabel = UILabel.new;
        _liveHintLabel.textColor = COLOR_HEX(0xBDBDBD);
        _liveHintLabel.font = NFont(18.0);
        _liveHintLabel.textAlignment = NSTextAlignmentCenter;
        _liveHintLabel.text = NSLocalizedString(@"live.ended", nil);
        _liveHintLabel.numberOfLines = 0;
    }
    return _liveHintLabel;
}

- (UIView *)blurBgView {
    if (_blurBgView == nil) {
        _blurBgView = [[UIView alloc] init];
        _blurBgView.hidden = YES;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        [_blurBgView addSubview:visualView];
        [visualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_blurBgView);
        }];
        
        [_blurBgView addSubview:self.liveHintLabel];
        [self.liveHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_blurBgView).offset(50.0);
            make.right.equalTo(_blurBgView).offset(-50.0);
            make.centerY.equalTo(_blurBgView).offset(-10.0);
        }];
        
    }
    return _blurBgView;
}

@end

#undef kDefaultTop

