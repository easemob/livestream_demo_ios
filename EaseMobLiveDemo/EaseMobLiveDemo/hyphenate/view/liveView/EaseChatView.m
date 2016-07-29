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

#define kGiftAction @"cmd_gift"

#define kBarrageAction @"is_barrage_msg"

#define kButtonWitdh 40
#define kButtonHeight 40

#define kDefaultSpace 5

@interface EaseChatView () <EMChatManagerDelegate,EMChatroomManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    NSString *_chatroomId;
    
    long long _curtime;
}

@property (strong, nonatomic) NSMutableArray *datasource;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) EaseInputTextView *textView;


//底部功能按钮
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *msgButton;
@property (strong, nonatomic) UIButton *giftButton;
@property (strong, nonatomic) UIButton *printScreenButton;
@property (strong, nonatomic) UIButton *sendTextButton;
@property (strong, nonatomic) UIButton *redPacketButton;

@property (strong, nonatomic) UIView *bottomSendMsgView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) EMConversation *conversation;
@property (strong, nonatomic) UIButton *barrageButton;

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
        [self.bottomSendMsgView addSubview:self.sendButton];
        [self.bottomSendMsgView addSubview:self.barrageButton];
        //底部功能按钮
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.sendTextButton];
        if (!isPublish) {
            [self.bottomView addSubview:self.giftButton];
            [self.bottomView addSubview:self.msgButton];
            [self addSubview:self.printScreenButton];
            [self addSubview:self.redPacketButton];
        } else {
            [self.bottomView addSubview:self.msgButton];
            [self addSubview:self.printScreenButton];
            [self addSubview:self.redPacketButton];
        }
        
        self.bottomSendMsgView.hidden = YES;
        _curtime = (long long)([[NSDate date] timeIntervalSince1970]*1000);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                   chatroomId:(NSString*)chatroomId
{
    return [self initWithFrame:frame chatroomId:chatroomId isPublish:NO];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds) - 75, CGRectGetHeight(self.bounds) - 48.f) style:UITableViewStylePlain];
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
        [_sendTextButton setImage:[UIImage imageNamed:@"live_comments"] forState:UIControlStateNormal];
         [_sendTextButton setImage:[UIImage imageNamed:@"live_comments_click"] forState:UIControlStateHighlighted];
        [_sendTextButton addTarget:self action:@selector(sendTextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendTextButton;
}

- (UIButton*)redPacketButton
{
    if(_redPacketButton == nil) {
        _redPacketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _redPacketButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - kButtonWitdh - kDefaultSpace * 2, self.bottomView.top - kButtonHeight * 2 - kDefaultSpace * 8, kButtonWitdh, kButtonHeight);
        [_redPacketButton setImage:[UIImage imageNamed:@"live_redbag"] forState:UIControlStateNormal];
        [_redPacketButton setImage:[UIImage imageNamed:@"live_redbag_click"] forState:UIControlStateHighlighted];
        [_redPacketButton addTarget:self action:@selector(redPacketAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _redPacketButton;
}

- (UIButton*)printScreenButton
{
    if (_printScreenButton == nil) {
        _printScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _printScreenButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - kButtonWitdh - kDefaultSpace * 2, self.bottomView.top - kButtonHeight - kDefaultSpace * 4, kButtonWitdh, kButtonHeight);
        [_printScreenButton setImage:[UIImage imageNamed:@"live_share"] forState:UIControlStateNormal];
        [_printScreenButton setImage:[UIImage imageNamed:@"live_share_click"] forState:UIControlStateHighlighted];
        [_printScreenButton addTarget:self action:@selector(printScreenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _printScreenButton;
}

- (UIButton*)msgButton
{
    if (_msgButton == nil) {
        _msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _msgButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - kButtonWitdh - kDefaultSpace * 2, 6.f, kButtonWitdh, kButtonHeight);
        [_msgButton setImage:[UIImage imageNamed:@"live_message"] forState:UIControlStateNormal];
        [_msgButton setImage:[UIImage imageNamed:@"live_message_click"] forState:UIControlStateHighlighted];
        [_msgButton addTarget:self action:@selector(msgButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _msgButton;
}

- (UIButton*)giftButton
{
    if (_giftButton == nil) {
        _giftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _giftButton.frame = CGRectMake(CGRectGetWidth(self.bounds)/2 - kButtonWitdh/2, 6.f, kButtonWitdh, kButtonHeight);
        [_giftButton setImage:[UIImage imageNamed:@"live_gift"] forState:UIControlStateNormal];
        [_giftButton setImage:[UIImage imageNamed:@"live_gift_click"] forState:UIControlStateHighlighted];
        [_giftButton addTarget:self action:@selector(sendGiftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftButton;
}

- (UIView*)bottomSendMsgView
{
    if (_bottomSendMsgView == nil) {
        _bottomSendMsgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), CGRectGetWidth(self.bounds), 48.f)];
        _bottomSendMsgView.backgroundColor = RGBACOLOR(234, 234, 234, 1);
    }
    return _bottomSendMsgView;
}

- (EaseInputTextView*)textView
{
    if (_textView == nil) {
        //输入框
        _textView = [[EaseInputTextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.barrageButton.frame) + kDefaultSpace, 6.f, CGRectGetWidth(self.bounds) - CGRectGetWidth(self.barrageButton.frame) - CGRectGetWidth(self.sendButton.frame) - kDefaultSpace*4, 36.f)];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textView.scrollEnabled = YES;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        _textView.placeHolder = @"输入新消息";
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        _textView.layer.borderWidth = 0.65f;
        _textView.layer.cornerRadius = 6.0f;
    }
    return _textView;
}

- (UIButton*)sendButton
{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 60.f - kDefaultSpace, 6.f, 60, 36.f);
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setBackgroundColor:RGBACOLOR(45, 188, 251, 1)];
        _sendButton.layer.cornerRadius = 6.f;
        [_sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIButton*)barrageButton
{
    if (_barrageButton == nil) {
        _barrageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _barrageButton.frame = CGRectMake(kDefaultSpace, 6.f, 60.f, 36.f);
        [_barrageButton setImage:[UIImage imageNamed:@"swich_close"] forState:UIControlStateNormal];
        [_barrageButton setImage:[UIImage imageNamed:@"swich"] forState:UIControlStateSelected];
        [_barrageButton addTarget:self action:@selector(barrageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barrageButton;
}

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages
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
                [self.datasource addObject:message];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datasource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
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
        }
    }
}

#pragma mark - EMChatroomManagerDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"来了"];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroom.chatroomId from:aUsername to:aChatroom.chatroomId body:body ext:@{@"em_join":aUsername}];
    message.chatType = EMChatTypeChatRoom;
    [self.datasource addObject:message];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datasource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"离开了"];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroom.chatroomId from:aUsername to:aChatroom.chatroomId body:body ext:@{@"em_leave":aUsername}];
    message.chatType = EMChatTypeChatRoom;
    [self.datasource addObject:message];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datasource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveKickedFromChatroom:(EMChatroom *)aChatroom
                              reason:(EMChatroomBeKickedReason)aReason
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
    return YES;
}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeChatViewDidChangeFrameToHeight:)]) {
        CGFloat toHeight = endFrame.size.height + self.frame.size.height;
        [self.delegate easeChatViewDidChangeFrameToHeight:toHeight];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(easeChatViewDidChangeFrameToHeight:)]) {
        CGFloat toHeight = self.frame.size.height;
        [self.delegate easeChatViewDidChangeFrameToHeight:toHeight];
    }
    [self setSendState:NO];
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

