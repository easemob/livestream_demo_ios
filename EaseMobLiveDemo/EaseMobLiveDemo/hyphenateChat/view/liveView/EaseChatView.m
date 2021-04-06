//
//  EaseChatView.m
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "EaseChatView.h"
#import "EaseInputTextView.h"
#import "EaseChatCell.h"
#import "EaseLiveRoom.h"
#import "EaseCustomSwitch.h"
#import "EaseEmoticonView.h"
#import "Masonry.h"

#define kGiftAction @"cmd_gift"
#define kPraiseAction @"cmd_live_praise"
#define kPraiseCount @"live_praise_count"

#define kBarrageAction @"is_barrage_msg"

#define kButtonWitdh 40
#define kButtonHeight 40

#define kDefaultSpace 8.f
#define kDefaulfLeftSpace 10.f

NSMutableDictionary *audienceNickname;//直播间观众昵称库

@interface EaseChatView () <EMChatManagerDelegate,EMChatroomManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,EaseEmoticonViewDelegate>
{
    NSString *_chatroomId;
    EaseLiveRoom *_room;
    EMChatroom *_chatroom;
    
    long long _curtime;
    CGFloat _previousTextViewContentHeight;
    CGFloat _defaultHeight;
    
    BOOL _isBarrageInfo;//弹幕消息
    
    NSTimer *_timer;
    NSInteger _praiseInterval;//点赞间隔
    NSInteger _praiseCount;//点赞计数
    
    EaseCustomMessageHelper* _customMsgHelper;
}

@property (strong, nonatomic) NSMutableArray *datasource;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) EaseInputTextView *textView;


//底部功能按钮
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *sendTextButton;
@property (strong, nonatomic) UIButton *changeCameraButton;
@property (strong, nonatomic) UIButton *adminButton;//成员列表
@property (strong, nonatomic) UIButton *exitButton;//退出
@property (strong, nonatomic) UIButton *likeButton;//喜欢/赞
@property (strong, nonatomic) UIButton *giftButton;//礼物

@property (strong, nonatomic) UIView *bottomSendMsgView;
@property (strong, nonatomic) EaseCustomSwitch *barrageSwitch;//弹幕开关
@property (strong, nonatomic) UIButton *faceButton;//表情
@property (strong, nonatomic) UIButton *sendButton;//发送按钮
@property (strong, nonatomic) EMConversation *conversation;

@property (strong, nonatomic) UIView *faceView;
@property (strong, nonatomic) UIView *activityView;

@end

BOOL isAllTheSilence;//全体禁言
@implementation EaseChatView

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
                    isPublish:(BOOL)isPublish
              
{
    self = [super initWithFrame:frame];
    if (self) {
        _chatroomId = chatroomId;
        _isBarrageInfo = false;
        _praiseInterval = 0;
        _praiseCount = 0;
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
        self.datasource = [NSMutableArray array];
        self.conversation = [[EMClient sharedClient].chatManager getConversation:_chatroomId type:EMConversationTypeChatRoom createIfNotExist:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self addSubview:self.tableView];

        //底部消息发送按钮
        [self addSubview:self.bottomSendMsgView];
        [self.bottomSendMsgView addSubview:self.barrageSwitch];
        [self.bottomSendMsgView addSubview:self.textView];
        [self.bottomSendMsgView addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textView);
            make.left.equalTo(self.textView.mas_right).offset(5);
            make.right.equalTo(self).offset(-5);
            make.height.equalTo(@30);
        }];
        //底部功能按钮
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.sendTextButton];
        [self.bottomView addSubview:self.exitButton];
        if (!isPublish) {
            [self.bottomView addSubview:self.likeButton];
        } else {
            [self.bottomView addSubview:self.changeCameraButton];
        }
        [self.bottomView addSubview:self.giftButton];
        self.bottomSendMsgView.hidden = YES;
        _curtime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
        _defaultHeight = self.height;

    }
    audienceNickname = [[NSMutableDictionary alloc]init];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
{
    return [self initWithFrame:frame chatroomId:chatroomId isPublish:NO];
}

