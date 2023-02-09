//
//  ELDChatView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/5/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDChatView.h"
#import "JPGiftCellModel.h"
#import "JPGiftModel.h"
#import "JPGiftShowManager.h"
#import "EaseLiveGiftHelper.h"
#import "EaseBarrageFlyView.h"
#import "EaseHeartFlyView.h"
#import "EaseUserInfoManagerHelper.h"
#import "EaseHeaders.h"

#define kExitButtonHeight 22.0
#define kExitBgViewHeight 32.0

#define kBottomButtonPadding 20.0

#define kGradientBgViewHeight 20.0

@interface ELDChatView ()<EaseChatViewDelegate>

@property (nonatomic, strong) UIView *gradientBgView;

@property (nonatomic, strong) UIView *functionAreaView;

@property (nonatomic, strong) UIButton *changeCameraButton;
@property (nonatomic, strong) UIView *changeCameraBgView;

@property (nonatomic, strong) UIButton *chatListShowButton;
@property (nonatomic, strong) UIView *chatListShowBgView;

@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UIView *exitBgView;
@property (nonatomic, strong) UIButton *giftButton;


@property (assign, nonatomic) BOOL isPublish;
@property (assign, nonatomic) BOOL isHiddenChatListView;


//custom chatView UI with option
@property (nonatomic, strong) EaseChatViewCustomOption *customOption;

@end


@implementation ELDChatView
#pragma mark life cycle
- (instancetype)initWithFrame:(CGRect)frame
                     chatroom:(EMChatroom *)chatroom
                    isPublish:(BOOL)isPublish
              customMsgHelper:(EaseCustomMessageHelper *)customMsgHelper {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.isPublish = isPublish;
        self.chatroom = chatroom;
        self.customOption = [EaseChatViewCustomOption customOption];
        if (!self.isPublish) {
            self.customOption.sendTextButtonRightMargin = 140.0;
        }else {
            self.customOption.sendTextButtonRightMargin = 0;
        }
        
        self.easeChatView = [[EaseChatView alloc] initWithFrame:frame chatroom:self.chatroom customMsgHelper:customMsgHelper customOption:self.customOption];
        self.easeChatView.delegate = self;
        if (self.isPublish) {
            [self.easeChatView updateSendTextButtonHint:NSLocalizedString(@"message.sayHiToFans", nil)];
        }else {
            [self.easeChatView updateSendTextButtonHint:NSLocalizedString(@"message.sayHi", nil)];
        }
        
        [self placeAndLayoutBottomView];

    }
    return self;
}


- (void)placeAndLayoutBottomView {
    [self addSubview:self.easeChatView];
    [self addSubview:self.functionAreaView];
        
    [self.functionAreaView addSubview:self.chatListShowBgView];
    [self.functionAreaView addSubview:self.chatListShowButton];
    
    [self.easeChatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];


    [self.functionAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.easeChatView.sendTextButton);
        make.left.lessThanOrEqualTo(self.easeChatView.sendTextButton.mas_right);
        make.right.equalTo(self);
        make.height.equalTo(self.easeChatView.sendTextButton);
    }];
    
    
    if (self.isPublish) {
        [self.functionAreaView addSubview:self.exitBgView];
        [self.functionAreaView addSubview:self.exitButton];

        [self.functionAreaView addSubview:self.changeCameraBgView];
        [self.functionAreaView addSubview:self.changeCameraButton];

    
        [self.exitBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.exitButton);
            make.size.equalTo(@(kExitBgViewHeight));
        }];
        
        [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.functionAreaView.mas_right).offset(-20.0);
            make.size.equalTo(@(kExitButtonHeight));
        }];

        [self.changeCameraBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.changeCameraButton);
            make.size.equalTo(@(kExitBgViewHeight));
        }];
        
        [self.changeCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.exitButton.mas_left).offset(-kBottomButtonPadding);
            make.size.equalTo(self.exitButton);
        }];
        
        [self.chatListShowBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.chatListShowButton);
            make.size.equalTo(@(kExitBgViewHeight));
        }];

        [self.chatListShowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.changeCameraButton.mas_left).offset(-kBottomButtonPadding);
            make.size.equalTo(self.exitButton);
        }];
    }else {
        [self.functionAreaView addSubview:self.giftButton];
        
//        [self.easeChatView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self);
//            make.left.equalTo(self);
//            make.right.equalTo(self).offset(-116.0);
//            make.bottom.equalTo(self);
//        }];
                
        [self.giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.functionAreaView.mas_right).offset(-20.0);
            make.size.equalTo(@(kExitBgViewHeight));
        }];

        [self.chatListShowBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.chatListShowButton);
            make.size.equalTo(@(kExitBgViewHeight));
        }];
        
        [self.chatListShowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionAreaView);
            make.right.equalTo(self.giftButton.mas_left).offset(-kBottomButtonPadding);
            make.size.equalTo(self.giftButton);
        }];
        
      
    }

}


