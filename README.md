# 简介 #
本demo演示了通过环信及ucloud sdk实现视频直播及直播室聊天

## 怎么使用本demo ##
- 首先在EaseMobLiveDemo文件夹下执行pod install,集成环信sdk
- 初次进入app时会进入到登录页面，没有账号可以通过注册按钮注册账号。登录成功后进入主页面
- 点击“发起直播”按钮，输入标题后，点击开始直播发起直播
- 其他人点击主页面任意一个主播图片进入播放页面，在这个页面目前可以观看直播、群聊、点赞等

## 功能实现 ##



### 发起直播
**具体演示代码见EaseCreateLiveViewController,EasePublishViewController,EaseHttpManager**

1、创建直播聊天室，拥有主播权限的用户可以创建新的直播聊天室，可以包括封面，题目，描述等信息。创建成功后会返回推流地址和聊天室ID

```
/*
 *  创建直播聊天室
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)createLiveRoomWithRoom:(EaseLiveRoom*)aRoom
                    completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```

2、获取主播关联直播聊天室列表，当用户创建新的直播聊天室或者后台操作，都可以关联之前创建的直播聊天室，用户可以使用之前创建的直播聊天室，继续直播或者创建新的直播场次

```
/*
 *  获取一个主播关联的直播聊天室列表
 *
 *  @param aUsername        直播环信ID
 *  @param aPage            获取第几页
 *  @param aPageSize        获取多少条
 *  @param aCompletion      完成的回调block
 */
- (void)getLiveRoomListWithUsername:(NSString*)aUsername
                               page:(NSInteger)aPage
                           pagesize:(NSInteger)aPageSize
                         completion:(void (^)(NSArray *roomList, BOOL success))aCompletion
```

3、创建新的直播场次，当一个直播结束后，用户可以创建一个新的直播场次，可以在原有直播聊天室开始新的直播

```
/*
 *  创建新的直播场次
 *
 *  @param aRoom            直播聊天室
 *  @param aCompletion      完成的回调block
 */
- (void)createLiveSessionWithRoom:(EaseLiveRoom*)aRoom
                       completion:(void (^)(EaseLiveRoom *room, BOOL success))aCompletion;
```

4、指定直播流id，开启预览
	
```	
NSString *path = _room.session.mobilepushstream

NSArray *filters = [self.filterManager filters];
[[CameraServer server] configureCameraWithOutputUrl:path
                                             filter:filters
                                    messageCallBack:^(UCloudCameraCode code, NSInteger arg1, NSInteger arg2, id data){
                                        if (code == UCloudCamera_BUFFER_OVERFLOW) {
                                            //推流带宽
                                        } else if (code == UCloudCamera_SecretkeyNil) {
                                            //密钥为空
                                        } else if (code == UCloudCamera_PreviewOK) {
                                            //预览视图准备好  
                                        } else if (code == UCloudCamera_PublishOk) {
                                            //底层推流配置完毕                                            
                                        } else if (code == UCloudCamera_StartPublish) {
                                            //开始直播
                                        } else if (code == UCloudCamera_Permission) {
                                            //相机授权
                                        } else if (code == UCloudCamera_Micphone) {
                                            //麦克风授权
                                        }
                                    } deviceBlock:^(AVCaptureDevice *dev) {
                                        //相机回掉(定制相机参数)
                                    } cameraData:^CMSampleBufferRef(CMSampleBufferRef buffer) {
                                        //若果不需要裸流，不建议在这里执行操作，讲增加额外的功耗
                                        return nil;
                                    }];
```

5、加入聊天室

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