- (instancetype)initWithFrame:(CGRect)frame
                         room:(EaseLiveRoom*)room
                    isPublish:(BOOL)isPublish
                customMsgHelper:(EaseCustomMessageHelper*)customMsgHelper
{
    self = [self initWithFrame:frame chatroomId:room.chatroomId isPublish:isPublish];
    if (self) {
        _room = room;
        _customMsgHelper = customMsgHelper;
    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (!hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(easeChatViewDidChangeFrameToHeight:)]) {
            CGFloat toHeight = self.frame.size.height;
            [self.delegate easeChatViewDidChangeFrameToHeight:toHeight];
        }
    }
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimer];
}

- (UITableView*)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, CGRectGetHeight(self.bounds) - 48.f) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollsToTop = NO;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UIView*)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(self.bounds), kButtonHeight)];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

- (UIButton*)sendTextButton
{
    if (_sendTextButton == nil) {
        _sendTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendTextButton.frame = CGRectMake(kDefaultSpace*1.5, 0, kButtonWitdh, kButtonHeight);
        [_sendTextButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [_sendTextButton addTarget:self action:@selector(sendTextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendTextButton;
}

- (UIButton*)changeCameraButton
{
    if (_changeCameraButton == nil) {
        _changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeCameraButton.frame = CGRectMake(KScreenWidth - kDefaultSpace*2 - 2*kButtonWitdh, 0, kButtonWitdh, kButtonHeight);
        [_changeCameraButton setImage:[UIImage imageNamed:@"reversal_camera"] forState:UIControlStateNormal];
        [_changeCameraButton addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeCameraButton;
}

- (UIButton*)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitButton.frame = CGRectMake(KScreenWidth - kDefaultSpace*3 - 3*kButtonWitdh, 0, kButtonWitdh, kButtonHeight);
        [_exitButton setImage:[UIImage imageNamed:@"ic_exit"] forState:UIControlStateNormal];
        _exitButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        _exitButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:92/255.0 blue:92/255.0 alpha:0.25];
        _exitButton.layer.cornerRadius = kButtonWitdh / 2;
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitButton;
}

- (UIButton*)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.frame = CGRectMake(KScreenWidth - kDefaultSpace*2 - 2*kButtonWitdh, 0, kButtonWitdh, kButtonHeight);
        _likeButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.25];
        _likeButton.layer.cornerRadius = kButtonWitdh / 2;
        [_likeButton setImage:[UIImage imageNamed:@"ic_praise"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"ic_praised"] forState:UIControlStateHighlighted];
        [_likeButton addTarget:self action:@selector(praiseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton*)giftButton
{
    if (_giftButton == nil) {
        _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _giftButton.frame = CGRectMake(KScreenWidth - kDefaultSpace - kButtonWitdh, 0, kButtonWitdh, kButtonHeight);
        _giftButton.backgroundColor = [UIColor colorWithRed:240/255.0 green:85/255.0 blue:34/255.0 alpha:1.0];
        _giftButton.layer.cornerRadius = kButtonWitdh / 2;
        [_giftButton setImage:[UIImage imageNamed:@"ic_Gift"] forState:UIControlStateNormal];
        [_giftButton addTarget:self action:@selector(giftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftButton;
}

- (UIButton*)adminButton
{
    if (_adminButton == nil) {
        _adminButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _adminButton.frame = CGRectMake(CGRectGetMaxX(_sendTextButton.frame) + kDefaultSpace*2, 0, kButtonWitdh, kButtonHeight);
        [_adminButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        //[_adminButton addTarget:self action:@selector(adminAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminButton;
}

- (UIView*)bottomSendMsgView
{
    if (_bottomSendMsgView == nil) {
        _bottomSendMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(self.bounds), 50.f)];
        _bottomSendMsgView.backgroundColor = RGBACOLOR(255, 255, 255, 1);
        _bottomSendMsgView.layer.borderWidth = 1;
        _bottomSendMsgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return _bottomSendMsgView;
}

- (EaseCustomSwitch*)barrageSwitch
{
    if (_barrageSwitch == nil) {
        _barrageSwitch = [[EaseCustomSwitch alloc]initWithTextFont:[UIFont systemFontOfSize:12.f] OnText:@"弹" offText:@"弹" onBackGroundColor:RGBACOLOR(4, 174, 240, 1) offBackGroundColor:RGBACOLOR(191, 191, 191, 1) onButtonColor:RGBACOLOR(255, 255, 255, 1) offButtonColor:RGBACOLOR(255, 255, 255, 1) onTextColor:RGBACOLOR(4, 174, 240, 1) andOffTextColor:RGBACOLOR(191, 191, 191, 1) isOn:NO frame:CGRectMake(5.f, 13.f, 44.f, 24.f)];
        _barrageSwitch.changeStateBlock = ^(BOOL isOn) {
            _isBarrageInfo = isOn;
        };
    }
    return _barrageSwitch;
}

- (EaseInputTextView*)textView
{
    if (_textView == nil) {
        //输入框
        _textView = [[EaseInputTextView alloc] initWithFrame:CGRectMake(kDefaulfLeftSpace + 44, 10.f, CGRectGetWidth(self.bounds) - CGRectGetWidth(self.faceButton.frame) - kDefaulfLeftSpace*3 - 44, 30.f)];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textView.scrollEnabled = YES;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        _textView.placeHolder = NSLocalizedString(@"chat.input.placeholder", @"input a new message");
        _textView.delegate = self;
        _textView.backgroundColor = RGBACOLOR(236, 236, 236, 1);
        _textView.layer.cornerRadius = 4.0f;
        _previousTextViewContentHeight = [self _getTextViewContentH:_textView];
    }
    return _textView;
}

- (UIButton*)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.backgroundColor = [UIColor lightGrayColor];
        _sendButton.tag = 0;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendButton.layer.cornerRadius = 3;
        [_sendButton addTarget:self action:@selector(sendMsgAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIButton*)faceButton
{
    if (_faceButton == nil) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 30 - kDefaulfLeftSpace, 10.f, 30, 30);
        [_faceButton setImage:[UIImage imageNamed:@"input_bar_1_icon_face"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"input_bar_1_icon_keyboard"] forState:UIControlStateSelected];
        [_faceButton addTarget:self action:@selector(faceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIView*)faceView
{
    if (_faceView == nil) {
        _faceView = [[EaseEmoticonView alloc] initWithOutlineFrame:CGRectMake(0, CGRectGetMaxY(_bottomSendMsgView.frame), self.frame.size.width, 180)];
        [(EaseEmoticonView *)_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        //[self _setupEmotion];
    }
    return _faceView;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([message.conversationId isEqualToString:_chatroomId]) {
            if ([self.datasource count] >= 200) {
                [self.datasource removeObjectsInRange:NSMakeRange(0, 190)];
            }
            [self.datasource addObject:message];
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.datasource count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        if ([message.conversationId isEqualToString:_chatroomId]) {
            if (message.timestamp < _curtime) {
                continue;
            }
        }
    }
}

#pragma mark - EMChatroomManagerDelegate

//有用户加入聊天室
- (void)userDidJoinChatroom:(EMChatroom *)aChatroom user:(NSString *)aUsername
{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"进入了直播间"];
    NSMutableDictionary *ext = [[NSMutableDictionary alloc]init];
    [ext setObject:@"em_join" forKey:@"em_join"];
    EMMessage *joinMsg = [[EMMessage alloc] initWithConversationID:aChatroom.chatroomId from:aUsername to:aChatroom.chatroomId body:body ext:ext];
    joinMsg.chatType = EMChatTypeChatRoom;
    if ([self.datasource count] >= 200) {
        [self.datasource removeObjectsInRange:NSMakeRange(0, 190)];
    }
    [self.datasource addObject:joinMsg];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.datasource count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin;
{
    if ([aChatroom.chatroomId isEqualToString:_chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            //[self.bottomView addSubview:self.adminButton];
            [self layoutSubviews];
        }
    }
}

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    if ([aChatroom.chatroomId isEqualToString:_chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self.adminButton removeFromSuperview];
            [self layoutSubviews];
        }
    }
}

- (void)chatroomOwnerDidUpdate:(EMChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    _chatroom = aChatroom;
    _room.anchor = aNewOwner;
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveRoomOwnerDidUpdate:newOwner:)]) {
        [self.delegate liveRoomOwnerDidUpdate:aChatroom newOwner:aNewOwner];
    }
}

#pragma  mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    EMMessage *message = [self.datasource objectAtIndex:indexPath.section];
    return [EaseChatCell heightForMessage:message];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell";
    EaseChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EaseChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (!self.datasource || [self.datasource count] < 1)
        return nil;
    EMMessage *message = [self.datasource objectAtIndex:indexPath.section];
    [cell setMesssage:message liveroom:_room];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *blank = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 5)];
    blank.backgroundColor = [UIColor clearColor];
    return blank;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.faceButton.selected = NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EMMessage *message = [self.datasource objectAtIndex:indexPath.section];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectUserWithMessage:)]) {
        [self.delegate didSelectUserWithMessage:message];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length > 0 && [text isEqualToString:@"\n"]) {
        if (_isBarrageInfo) {
            [self sendBarrageMsg:self.textView.text];
        } else {
            [self sendText];
        }
        [self textViewDidChange:self.textView];
        return NO;
    }
    [self textViewDidChange:self.textView];
    return YES;
}

