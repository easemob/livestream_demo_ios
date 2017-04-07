//
//  EaseChatView.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "EaseChatView.h"
#import "EaseInputTextView.h"
#import "EaseChatCell.h"
#import "EaseLiveRoom.h"

#define kGiftAction @"cmd_gift"
#define kPraiseAction @"cmd_live_praise"
#define kPraiseCount @"live_praise_count"

#define kBarrageAction @"is_barrage_msg"

#define kButtonWitdh 40
#define kButtonHeight 40

#define kDefaultSpace 5.f
#define kDefaulfLeftSpace 10.f

@interface EaseChatView () <EMChatManagerDelegate,EMChatroomManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,EMFaceDelegate>
{
    NSString *_chatroomId;
    EaseLiveRoom *_room;
    EMChatroom *_chatroom;
    NSInteger _praiseCount;
    
    long long _curtime;
    CGFloat _previousTextViewContentHeight;
    CGFloat _defaultHeight;
}

@property (strong, nonatomic) NSMutableArray *datasource;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) EaseInputTextView *textView;


//底部功能按钮
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *sendTextButton;
@property (strong, nonatomic) UIButton *changeCameraButton;
@property (strong, nonatomic) UIButton *adminButton;
@property (strong, nonatomic) UIButton *likeButton;

@property (strong, nonatomic) UIView *bottomSendMsgView;
@property (strong, nonatomic) UIButton *faceButton;
@property (strong, nonatomic) EMConversation *conversation;

@property (strong, nonatomic) UIView *faceView;
@property (strong, nonatomic) UIView *activityView;

@end