#pragma mark EaseChatViewDelegate
- (void)chatViewDidBottomOffset:(CGFloat)offset {
    
    BOOL hidden = offset > 0 ? YES : NO;
    
    if (self.isPublish) {
        self.chatListShowButton.hidden = hidden;
        self.chatListShowBgView.hidden = hidden;
        self.changeCameraButton.hidden = hidden;
        self.changeCameraBgView.hidden = hidden;
        self.exitButton.hidden = hidden;
        self.exitBgView.hidden = hidden;
    }else {
        self.chatListShowButton.hidden = hidden;
        self.chatListShowBgView.hidden = hidden;
        self.giftButton.hidden = hidden;
    }
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidBottomOffset:)]) {
        [self.delegate chatViewDidBottomOffset:offset];
    }
}

- (void)didSelectUserWithMessage:(EMChatMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectUserWithMessage:)]) {
        [self.delegate didSelectUserWithMessage:message];
    }

}


- (void)chatViewDidSendMessage:(EMChatMessage *)message error:(EMError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatViewDidSendMessage:error:)]) {
        [self.delegate chatViewDidSendMessage:message error:error];
    }
}

#pragma mark user join chatroom
- (void)insertJoinMessageWithChatroom:(EMChatroom *)aChatroom user:(NSString *)aUsername {
    if (![self.chatroom.chatroomId isEqualToString:aChatroom.chatroomId]) {
        return;
    }
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"join the live room"];
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]init];
    [ext setObject:EaseKit_chatroom_join forKey:EaseKit_chatroom_join];
    EMChatMessage *joinMsg = [[EMChatMessage alloc] initWithConversationID:aChatroom.chatroomId from:aUsername to:aChatroom.chatroomId body:body ext:ext];
    joinMsg.chatType = EMChatTypeChatRoom;
    if ([self.easeChatView.datasource count] >= 200) {
        [self.easeChatView.datasource removeObjectsInRange:NSMakeRange(0, 190)];
    }
    [self.easeChatView.datasource addObject:joinMsg];
    [self.easeChatView.tableView reloadData];
    [self.easeChatView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.easeChatView.datasource count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark chatroom operation
- (void)showGiftModel:(ELDGiftModel*)aGiftModel
              giftNum:(NSInteger)giftNum
             backView:(UIView*)backView {
    
    [EaseUserInfoManagerHelper fetchOwnUserInfoCompletion:^(EMUserInfo * _Nonnull ownUserInfo) {
               
        JPGiftModel *giftModel = [[JPGiftModel alloc]init];
        giftModel.userAvatarURL = ownUserInfo.avatarUrl;
        giftModel.userName = ownUserInfo.nickname ?: ownUserInfo.userId;
        giftModel.giftName = aGiftModel.giftname;
        giftModel.giftImage = ImageWithName(aGiftModel.giftname);;
        giftModel.defaultCount = 0;
        giftModel.sendCount = giftNum;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[JPGiftShowManager sharedManager] showGiftViewWithBackView:backView info:giftModel completeBlock:^(BOOL finished) {
                       //结束
                } completeShowGifImageBlock:^(JPGiftModel *giftModel) {
            }];

        });
    }];
}


//有观众送礼物
- (void)userSendGiftId:(NSString *)giftId
               giftNum:(NSInteger)giftNum
                userId:(NSString *)userId
              backView:(UIView*)backView {
        
    int giftIndex = [[giftId substringFromIndex:5] intValue];
    ELDGiftModel *model = EaseLiveGiftHelper.sharedInstance.giftArray[giftIndex-1];
    
    [self showGiftModel:model giftNum:giftNum backView:backView];
}


//弹幕动画
- (void)barrageAction:(EMChatMessage*)msg backView:(UIView*)backView
{
    EaseBarrageFlyView *barrageView = [[EaseBarrageFlyView alloc]initWithMessage:msg];
    [backView addSubview:barrageView];
    [barrageView animateInView:backView];
}