#pragma mark - EaseEmoticonViewDelegate

- (void)didSelectedEmoticonModel:(EMEmoticonModel *)aModel
{
    if (aModel.type == EMEmotionTypeEmoji) {
        [self inputViewAppendText:aModel.name];
    }
}

- (void)didChatBarEmoticonViewSendAction
{
    [self sendFace];
    [self sendTextAction];
    [self textViewDidChange:self.textView];
}
/*
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    NSString *chatText = self.textView.text;
    
    if (!isDelete && str.length > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    } else {
        if (chatText.length > 0) {
            NSInteger length = 1;
            if (chatText.length >= 2) {
                NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                if ([EaseEmoji stringContainsEmoji:subStr]) {
                    length = 2;
                }
            }
            self.textView.text = [chatText substringToIndex:chatText.length-length];
        }
    }
    [self textViewDidChange:self.textView];
}*/

- (void)inputViewAppendText:(NSString *)aText
{
    if ([aText length] > 0) {
        self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, aText];
        [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.textView] refresh:YES];
    }
}

- (void)sendFace
{
    NSString *chatText = self.textView.text;
    if (chatText.length > 0) {
        if (_isBarrageInfo) {
            [self sendBarrageMsg:self.textView.text];
        } else {
            [self sendText];
        }
        self.textView.text = @"";
        [self textChangedExt];
    }
    [self textViewDidChange:self.textView];
}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    if (self.activityView) {
        [self _setSendState:NO];
        [self _willShowBottomView:nil];
    }
    
    //防止自定义数字键盘弹起导致本页面上移
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    if ([firstResponder isEqual:self.textView]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(easeChatViewDidChangeFrameToHeight:)]) {
            CGFloat toHeight = endFrame.size.height + self.frame.size.height + (self.textView.height - 30);
            [self.delegate easeChatViewDidChangeFrameToHeight:toHeight];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self _setSendState:NO];
    [self _willShowBottomView:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textView.text.length > 0 && ![self.textView.text isEqualToString:@""]) {
        self.sendButton.backgroundColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
        self.sendButton.tag = 1;
    } else {
        self.sendButton.backgroundColor = [UIColor lightGrayColor];
        self.sendButton.tag = 0;
    }
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:textView] refresh:NO];
}