@implementation EaseChatView

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
                    isPublish:(BOOL)isPublish
{
    self = [super initWithFrame:frame];
    if (self) {
        _chatroomId = chatroomId;
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
        self.datasource = [NSMutableArray array];
        self.conversation = [[EMClient sharedClient].chatManager getConversation:_chatroomId type:EMConversationTypeChatRoom createIfNotExist:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self addSubview:self.tableView];

        //底部消息发送按钮
        [self addSubview:self.bottomSendMsgView];
        [self.bottomSendMsgView addSubview:self.textView];
        [self.bottomSendMsgView addSubview:self.faceButton];
        //底部功能按钮
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.sendTextButton];
        if (isPublish) {
            [self.bottomView addSubview:self.adminButton];
            [self.bottomView addSubview:self.changeCameraButton];
        } else {
            [self.bottomView addSubview:self.likeButton];
        }
        
        self.bottomSendMsgView.hidden = YES;
        _curtime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
        _defaultHeight = self.height;
    }
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
{
    self = [self initWithFrame:frame chatroomId:room.chatroomId isPublish:isPublish];
    if (self) {
        _room = room;
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
}

- (UITableView*)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, CGRectGetHeight(self.bounds) - 48.f) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        _sendTextButton.frame = CGRectMake(kDefaultSpace*2, 6.f, kButtonWitdh, kButtonHeight);
        [_sendTextButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [_sendTextButton addTarget:self action:@selector(sendTextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendTextButton;
}

- (UIButton*)changeCameraButton
{
    if (_changeCameraButton == nil) {
        _changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeCameraButton.frame = CGRectMake(KScreenWidth - kDefaultSpace*2 - kButtonWitdh, 6.f, kButtonWitdh, kButtonHeight);
        [_changeCameraButton setImage:[UIImage imageNamed:@"reversal_camera"] forState:UIControlStateNormal];
        [_changeCameraButton addTarget:self action:@selector(changeCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeCameraButton;
}

- (UIButton*)likeButton
{
    if (_likeButton == nil) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.frame = CGRectMake(KScreenWidth - kDefaultSpace*2 - kButtonWitdh, 6.f, kButtonWitdh, kButtonHeight);
        [_likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(praiseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

- (UIButton*)adminButton
{
    if (_adminButton == nil) {
        _adminButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _adminButton.frame = CGRectMake(CGRectGetMaxX(_sendTextButton.frame) + kDefaultSpace*2, 6.f, kButtonWitdh, kButtonHeight);
        [_adminButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        [_adminButton addTarget:self action:@selector(adminAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adminButton;
}

- (UIView*)bottomSendMsgView
{
    if (_bottomSendMsgView == nil) {
        _bottomSendMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(self.bounds), 50.f)];
        _bottomSendMsgView.backgroundColor = RGBACOLOR(255, 255, 255, 1);
    }
    return _bottomSendMsgView;
}

- (EaseInputTextView*)textView
{
    if (_textView == nil) {
        //输入框
        _textView = [[EaseInputTextView alloc] initWithFrame:CGRectMake(kDefaulfLeftSpace, 10.f, CGRectGetWidth(self.bounds) - CGRectGetWidth(self.faceButton.frame) - kDefaulfLeftSpace*3, 30.f)];
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
        _faceView = [[EaseFaceView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_bottomSendMsgView.frame), self.frame.size.width, 180)];
        [(EaseFaceView *)_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self _setupEmotion];
    }
    return _faceView;
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if ([message.conversationId isEqualToString:_chatroomId]) {
            if ([message.ext objectForKey:kBarrageAction]) {
                if (message.timestamp < _curtime) {
                    continue;
                }
                if (_delegate && [_delegate respondsToSelector:@selector(didReceiveBarrageWithCMDMessage:)]) {
                    [_delegate didReceiveBarrageWithCMDMessage:message];
                }
            } else {
                if ([self.datasource count] >= 200) {
                    [self.datasource removeObjectsInRange:NSMakeRange(0, 190)];
                }
                [self.datasource addObject:message];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datasource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
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
            EMCmdMessageBody *body = (EMCmdMessageBody*)message.body;
            if (body) {
                if ([body.action isEqualToString:kGiftAction]) {
                    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveGiftWithCMDMessage:)]) {
                        [_delegate didReceiveGiftWithCMDMessage:message];
                    }
                }
                
                if ([body.action isEqualToString:kPraiseAction]) {
                    if (_delegate && [_delegate respondsToSelector:@selector(didReceivePraiseWithCMDMessage:)]) {
                        [_delegate didReceivePraiseWithCMDMessage:message];
                    }
                }
            }
        }
    }
}

#pragma mark - EMChatroomManagerDelegate

- (void)chatroomAdminListDidUpdate:(EMChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin;
{
    if ([aChatroom.chatroomId isEqualToString:_chatroomId]) {
        if ([aAdmin isEqualToString:[EMClient sharedClient].currentUsername]) {
            [self.bottomView addSubview:self.adminButton];
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
    
}

#pragma  mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    EMMessage *message = [self.datasource objectAtIndex:indexPath.row];
    return [EaseChatCell heightForMessage:message];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell";
    EaseChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EaseChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    EMMessage *message = [self.datasource objectAtIndex:indexPath.row];
    [cell setMesssage:message];
    return cell;
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
    EMMessage *message = [self.datasource objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectUserWithMessage:)]) {
        [self.delegate didSelectUserWithMessage:message];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length > 0 && [text isEqualToString:@"\n"]) {
        [self sendText];
        [self textViewDidChange:self.textView];
        return NO;
    }
    [self textViewDidChange:self.textView];
    return YES;
}

#pragma mark - EMFaceDelegate

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
}

- (void)sendFace
{
    NSString *chatText = self.textView.text;
    if (chatText.length > 0) {
        [self sendText];
        self.textView.text = @"";
    }
    [self textViewDidChange:self.textView];
}

- (void)sendFaceWithEmotion:(EaseEmotion *)emotion
{

}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    if (self.activityView) {
        [self _willShowBottomView:nil];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeChatViewDidChangeFrameToHeight:)]) {
        CGFloat toHeight = endFrame.size.height + self.frame.size.height + (self.textView.height - 30);
        [self.delegate easeChatViewDidChangeFrameToHeight:toHeight];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self _willShowBottomView:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:textView] refresh:NO];
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

#pragma mark - private

- (EMMessage *)_sendTextMessage:(NSString *)text
                             to:(NSString *)toUser
                    messageType:(EMChatType)messageType
                     messageExt:(NSDictionary *)messageExt

{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
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

- (void)_setupEmotion
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *emotion = [emotions objectAtIndex:0];
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
    [(EaseFaceView *)self.faceView setEmotionManagers:@[manager]];
}

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

- (void)sendTextAction
{
    [self _setSendState:YES];
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.textView] refresh:YES];
}

