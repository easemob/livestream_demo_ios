//
//  EaseLiveViewController.m
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveViewController.h"

#import "EaseChatView.h"
#import "AppDelegate.h"
#import "EaseHeartFlyView.h"
#import "EaseGiftFlyView.h"
#import "EaseBarrageFlyView.h"
#import "EaseLiveHeaderListView.h"
#import "UIImage+Color.h"
#import "EaseProfileLiveView.h"
#import "EaseLiveGiftView.h"
#import "EaseLiveRoom.h"
#import "EaseAdminView.h"
#import "EaseAnchorCardView.h"
#import "EaseLiveGiftView.h"
#import "EaseGiftConfirmView.h"
#import "EaseGiftCell.h"
#import "EaseCustomKeyBoardView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "EasePublishViewController.h"
#import "EaseDefaultDataHelper.h"

#import "UIImageView+WebCache.h"
#import "EaseCustomMessageHelper.h"

#import <PLPlayerKit/PLPlayerKit.h>

#import <AgoraRtcKit/AgoraRtcEngineKit.h>

#define kDefaultTop 35.f
#define kDefaultLeft 10.f

@interface EaseLiveViewController () <EaseChatViewDelegate,EaseLiveHeaderListViewDelegate,TapBackgroundViewDelegate,EaseLiveGiftViewDelegate,EMChatroomManagerDelegate,EaseProfileLiveViewDelegate,EMClientDelegate,EaseCustomMessageHelperDelegate,PLPlayerDelegate,AgoraRtcEngineDelegate>
{
    NSTimer *_burstTimer;
    EaseLiveRoom *_room;
    EMChatroom *_chatroom;
    BOOL _enableAdmin;
    EaseCustomMessageHelper *_customMsgHelper;
    NSTimer *_timer;
    NSInteger _clock; //重复次数时钟
    id _observer;
}

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) EaseChatView *chatview;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *liveView;
@property (nonatomic, strong) UILabel *roomNameLabel;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGR;

/** gifimage */
@property(nonatomic,strong) UIImageView *gifImageView;
@property(nonatomic,strong) UIImageView *backImageView;

@property (nonatomic, strong) PLPlayer  *player;

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avLayer;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *agoraRemoteVideoView;

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
    [self.view insertSubview:self.backImageView atIndex:0];
    
    [self.view addSubview:self.liveView];
    [self.liveView addSubview:self.headerListView];
    [self.liveView addSubview:self.chatview];
    //[self.liveView addSubview:self.roomNameLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    __weak EaseLiveViewController *weakSelf = self;
    [self.chatview joinChatroomWithIsCount:YES
                                completion:^(BOOL success) {
                                    if (success) {
                                        [weakSelf.headerListView loadHeaderListWithChatroomId:[_room.chatroomId copy]];
                                        _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_room.chatroomId error:nil];
                                        [[EaseHttpManager sharedInstance] getLiveRoomWithRoomId:_room.roomId
                                                                                     completion:^(EaseLiveRoom *room, BOOL success) {
                                                                                     }];
                                    } else {
                                        [weakSelf showHint:@"加入聊天室失败"];
                                        [weakSelf.view bringSubviewToFront:weakSelf.liveView];
                                        [weakSelf.view layoutSubviews];
                                    }
                                }];
    
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    [self setupForDismissKeyboard];
    
    [self fetchLivingStream];
}