- (void)textChangedExt
{
    if (self.textView.text.length > 0 && ![self.textView.text isEqualToString:@""]) {
        self.sendButton.backgroundColor = [UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0];
        self.sendButton.tag = 1;
    } else {
        self.sendButton.backgroundColor = [UIColor lightGrayColor];
        self.sendButton.tag = 0;
    }
}

+ (NSString *)latestMessageTitleForConversationModel:(EMMessage*)lastMessage;
{
    NSString *latestMessageTitle = @"";
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = ((EMTextMessageBody *)messageBody).text;
                latestMessageTitle = didReceiveText;
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"[语音]";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"[位置]";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = @"[视频]";
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = @"[文件]";
            } break;
            default: {
            } break;
        }
    }
    latestMessageTitle = [NSString stringWithFormat:@"%@: %@",lastMessage.from,latestMessageTitle];
    return latestMessageTitle;
}

- (EMMessage *)_sendTextMessage:(NSString *)text
                             to:(NSString *)toUser
                    messageType:(EMChatType)messageType
                     messageExt:(NSDictionary *)messageExt

{
    EMMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:messageExt];
    message.chatType = messageType;
    return message;
}

- (EMMessage *)_sendCMDMessageTo:(NSString *)toUser
                     messageType:(EMChatType)messageType
                      messageExt:(NSDictionary *)messageExt
                          action:(NSString*)action

{
    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:action];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:toUser from:from to:toUser body:body ext:messageExt];
    message.chatType = messageType;
    
    return message;
}

