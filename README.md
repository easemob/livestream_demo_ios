# 简介 #
本demo演示了通过环信sdk实现的直播聊天室

## 怎么使用本demo ##
- 首先在EaseMobLiveDemo文件夹下执行pod install,集成环信sdk
- 初次进入app时会自动注册一个UUID游客账号，默认密码000000，注册成功自动登录，自动登录完成跳转到主页面
- 点击主页底部“我要直播”蓝色按钮，选择一个可“立即开播”的直播间，点击进入该直播间基本信息页，键入封面图以及本次直播主题和描述后，点击“开始直播”开启一场直播
- 游客点击主页面任意一个直播间即可进入该直播间观看直播，在直播间目前可以发群聊消息、给主播点赞，给主播刷礼物，发弹幕等，当前直播间聊天室观众均可收到消息动画

## 功能实现 ##


### 我要直播
**具体演示代码见EaseLiveTVListViewController,EaseCreateLiveViewController,EasePublishViewController,EaseHttpManager**

1、获取直播聊天室列表
```
/*
 *  获取当前appKey下的直播房间列表
 *
 *  @param aPage          第几页
 *  @param aPageSize      每页大小
 *  @param aCompletion    完成的回调block
 */
- (void)fetchLiveRoomsWithCursor:(NSString*)aCursor
                            limit:(NSInteger)aLimit
                            completion:(void (^)(EMCursorResult *result, BOOL success))aCompletion;
```
2、设置当前将要直播的直播聊天室为“ongoing”正直播状态

```
/*
*  更新直播间状态为ongoing
*
*  @param aRoom            直播间
*  @param aCompletion      完成的回调block
*/
- (void)modifyLiveroomStatusWithOngoing:(EaseLiveRoom *)room
                             completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```
3、自定义直播聊天室封面信息，包括封面，主题，描述信息，并修改直播聊天室详情为自定义详情信息，该场直播结束后，任何用户也可在原有直播聊天室开始一场新的直播

```
/*
 *  修改直播聊天室详情
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)modifyLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```
4、加入聊天室

```
/*
 *  用户加入直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 *  @param aIsCount         是否计数
 *  @param aCompletion      完成的回调block
 */
- (void)joinLiveRoomWithRoomId:(NSString*)aRoomId
                    chatroomId:(NSString*)aChatroomId
                       isCount:(BOOL)aIsCount
                       completion:(void (^)(BOOL success))aCompletion;
```
5、设置消息监听

```
	 [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
	 
	- (void)messagesDidReceive:(NSArray *)aMessages
	{
	//收到普通消息
	}

	- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
	{
	//收到cmd消息
	}
```
6、发送消息

```
EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"发送内容"];
NSString *from = [[EMClient sharedClient] currentUsername];
EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroomId from:from to:aChatroomId body:body ext:nil];
message.chatType = EMChatTypeChatRoom;
[[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
	if (!error) {
	//消息发送成功
	}
}];   
``` 
7、获取直播聊天室成员列表

```
/*!
 *  获取聊天室成员列表
 *
 *  @param aChatroomId      聊天室ID
 *  @param aCursor          游标，首次调用传空
 *  @param aPageSize        获取多少条
 *  @param aCompletionBlock 完成的回调
 */
- (void)getChatroomMemberListFromServerWithId:(NSString *)aChatroomId
                                       cursor:(NSString *)aCursor
                                     pageSize:(NSInteger)aPageSize
                                     completion:(void (^)(EMCursorResult *aResult, EMError *aError))aCompletionBlock;
```
8、获取直播聊天室禁言列表

```
/*!
 *  获取聊天室被禁言列表
 *
 *  @param aChatroomId      聊天室ID
 *  @param aPageNum         获取第几页
 *  @param aPageSize        获取多少条
 *  @param aCompletionBlock 完成的回调
 */
- (void)getChatroomMuteListFromServerWithId:(NSString *)aChatroomId
                                 pageNumber:(NSInteger)aPageNum
                                   pageSize:(NSInteger)aPageSize
                                   completion:(void (^)(NSArray *aList, EMError *aError))aCompletionBlock;
```
9、直播聊天室某观众解除禁言

```
/*!
 *  解除禁言，需要Owner / Admin权限
 *
 *  @param aMuteMembers     被解除的列表<NSString>
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)unmuteMembers:(NSArray *)aMembers
                 fromChatroom:(NSString *)aChatroomId
                 completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
```
10、获取直播聊天室白名单列表

```
/*!
 *  获取聊天室白名单列表
 *
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)getChatroomWhiteListFromServerWithId:(NSString *)aChatroomId
        completion:(void (^)(NSArray *aList, EMError *aError))aCompletionBlock;
```
11、直播聊天室从白名单移除成员

```
/*!
 *  移除白名单，需要Owner / Admin权限
 *
 *  @param aMembers         被移除的列表<NSString>
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)removeWhiteListMembers:(NSArray *)aMembers
                  fromChatroom:(NSString *)aChatroomId
                  completion:(void (^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
```
12、直播聊天室全体禁言

```
/*!
 *  设置全员禁言，需要Owner / Admin权限
 *
 *  @param aChatroomId      聊天室ID
 *  @param aCompletionBlock 完成的回调
 */
- (void)muteAllMembersFromChatroom:(NSString *)aChatroomId
                  completion:(void(^)(EMChatroom *aChatroom, EMError *aError))aCompletionBlock;
```
13、直播聊天室解除全体禁言