- (void)viewWillLayoutSubviews
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient] removeDelegate:self];
    [_headerListView stopTimer];
    _chatview.delegate = nil;
    _chatview = nil;
    if (self.avPlayer)
        [self.avPlayer removeTimeObserver:_observer];
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self _setupAgoreKit];
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
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"b79a23d7b1074ed9b0c756c63fd4fa81" delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    AgoraClientRoleOptions *options = [[AgoraClientRoleOptions alloc]init];
    options.audienceLatencyLevel = AgoraAudienceLatencyLevelLowLatency;
    [self.agoraKit setClientRole:AgoraClientRoleAudience options:options];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    __weak typeof(self) weakSelf = self;
    [self fetchAgoraRtcToken:^(NSString *rtcToken) {
        [weakSelf.agoraKit joinChannelByToken:rtcToken channelId:_room.channel info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        }];
    }];
    self.agoraRemoteVideoView = [[UIView alloc]init];
    self.agoraRemoteVideoView.frame = self.view.bounds;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine remoteVideoStateChangedOfUid:(NSUInteger)uid state:(AgoraVideoRemoteState)state reason:(AgoraVideoRemoteStateReason)reason elapsed:(NSInteger)elapsed
{
    if (state == AgoraVideoRemoteStateFailed || state == AgoraVideoRemoteStateStopped) {
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
    } else {
        [self.view insertSubview:self.agoraRemoteVideoView atIndex:0];
        [self.backImageView removeFromSuperview];
    }
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    videoCanvas.view = self.agoraRemoteVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    // 设置远端视图。
    [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (PLPlayerOption *)_getPlayerOPtion
{
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    [option setOptionValue:@(3) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogDebug) forKey:PLPlayerOptionKeyLogLevel];
    return option;
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
    [self.backImageView removeFromSuperview];
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
    self.player = [PLPlayer playerLiveWithURL:streamUrl option:[self _getPlayerOPtion]];
    self.player.delegate = self;
    [self.view insertSubview:self.player.playerView atIndex:0];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    self.player.delegateQueue = dispatch_get_main_queue();
    if ([_room.liveroomType isEqual:kLiveBroadCastingTypeVOD])
        self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.player play];
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
        if (_clock > 0) {
            _clock = 0;
            [self stopTimer];
        }
    }
    if (state == AgoraConnectionStateConnecting || state == AgoraConnectionStateReconnecting) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在连接..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
    }
    if (state == AgoraConnectionStateFailed) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"连接失败,请退出重进直播间。" toView:self.view];
        [self.agoraRemoteVideoView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:2.0];
        if (_clock >= 5)
            return;
        ++_clock;
        [self startTimer];
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

#pragma mark - PLPlayerDelegate

- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state
{
    NSLog(@"status       %ld",(long)state);
    if (state == PLPlayerStatusPlaying) {
        [self.backImageView removeFromSuperview];
        if (_clock > 0) {
            _clock = 0;
            [self stopTimer];
        }
    } else if (state == PLPlayerStatusCaching) {
    } else if (state == PLPlayerStateAutoReconnecting) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在重新连接..." toView:self.view];
        [hud hideAnimated:YES afterDelay:1.5];
    } else if (state == PLPlayerStatusError) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"播放出错,请退出重进直播间。" toView:self.view];
        [self.player.playerView removeFromSuperview];
        [self.view insertSubview:self.backImageView atIndex:0];
        [hud hideAnimated:YES afterDelay:1.5];
    }
}

- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error
{
    NSString *info = error.userInfo[@"NSLocalizedDescription"];
    MBProgressHUD *hud = [MBProgressHUD showMessag:info toView:self.view];
    [self.player.playerView removeFromSuperview];
    [self.view insertSubview:self.backImageView atIndex:0];
    [hud hideAnimated:YES afterDelay:2.0];
    if (_clock >= 5)
        return;
    ++_clock;
    [self startTimer];
}

- (void)startTimer {
    [self stopTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(fetchLivingStream) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - getter

- (UIWindow*)window
{
    if (_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _window;
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
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, CGRectGetWidth(self.view.frame), 40.f) room:_room];
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
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 208, CGRectGetWidth(self.view.frame), 200) room:_room isPublish:NO customMsgHelper:_customMsgHelper];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (void)didSelectedExitButton
{
    [self closeButtonAction];
}

- (UIImageView *)gifImageView{
    
    if (!_gifImageView) {
        
        _gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 0, 360, 225)];
        _gifImageView.hidden = YES;
    }
    return _gifImageView;
}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    BOOL isOwner = _chatroom.permissionType == EMChatroomPermissionTypeOwner;
    BOOL ret = _chatroom.permissionType == EMChatroomPermissionTypeAdmin || isOwner;
    if (ret || _enableAdmin) {
        EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:username
                                                                                  chatroomId:_room.chatroomId
                                                                                     isOwner:isOwner];
        profileLiveView.delegate = self;
        [profileLiveView showFromParentView:self.view];
    } else {
        EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:username
                                                                                  chatroomId:_room.chatroomId];
        profileLiveView.delegate = self;
        [profileLiveView showFromParentView:self.view];
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

#pragma  mark - TapBackgroundViewDelegate

- (void)didTapBackgroundView:(EaseBaseSubView *)profileView
{
    [profileView removeFromParentView];
}

#pragma mark - EaseChatViewDelegate

- (void)liveRoomOwnerDidUpdate:(EMChatroom *)aChatroom newOwner:(NSString *)aNewOwner
{
    _chatroom = aChatroom;
    _room.anchor = aNewOwner;
    [self fetchLivingStream];
}