- (void)_setSendState:(BOOL)state
{
    if (state) {
        self.bottomSendMsgView.hidden = NO;
        self.bottomView.hidden = YES;
        [self.textView becomeFirstResponder];
    } else {
        self.bottomSendMsgView.hidden = YES;
        self.bottomView.hidden = NO;
        [self.textView resignFirstResponder];
    }
}

- (void)_willShowBottomView:(UIView *)bottomView
{
    if (![self.activityView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        if (bottomView != nil) {
            self.height = bottomHeight + _defaultHeight + (self.textView.height - 30);
        } else {
            self.height = bottomHeight + _defaultHeight;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(easeChatViewDidChangeFrameToHeight:)]) {
            [self.delegate easeChatViewDidChangeFrameToHeight:self.height];
        }
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.bottomSendMsgView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityView) {
            [self.activityView removeFromSuperview];
        }
        self.activityView = bottomView;
    }
}
/*
- (void)_setupEmotion
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *emotion = [emotions objectAtIndex:0];
 EaseEmotionManager *manager= [[EaseHttpManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
    [(EaseFaceView *)self.faceView setEmotionManagers:@[manager]];
}*/

- (CGFloat)_getTextViewContentH:(UITextView *)textView
{
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}

- (void)_willShowInputTextViewToHeight:(CGFloat)toHeight refresh:(BOOL)refresh
{
    if (toHeight < 30.f) {
        toHeight = 30.f;
    }
    if (toHeight > 90.f) {
        toHeight = 90.f;
    }
    
    if (toHeight == _previousTextViewContentHeight && !refresh) {
        return;
    } else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.bottomSendMsgView.frame;
        rect.size.height += changeHeight;
        self.bottomSendMsgView.frame = rect;
        
        [self.textView setContentOffset:CGPointMake(0.0f, (self.textView.contentSize.height - self.textView.frame.size.height) / 2) animated:YES];

        _previousTextViewContentHeight = toHeight;
    }
}


#pragma mark - action

- (void)sendMsgAction
{
    if (self.sendButton.tag == 1) {
        if (_isBarrageInfo) {
            [self sendBarrageMsg:self.textView.text];
        } else {
            [self sendText];
        }
    }
}

- (void)sendTextAction
{
    [self _setSendState:YES];
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.textView] refresh:YES];
}
//普通文本消息
- (void)sendText
{
    if (self.textView.text.length > 0) {
        EMMessage *message = [self _sendTextMessage:self.textView.text to:_chatroomId messageType:EMChatTypeChatRoom messageExt:nil];
        __weak EaseChatView *weakSelf = self;
        [[EMClient sharedClient].chatManager sendMessage:message progress:NULL completion:^(EMMessage *message, EMError *error) {
            if (!error) {
                [weakSelf currentViewDataFill:message];
            } else {
                [MBProgressHUD showError:@"消息发送失败" toView:weakSelf];
            }
        }];
        self.textView.text = @"";
        [self textChangedExt];
    }
}

//发送弹幕消息
- (void)sendBarrageMsg:(NSString*)text
{
    __weak EaseChatView *weakSelf = self;
    [_customMsgHelper sendCustomMessage:text num:0 to:_chatroomId messageType:EMChatTypeChatRoom customMsgType:customMessageType_barrage completion:^(EMMessage * _Nonnull message, EMError * _Nonnull error) {
        if (!error) {
            [_customMsgHelper barrageAction:message backView:self.superview];
            [weakSelf currentViewDataFill:message];
        } else {
            [MBProgressHUD showError:@"弹幕消息发送失败" toView:weakSelf];
        }
    }];
    self.textView.text = @"";
    [self textChangedExt];
}

- (void)faceAction
{
    _faceButton.selected = !_faceButton.selected;
    
    if (_faceButton.selected) {
        [self.textView resignFirstResponder];
        [self _willShowBottomView:self.faceView];
    } else {
        [self.textView becomeFirstResponder];
    }
}

//发送礼物
- (void)sendGiftAction:(NSString *)giftId
                   num:(NSInteger)num
                    completion:(void (^)(BOOL success))aCompletion

