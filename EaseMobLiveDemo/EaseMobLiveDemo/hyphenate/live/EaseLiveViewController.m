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

#define kDefaultTop 30.f
#define kDefaultLeft 10.f

@interface EaseLiveViewController () <EaseChatViewDelegate,EaseLiveHeaderListViewDelegate,TapBackgroundViewDelegate,EaseLiveGiftViewDelegate,EMChatroomManagerDelegate,EaseProfileLiveViewDelegate>
{
    NSTimer *_burstTimer;
    EaseLiveRoom *_room;
    EMChatroom *_chatroom;
    BOOL _enableAdmin;
}

@property (nonatomic, strong) PlayerManager *playerManager;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) EaseChatView *chatview;
@property (nonatomic, strong) EaseLiveHeaderListView *headerListView;

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *liveView;
@property (nonatomic, strong) UILabel *roomNameLabel;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGR;

@end

@implementation EaseLiveViewController

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
    
    [self.view addSubview:self.liveView];
    
    [self.liveView addSubview:self.chatview];
    [self.liveView addSubview:self.closeButton];
    [self.liveView addSubview:self.headerListView];
    [self.liveView addSubview:self.roomNameLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UCloudPlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    self.playerManager = [[PlayerManager alloc] init];
    self.playerManager.view = self.view;
    self.playerManager.viewContorller = self;
    float height = self.view.frame.size.height;
    [self.playerManager setPortraitViewHeight:height];

    __weak EaseLiveViewController *weakSelf = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.chatview joinChatroomWithCompletion:^(BOOL success) {
            if (success) {
                [weakSelf.headerListView loadHeaderListWithChatroomId:[_room.chatroomId copy]];
                _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_room.chatroomId error:nil];
                
                NSString *path = _room.session.mobilepullstream;
                [weakSelf.playerManager buildMediaPlayer:path];
            } else {
                [weakSelf showHint:@"加入聊天室失败"];
            }
            [weakSelf.view bringSubviewToFront:weakSelf.liveView];
            [weakSelf.view layoutSubviews];
        }];
    });
    
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
    _chatview = nil;
}

#pragma mark - getter

- (UIWindow*)window
{
    if (_window == nil) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 290.f)];
    }
    return _window;
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
        _headerListView = [[EaseLiveHeaderListView alloc] initWithFrame:CGRectMake(0, kDefaultTop, CGRectGetMinX(self.closeButton.frame), 30.f) room:_room];
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
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 200, CGRectGetWidth(self.view.frame), 200) room:_room isPublish:NO];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (UIButton*)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(KScreenWidth - 40.f, kDefaultTop, 30.f, 30.f);
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark - EaseLiveHeaderListViewDelegate

- (void)didSelectHeaderWithUsername:(NSString *)username
{
    if ([self.window isKeyWindow]) {
        [self closeAction];
        return;
    }
    BOOL isOwner = [_chatroom.owner isEqualToString:[EMClient sharedClient].currentUsername];
    BOOL ret = [_chatroom.adminList containsObject:[EMClient sharedClient].currentUsername] || isOwner;
    if (ret || _enableAdmin) {
        EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:username
                                                                                  chatroomId:_room.chatroomId
                                                                                     isOwner:isOwner];
        profileLiveView.delegate = self;
        [profileLiveView showFromParentView:self.view];
    }
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

- (void)didSelectUserWithMessage:(EMMessage *)message
{
    [self.view endEditing:YES];
    BOOL isOwner = [_chatroom.owner isEqualToString:[EMClient sharedClient].currentUsername];
    BOOL ret = [_chatroom.adminList containsObject:[EMClient sharedClient].currentUsername] || isOwner;
    if (ret || _enableAdmin) {
        EaseProfileLiveView *profileLiveView = [[EaseProfileLiveView alloc] initWithUsername:message.from
                                                                                  chatroomId:_room.chatroomId
                                                                                     isOwner:isOwner];
        profileLiveView.delegate = self;
        [profileLiveView showFromParentView:self.view];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        
    }
}

- (void)didSelectAdminButton:(BOOL)isOwner
{
    EaseAdminView *adminView = [[EaseAdminView alloc] initWithChatroomId:_room.chatroomId
                                                                 isOwner:isOwner];
    adminView.delegate = self;
    [adminView showFromParentView:self.view];
}

#pragma mark - EaseLiveGiftViewDelegate

- (void)didSelectGiftWithGiftId:(NSString *)giftId
{
    if (_chatview) {
        [_chatview sendGiftWithId:giftId];
    }
}

#pragma mark - EaseProfileLiveViewDelegate


#pragma mark - EMChatroomManagerDelegate

- (void)userDidJoinChatroom:(EMChatroom *)aChatroom
                       user:(NSString *)aUsername
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        [_headerListView joinChatroomWithUsername:aUsername];
    }
}

- (void)userDidLeaveChatroom:(EMChatroom *)aChatroom
                        user:(NSString *)aUsername
{
    if ([aChatroom.chatroomId isEqualToString:_room.chatroomId]) {
        [_headerListView leaveChatroomWithUsername:aUsername];
    }
}

- (void)didDismissFromChatroom:(EMChatroom *)aChatroom
                        reason:(EMChatroomBeKickedReason)aReason
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"被提出直播聊天室" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
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
            [self closeButtonAction];
        }];
        
        [alert addAction:ok];
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

-(void)showTheLoveAction
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [_chatview addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), _chatview.height - 100);
    heart.center = fountainSource;
    [heart animateInView:_chatview];
}

- (void)closeButtonAction
{
    [self.playerManager.mediaPlayer.player.view removeFromSuperview];
    [self.playerManager.controlVC.view removeFromSuperview];
    [self.playerManager.mediaPlayer.player shutdown];
    self.playerManager.mediaPlayer = nil;
    self.playerManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UCloudPlayerPlaybackDidFinishNotification object:nil];
    
    __weak typeof(self) weakSelf =  self;
    NSString *chatroomId = [_room.chatroomId copy];
    [weakSelf.chatview leaveChatroomWithCompletion:^(BOOL success) {
        if (success) {
            [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:NULL];
        }
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshList object:@(YES)];
        }];
    }];
    
    [_burstTimer invalidate];
    _burstTimer = nil;
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