- (void)easeChatViewDidChangeFrameToHeight:(CGFloat)toHeight
{
    if ([self.window isKeyWindow]) {
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

- (void)didSelectGiftButton:(BOOL)isOwner
{
    if (!isOwner) {
        EaseLiveGiftView *giftView = [[EaseLiveGiftView alloc]init];
        giftView.giftDelegate = self;
        giftView.delegate = self;
        [giftView showFromParentView:self.view];
    }
}

#pragma mark - EaseCustomMessageHelperDelegate

//有观众送礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count
{
    [_customMsgHelper userSendGifts:msg count:count backView:self.view];
}
//弹幕
- (void)didSelectedBarrageSwitch:(EMMessage*)msg
{
    [_customMsgHelper barrageAction:msg backView:self.view];
}

//点赞
- (void)didReceivePraiseMessage:(EMMessage *)message
{
    [_customMsgHelper praiseAction:_chatview];
}

#pragma mark - EaseLiveGiftViewDelegate

- (void)didConfirmGift:(EaseGiftCell *)giftCell giftNum:(long)num
{
    EaseGiftConfirmView *confirmView = [[EaseGiftConfirmView alloc]initWithGiftInfo:giftCell giftNum:num titleText:@"是否赠送" giftId:giftCell.giftId];
    confirmView.delegate = self;
    [confirmView showFromParentView:self.view];
    __weak typeof(self) weakself = self;
    [confirmView setDoneCompletion:^(BOOL aConfirm,JPGiftCellModel *giftModel) {
        if (aConfirm) {
            //发送礼物消息
            [weakself.chatview sendGiftAction:giftModel.id num:giftModel.count completion:^(BOOL success) {
                if (success) {
                    //显示礼物UI
                    giftModel.username = [self randomNickName:giftModel.username];
                    [_customMsgHelper sendGiftAction:giftModel backView:self.view];
                }
            }];
        }
    }];
}
extern NSMutableDictionary *audienceNickname;
extern NSArray<NSString*> *nickNameArray;
extern NSMutableDictionary *anchorInfoDic;
- (NSString *)randomNickName:(NSString *)userName
{
    int random = (arc4random() % 100);
    NSString *randomNickname = nickNameArray[random];
    if (![audienceNickname objectForKey:userName]) {
        [audienceNickname setObject:randomNickname forKey:userName];
    } else {
        randomNickname = [audienceNickname objectForKey:userName];
    }
    if ([userName isEqualToString:EMClient.sharedClient.currentUsername]) {
        randomNickname = EaseDefaultDataHelper.shared.defaultNickname;
    }
    
    return randomNickname;
}

//自定义礼物数量
- (void)giftNumCustom:(EaseLiveGiftView *)liveGiftView
{
    EaseCustomKeyBoardView *keyBoardView = [[EaseCustomKeyBoardView alloc]init];
    keyBoardView.customGiftNumDelegate = liveGiftView;
    keyBoardView.delegate = self;
    [keyBoardView showFromParentView:self.view];
}

#pragma mark - EaseProfileLiveViewDelegate


#pragma mark - EMChatroomManagerDelegate

- (void)chatroomAllMemberMuteChanged:(EMChatroom *)aChatroom isAllMemberMuted:(BOOL)aMuted
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if (aMuted) {
            [self showHint:@"主播已开启全员禁言状态，不可发言！"];
        } else {
            [self showHint:@"主播已解除全员禁言，尽情发言吧！"];
        }
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
    [self closeButtonAction];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin;
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            _enableAdmin = YES;
            [self.view layoutSubviews];
        }
    }
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            _enableAdmin = NO;
            [self.view layoutSubviews];
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
        //[self showHudInView:[[[UIApplication sharedApplication] windows] firstObject] hint:[NSString stringWithFormat:@"禁言成员:%@",text]];
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

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    __weak typeof(self) weakSelf =  self;
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"聊天室创建者有更新:%@",aChatroom.chatroomId] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.ok", @"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([aNewOwner isEqualToString:EMClient.sharedClient.currentUsername]) {
                [_burstTimer invalidate];
                _burstTimer = nil;
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    _room.anchor = aChatroom.owner;
                    if (_chatroomUpdateCompletion) {
                        _chatroomUpdateCompletion(YES,_room);
                    }
                }];
            }
        }];
        
        [alert addAction:ok];
        alert.modalPresentationStyle = 0;
        [self presentViewController:alert animated:YES completion:nil];
    }
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
    __weak typeof(self) weakSelf =  self;
    NSString *chatroomId = [_room.chatroomId copy];
    [weakSelf.chatview leaveChatroomWithIsCount:YES
                                     completion:^(BOOL success) {
                                         if (success) {
                                             [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:NULL];
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