- (void)setSendState:(BOOL)state
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

#pragma mark - action

- (void)msgButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMessageButton)]) {
        [self.delegate didSelectMessageButton];
    }
}

- (void)printScreenAction
{
    //截屏    
    UIGraphicsEndImageContext();
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPrintScreenButton)]) {
        [self.delegate didSelectPrintScreenButton];
    }
}

- (void)redPacketAction
{

}

- (void)sendGiftAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectGiftButton)]) {
        [_delegate didSelectGiftButton];
    }
}

- (void)sendTextAction
{
    [self setSendState:YES];
}

- (void)sendText
{
    if (self.textView.text.length > 0) {
        if (_barrageButton.selected) {
            EMMessage *message = [self _sendTextMessage:self.textView.text to:_chatroomId messageType:EMChatTypeChatRoom messageExt:@{kBarrageAction:@(1)}];
            __weak EaseChatView *weakSelf = self;
            [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error) {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didReceiveBarrageWithCMDMessage:)]) {
                        [weakSelf.delegate didReceiveBarrageWithCMDMessage:message];
                    }
                }
            }];
            
        } else {
            EMMessage *message = [self _sendTextMessage:self.textView.text to:_chatroomId messageType:EMChatTypeChatRoom messageExt:nil];
            __weak EaseChatView *weakSelf = self;
            [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error) {
                    [weakSelf.datasource addObject:message];
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.datasource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }];
        }
        self.textView.text = @"";
    }
}

- (void)barrageAction
{
    _barrageButton.selected = !_barrageButton.selected;
}

#pragma mark - public

- (BOOL)joinChatroom
{
    EMError *error = nil;
    [[EMClient sharedClient].roomManager joinChatroom:_chatroomId error:&error];
    if (!error) {
        return YES;
    }
    return NO;
}

- (BOOL)leaveChatroom
{
    EMError *error = nil;
    [[EMClient sharedClient].roomManager leaveChatroom:_chatroomId error:&error];
    if (!error) {
        [self.datasource removeAllObjects];
        [[EMClient sharedClient].chatManager deleteConversation:_chatroomId deleteMessages:YES];
        return YES;
    }
    return NO;
}

- (void)sendGiftWithId:(NSString*)giftId
{
    EMMessage *message = [self _sendCMDMessageTo:_chatroomId messageType:EMChatTypeChatRoom messageExt:nil action:kGiftAction];
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
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
    [self setSendState:YES];
}


@end
