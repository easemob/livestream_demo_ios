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

@interface EaseLiveViewController () <EaseChatViewDelegate>
{
    NSTimer *_burstTimer;
    EasePublishModel* _model;
}

@property (nonatomic, strong) PlayerManager *playerManager;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) EaseChatView *chatview;

@property (nonatomic, strong) UIImageView *printImageView;

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
    
    [self.view addSubview:self.chatview];
    [self.view addSubview:self.closeButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:UCloudPlayerPlaybackDidFinishNotification object:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    self.playerManager = [[PlayerManager alloc] init];
    self.playerManager.view = self.view;
    self.playerManager.viewContorller = self;
    float height = self.view.frame.size.height;
    [self.playerManager setPortraitViewHeight:height];
    
    __weak EaseLiveViewController *weakSelf = self;
    [self.playerManager buildMediaPlayer:_model.streamId completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view bringSubviewToFront:weakSelf.chatview];
            [weakSelf.view bringSubviewToFront:weakSelf.closeButton];
            [weakSelf.view layoutSubviews];
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.chatview joinChatroom];
    });
    
    _burstTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showTheLoveAction) userInfo:nil repeats:YES];
    
    [self setupForDismissKeyboard];
}

- (EaseChatView*)chatview
{
    if (_chatview == nil) {
        NSString *chatroomId = @"203138578711052716";
        if (_model.chatroomId.length > 0) {
            chatroomId = [_model.chatroomId copy];
        }
        _chatview = [[EaseChatView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 260, CGRectGetWidth(self.view.frame), 260) chatroomId:chatroomId];
        _chatview.delegate = self;
    }
    return _chatview;
}

- (UIButton*)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(KScreenWidth - 50, 20, 40, 40);
        _closeButton.titleLabel.font = [UIFont fontWithName:kEaseDefaultIconFont size:40];
        [_closeButton setTitle:kEaseCloseButton forState:UIControlStateNormal];
//        [_closeButton setImage:[UIImage imageNamed:@"live_close_top_pressed"] forState:UIControlStateHighlighted];
//        [_closeButton setImage:[UIImage imageNamed:@"live_close_top"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_burstTimer invalidate];
    _burstTimer = nil;
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
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image1= UIGraphicsGetImageFromCurrentImageContext();
    UIImage *image2 = [self.playerManager.mediaPlayer.player thumbnailImageAtCurrentTime];
    UIImage *image = [self _addImage:image2 toImage:image1];

    _printImageView = [[UIImageView alloc] initWithImage:image];
    _printImageView.frame = CGRectMake(KScreenWidth/4, KScreenHeight/4, KScreenWidth/2, KScreenHeight/2);
    _printImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _printImageView.layer.cornerRadius = 5.f;
    _printImageView.layer.borderWidth = 1.f;
    _printImageView.contentMode = UIViewContentModeScaleAspectFill;
    _printImageView.layer.masksToBounds = YES;
    [self.view addSubview:_printImageView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定保存到相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 1000;
    [alert show];
}

- (UIImage *)_addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
    UIGraphicsBeginImageContext(image1.size);
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
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

#pragma mark - Action

-(void)showTheLoveAction
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [self.chatview addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), CGRectGetHeight(self.chatview.frame) - 60);
    heart.center = fountainSource;
    [heart animateInView:self.chatview];
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
//
//    {
//        self.playerManager.supportInterOrtation = UIInterfaceOrientationMaskPortrait;
//        [self.playerManager awakeSupportInterOrtation:self.playerManager.viewContorller completion:^{
//            self.playerManager.supportInterOrtation = UIInterfaceOrientationMaskAllButUpsideDown;
//        }];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:UCloudMoviePlayerClickBack object:self.playerManager];
    
    self.playerManager = nil;
    
    __weak EaseLiveViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL flag = [weakSelf.chatview leaveChatroom];
        if (flag) {
            [[EMClient sharedClient].chatManager deleteConversation:_model.chatroomId deleteMessages:YES];
        }
    });
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UCloudPlayerPlaybackDidFinishNotification object:nil];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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

@end