```
/*!
 *  解除全员禁言，需要Owner / Admin权限
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aChatroomId      聊天室ID
 *  @param pError           错误信息
 *
 *  @result    聊天室实例
 */
- (EMChatroom *)unmuteAllMembersFromChatroom:(NSString *)aChatroomId
                  error:(EMError **)pError;
```
- 直播聊天室全体禁言与观众禁言列表没有直接关系，互不影响

14、离开聊天室并设置当前直播聊天室为“Offline”未直播状态，结束直播

```
/*
 *  用户离开直播聊天室
 *
 *  @param aRoomId          直播聊天室ID
 *  @param aChatroomId      聊天室ID
 *  @param aIsCount         是否计数
 *  @param aCompletion      完成的回调block
 */
- (void)leaveLiveRoomWithRoomId:(NSString*)aRoomId
                     chatroomId:(NSString*)aChatroomId
                        isCount:(BOOL)aIsCount
                        completion:(void (^)(BOOL success))aCompletion;
                        
- 更新直播聊天室状态为Offline
/*
*  更新直播间状态为offline
*
*  @param aRoom            直播间
*  @param aCompletion      完成的回调block
*/
- (void)modifyLiveroomStatusWithOffline:(EaseLiveRoom *)room
                             completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```

### 观看直播
**具体代码参考demo EaseLiveViewController，EaseLiveTVListViewController**

1、获取当前正直播的直播聊天室列表

```
/*
 *  获取正在直播聊天室列表
 *
 *  @param aCursor          游标
 *  @param aLimit           预期获取的记录数
 *  @param aCompletion      完成的回调block
 */
- (void)fetchLiveRoomsOngoingWithCursor:(NSString*)aCursor
                                  limit:(NSInteger)aLimit
                                  completion:(void (^)(EMCursorResult *result, BOOL success))aCompletion;
```
- 进入某个直播间加入聊天室并且设置消息监听接收消息通知，观看直播

## 新特性：自定义消息体 ##

- 本demo所实现的‘礼物’，‘弹幕’，‘点赞’等功能均通过“自定义消息体”构建传输消息

**具体功能演示代码请参见 EaseCustomMessageHelper**

1、实现自定义消息帮助类接口协议再创建该类实例

```
- 实现该接口并重写如下方法
@protocol EaseCustomMessageHelperDelegate <NSObject>

@optional

//观众点赞消息
- (void)didReceivePraiseMessage:(EMMessage *)message;
//弹幕消息
- (void)didSelectedBarrageSwitch:(EMMessage*)msg;
//观众刷礼物
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count;//观众送礼物

@end

- 创建实例
- (instancetype)initWithCustomMsgImp:(id<EaseCustomMessageHelperDelegate>)customMsgImp chatId:(NSString*)chatId;
```
2、发送包含自定义消息体的消息

```
/*
 发送自定义消息 （礼物，点赞，弹幕）
 @param text                 消息内容
 @param num                  消息内容数量
 @param messageType          聊天类型
 @param customMsgType        自定义消息类型
 @param aCompletionBlock     发送完成回调block
*/

- (void)sendCustomMessage:(NSString*)text
                      num:(NSInteger)num
                       to:(NSString*)toUser
              messageType:(EMChatType)messageType
            customMsgType:(customMessageType)customMsgType
               completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;

/*
 发送自定义消息（礼物，点赞，弹幕）（有扩展参数）
 @param text             消息内容
 @param num              消息内容数量
 @param messageType      聊天类型
 @param customMsgType    自定义消息类型
 @param ext              消息扩展
 @param aCompletionBlock 发送完成回调block
*/

- (void)sendCustomMessage:(NSString*)text
                              num:(NSInteger)num
                               to:(NSString*)toUser
                      messageType:(EMChatType)messageType
                    customMsgType:(customMessageType)customMsgType
                            ext:(NSDictionary*)ext
                       completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;
```
3、发送用户自定义消息体事件（其他自定义消息体事件）
```
/*
发送用户自定义消息体事件（其他自定义消息体事件）
@param event                自定义消息体事件
@param customMsgBodyExt     自定义消息体事件参数
@param to                   消息发送对象
@param messageType          聊天类型
@param aCompletionBlock     发送完成回调block
*/
- (void)sendUserCustomMessage:(NSString*)event
                customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                            to:(NSString*)toUser
                        messageType:(EMChatType)messageType
                   completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;
                   
/*
发送用户自定义消息体事件（其他自定义消息体事件）
@param event                自定义消息体事件
@param customMsgBodyExt     自定义消息体事件参数
@param to                   消息发送对象
@param messageType          聊天类型
@param aCompletionBlock     发送完成回调block
*/
- (void)sendUserCustomMessage:(NSString*)event
               customMsgBodyExt:(NSDictionary*)customMsgBodyExt
                           to:(NSString*)toUser
                       messageType:(EMChatType)messageType
                  completion:(void (^)(EMMessage *message, EMError *error))aCompletionBlock;
```

3、解析消息内容

```
//解析消息内容
+ (NSString*)getMsgContent:(EMMessageBody*)messageBody;
```
4、直播聊天室礼物消息展示

```
/*
 @param msg             接收的消息
 @param count           礼物数量
 @param backView        展示在哪个页面
 */
 
- (void)userSendGifts:(EMMessage*)msg count:(NSInteger)count backView:(UIView*)backView;
```
5、弹幕消息展示

```
/*
 @param msg             接收的消息
 @param backView        展示在哪个页面
 */
 
- (void)barrageAction:(EMMessage*)msg backView:(UIView*)backView;
```
6、点赞消息展示

```
/*
 @param backView        展示在哪个页面
 */

- (void)praiseAction:(UIView*)backView;
```

> 环信文档地址：[环信文档](http://docs-im.easemob.com/im/extensions/live/intro)
