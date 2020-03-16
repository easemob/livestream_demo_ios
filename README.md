# 简介 #
本demo演示了通过环信sdk实现的直播聊天室

## 怎么使用本demo ##
- 首先在EaseMobLiveDemo文件夹下执行pod install,集成环信sdk
- 初次进入app时会自动注册一个UUID游客账号，默认密码000000，注册成功自动登录，自动登录完成跳转到主页面
- 点击主页底部“我要直播”蓝色按钮，选择一个可“立即开播”的直播间，点击进入该直播间基本信息页，键入封面图以及本次直播主题和描述后，点击“开始直播”开启一场直播
- 游客点击主页面任意一个直播间即可进入该直播间观看直播，在直播间目前可以发群聊消息、给主播点赞，给主播刷礼物，发弹幕等，当前直播间聊天室观众均可收到消息动画

## 功能实现 ##



### 我要直播
**具体演示代码见EaseCreateLiveViewController,EasePublishViewController,EaseHttpManager**

1、设置当前将要直播的直播间为“ongoing”正直播状态

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

2、自定义直播聊天室封面信息，包括封面，主题，描述信息，并修改直播聊天室详情为自定义详情信息，该场直播结束后，任何用户也可在原有直播聊天室开始一场新的直播

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

3、加入聊天室

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
                    completion:(void (^)(BOOL success))aCompletion
```

6、设置消息监听

	 [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
	 
	 
	- (void)messagesDidReceive:(NSArray *)aMessages
	{
	//收到普通消息
	}

	- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
	{
	//收到cmd消息
	}


7、发送消息

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
8、离开聊天室

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
```

### 观看直播
**具体代码参考demo EaseLiveViewController，EaseLiveTVListViewController**

1、获取直播列表，可以获取当前正在直播的列表

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

2、通过指定流id观看直播
	
```	
NSString *path = PlayDomain(room.session.mobilepullstream);
    
self.view = self.viewContorller.view;
__weak PlayerManager *weakSelf = self;
self.mediaPlayer = [UCloudMediaPlayer ucloudMediaPlayer];
[self.mediaPlayer showMediaPlayer:path frame:CGRectNull view:self.view completion:^(NSInteger defaultNum, NSArray *data) {
	if (bloc) {
		bloc();
	}
	if (self.mediaPlayer) {
		[weakSelf buildMediaControl:defaultNum data:data];
	}
}];
```
加入聊天室及接发消息通发起直播

这里只是做一个简单演示，可通过设置扩展消息设置礼物的具体类型及数量等


> 环信及ucloud文档地址：[环信文档](http://docs.easemob.com/im/300iosclientintegration/40emmsg)，
> [ucloud文档](https://docs.ucloud.cn/video/ulive/ulive_ios_sdk)