//点赞动画
- (void)praiseAction:(UIView*)backView
{
    EaseHeartFlyView* heart = [[EaseHeartFlyView alloc]initWithFrame:CGRectMake(0, 0, 55, 50)];
    [backView addSubview:heart];
    CGPoint fountainSource = CGPointMake(KScreenWidth - (20 + 50/2.0), backView.height);
    heart.center = fountainSource;
    [heart animateInView:backView];
}

- (void)reloadTableView {
    [self.easeChatView.tableView reloadData];
}

#pragma mark actions
- (void)changeCameraAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectChangeCameraButton)]) {
        [_delegate didSelectChangeCameraButton];
        _changeCameraButton.selected = !_changeCameraButton.selected;
    }
}

- (void)chatListShowButtonAction:(id)sender {
  
    self.isHiddenChatListView = !self.isHiddenChatListView;
    
    if (self.isHiddenChatListView) {
        [_chatListShowButton setImage:ImageWithName(@"live_chatlist_normal") forState:UIControlStateNormal];
    }else {
        [_chatListShowButton setImage:ImageWithName(@"live_chatlist_hidden") forState:UIControlStateNormal];
    }
        
    [self.easeChatView updateChatViewWithHidden:self.isHiddenChatListView];
}


- (void)exitAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedExitButton)]) {
        [self.delegate didSelectedExitButton];
    }
}

- (void)giftAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectGiftButton)]) {
        [_delegate didSelectGiftButton];
    }
}


#pragma mark getter and setter
- (UIView *)gradientBgView {
    if (_gradientBgView == nil) {
        _gradientBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        [_gradientBgView addTransitionColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] endColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1] startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
    }
    return _gradientBgView;
}

- (UIView*)functionAreaView
{
    if (_functionAreaView == nil) {
        _functionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 40.0)];
        _functionAreaView.backgroundColor = [UIColor clearColor];
    }
    return _functionAreaView;
}


- (UIButton*)changeCameraButton
{
    if (_changeCameraButton == nil) {
        _changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeCameraButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_changeCameraButton setImage:[UIImage imageNamed:@"flip_camera_ios"] forState:UIControlStateNormal];
        [_changeCameraButton addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];

    }
    return _changeCameraButton;
}

- (UIView *)changeCameraBgView {
    if (_changeCameraBgView == nil) {
        _changeCameraBgView = [[UIView alloc] init];
        _changeCameraBgView.backgroundColor = ELDBlackAlphaColor;
        _changeCameraBgView.layer.cornerRadius = kExitBgViewHeight * 0.5;
    }
    return _changeCameraBgView;
}

- (UIButton *)chatListShowButton {
    if (_chatListShowButton == nil) {
        _chatListShowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chatListShowButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_chatListShowButton setImage:ImageWithName(@"live_chatlist_hidden") forState:UIControlStateNormal];
        [_chatListShowButton addTarget:self action:@selector(chatListShowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatListShowButton;
}

- (UIView *)chatListShowBgView {
    if (_chatListShowBgView == nil) {
        _chatListShowBgView = [[UIView alloc] init];
        _chatListShowBgView.backgroundColor = ELDBlackAlphaColor;
        _chatListShowBgView.layer.cornerRadius = kExitBgViewHeight * 0.5;
    }
    return _chatListShowBgView;
}


- (UIButton*)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_exitButton setImage:[UIImage imageNamed:@"stop_live"] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _exitButton;
}

- (UIView *)exitBgView {
    if (_exitBgView == nil) {
        _exitBgView = [[UIView alloc] init];
        _exitBgView.backgroundColor = ELDBlackAlphaColor;
        _exitBgView.layer.cornerRadius = kExitBgViewHeight * 0.5;
    }
    return _exitBgView;
}


- (UIButton*)giftButton
{
    if (_giftButton == nil) {
        _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _giftButton.frame = CGRectMake(0, 0, KScreenWidth, 100);
        [_giftButton setImage:[UIImage imageNamed:@"live_gift"] forState:UIControlStateNormal];
        [_giftButton addTarget:self action:@selector(giftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftButton;
}


@end

#undef kExitButtonHeight
#undef kExitBgViewHeight
#undef kBottomButtonPadding
#undef kGradientBgViewHeight