{
     __weak EaseChatView *weakSelf = self;
    [_customMsgHelper sendCustomMessage:giftId num:num to:_chatroomId messageType:EMChatTypeChatRoom customMsgType:customMessageType_gift completion:^(EMMessage * _Nonnull message, EMError * _Nonnull error) {
        bool ret = false;
        if (!error) {
            [weakSelf currentViewDataFill:message];
            ret = true;
        } else {
            ret = false;
            [MBProgressHUD showError:@"送礼物失败" toView:weakSelf];
        }
        aCompletion(ret);
    }];
}
//赞
- (void)praiseAction
{
    [_customMsgHelper praiseAction:self];
    ++_praiseCount;
    if (_praiseInterval != 0) {
        return;
    }
    [self startTimer];
}

- (void)_praiseOperate
{
    __weak EaseChatView *weakSelf = self;
    [_customMsgHelper sendCustomMessage:@"" num:_praiseCount to:_chatroomId messageType:EMChatTypeChatRoom customMsgType:customMessageType_praise completion:^(EMMessage * _Nonnull message, EMError * _Nonnull error) {
        if (!error) {
            _praiseCount = 0;
            [weakSelf currentViewDataFill:message];
        } else {
            [MBProgressHUD showError:@"点赞失败" toView:weakSelf];
        }
    }];
}

- (void)startTimer {
    [self stopTimer];
    _praiseInterval = 4 + (arc4random() % 3);
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setupPraiseInterval) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)setupPraiseInterval{
    if(_praiseInterval < 1){
        [self _praiseOperate];
        [self stopTimer];
        return;
    }
    _praiseInterval -= 1;
}

- (void)changeCameraAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectChangeCameraButton)]) {
        [_delegate didSelectChangeCameraButton];
        _changeCameraButton.selected = !_changeCameraButton.selected;
    }
}

- (void)exitAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedExitButton)]) {
        [self.delegate didSelectedExitButton];
    }
}

- (void)giftAction
{
    if ([_chatroom.owner isEqualToString:EMClient.sharedClient.currentUsername]) {
        //礼物列表
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectGiftButton:)]) {
            [_delegate didSelectGiftButton:YES];
        }
    } else {
        //送礼物
        if (_delegate && [_delegate respondsToSelector:@selector(didSelectGiftButton:)]) {
            [_delegate didSelectGiftButton:NO];
        }
    }
}

#pragma mark - private

//当前视图数据填充
- (void)currentViewDataFill:(EMMessage*)message
{
    if ([self.datasource count] >= 200) {
        [self.datasource removeObjectsInRange:NSMakeRange(0, 190)];
    }
    [self.datasource addObject:message];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.datasource count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - public

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    [self _setSendState:NO];
    [self _willShowBottomView:nil];
    self.faceButton.selected = NO;
    return result;
}

- (void)joinChatroomWithIsCount:(BOOL)aIsCount
                     completion:(void (^)(BOOL success))aCompletion
{
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] joinLiveRoomWithRoomId:_room.roomId
                                                  chatroomId:_room.chatroomId
                                                     isCount:aIsCount
                                                  completion:^(BOOL success) {
                                                      BOOL ret = NO;
                                                      if (success) {
                                                          EMError *error = nil;
                                                          _chatroom = [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:_chatroomId error:&error];
                                                          ret = YES;
                                                          if (!error) {
                                                              isAllTheSilence = _chatroom.isMuteAllMembers;
                                                              BOOL ret = _chatroom.permissionType == EMChatroomPermissionTypeAdmin || _chatroom.permissionType == EMChatroomPermissionTypeOwner;
                                                              if (ret) {
                                                                  //[weakSelf.bottomView addSubview:weakSelf.adminButton];
                                                                  [weakSelf layoutSubviews];
                                                              }
                                                          }
                                                      }
                                                      aCompletion(ret);
                                                  }];
}

- (void)leaveChatroomWithIsCount:(BOOL)aIsCount
                      completion:(void (^)(BOOL success))aCompletion
{
    __weak typeof(self) weakSelf = self;
    [[EaseHttpManager sharedInstance] leaveLiveRoomWithRoomId:_room.roomId
                                                   chatroomId:_room.chatroomId
                                                      isCount:aIsCount
                                                   completion:^(BOOL success) {
                                                       BOOL ret = NO;
                                                       if (success) {
                                                           [weakSelf.datasource removeAllObjects];
                                                           [[EMClient sharedClient].chatManager deleteConversation:_chatroomId isDeleteMessages:YES completion:NULL];
                                                           ret = YES;
                                                       }
                                                       aCompletion(ret);
                                                   }];
}

@end