- (void)sendText
{
    if (self.textView.text.length > 0) {
        EMMessage *message = [self _sendTextMessage:self.textView.text to:_chatroomId messageType:EMChatTypeChatRoom messageExt:nil];
        __weak EaseChatView *weakSelf = self;
        [[EMClient sharedClient].chatManager sendMessage:message progress:NULL completion:^(EMMessage *message, EMError *error) {
            if (!error) {
                if ([weakSelf.datasource count] >= 200) {
                    [weakSelf.datasource removeObjectsInRange:NSMakeRange(0, 190)];
                }
                [weakSelf.datasource addObject:message];
                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.datasource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            } else {
                [MBProgressHUD showError:@"消息发送失败" toView:weakSelf];
            }
        }];
        self.textView.text = @"";
    }
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

- (void)changeCameraAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectChangeCameraButton)]) {
        [_delegate didSelectChangeCameraButton];
        _changeCameraButton.selected = !_changeCameraButton.selected;
    }
}

- (void)adminAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectAdminButton:)]) {
        BOOL isOwner = NO;
        if (_chatroom && _chatroom.permissionType == EMChatroomPermissionTypeOwner) {
            isOwner = YES;
        }
        [_delegate didSelectAdminButton:isOwner];
        _adminButton.selected = !_adminButton.selected;
    }
}

- (void)praiseAction
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_uploadPraiseCountToServer) object:nil];
    EMMessage *message = [self _sendCMDMessageTo:_chatroomId messageType:EMChatTypeChatRoom messageExt:@{kPraiseCount:@(1)} action:kPraiseAction];
    __weak EaseChatView *weakSelf = self;
    [[EMClient sharedClient].chatManager sendMessage:message progress:NULL completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didReceivePraiseWithCMDMessage:)]) {
                [weakSelf.delegate didReceivePraiseWithCMDMessage:message];
            }
            _praiseCount++;
            [weakSelf performSelector:@selector(_uploadPraiseCountToServer) withObject:nil afterDelay:10.f];
        }
    }];
}

- (void)_uploadPraiseCountToServer
{
    [[EaseHttpManager sharedInstance] savePraiseCountToServerWithRoomId:_room.roomId
                                                                  count:_praiseCount
                                                             completion:^(NSInteger count, BOOL success) {
                                                                 if (success) {
                                                                     _praiseCount = 0;
                                                                 }
                                                             }];
}

#pragma mark - public

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    [self _willShowBottomView:nil];
    [self _setSendState:NO];
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
                                                              BOOL ret = _chatroom.permissionType == EMChatroomPermissionTypeAdmin || _chatroom.permissionType == EMChatroomPermissionTypeOwner;
                                                              if (ret) {
                                                                  [weakSelf.bottomView addSubview:weakSelf.adminButton];
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

- (void)sendGiftWithId:(NSString*)giftId
{
    EMMessage *message = [self _sendCMDMessageTo:_chatroomId messageType:EMChatTypeChatRoom messageExt:nil action:kGiftAction];
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            EMCmdMessageBody *body = (EMCmdMessageBody*)message.body;
            if (body) {
                if ([body.action isEqualToString:kGiftAction]) {
                    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveGiftWithCMDMessage:)]) {
                        [_delegate didReceiveGiftWithCMDMessage:message];
                    }
                }
            }
        } else {
            //发送失败
        }
    }];
}

- (void)sendMessageAtWithUsername:(NSString *)username
{
    self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"@%@ ",username]];
    [self _setSendState:YES];
}


@end
