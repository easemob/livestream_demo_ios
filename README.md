## 简介 ##
本demo演示了通过环信及ucloud sdk实现视频直播及直播室聊天

## 怎么使用本demo ##
- 首先在EaseMobLiveDemo文件夹下执行pod install,集成环信sdk
- 初次进入app时会进入到登录页面，没有账号可以通过注册按钮注册账号。登录成功后进入主页面
- 点击“发起直播”按钮，输入标题后，点击开始直播发起直播
- 其他人点击主页面任意一个主播图片进入播放页面，**在这个页面目前可以观看直播、群聊、发送礼物、发送弹幕等**

## 功能实现 ##



### 发起直播
**具体代码见EasePublishViewController类**

1、指定直播流id，开启预览
	
	#define RecordDomain(id) [NSString stringWithFormat:@"rtmp://publish3.cdn.ucloud.com.cn/ucloud/%@", id];
	
	
 	NSString *path = RecordDomain(self.streamId);

    NSArray *filters = [self.filterManager filters];
    [[CameraServer server] configureCameraWithOutputUrl:path
                                                 filter:filters
                                        messageCallBack:^(UCloudCameraCode code, NSInteger arg1, NSInteger arg2, id data){
                                            if (code == UCloudCamera_BUFFER_OVERFLOW)
                                            {
                                            //推流带宽
                                            }
                                            else if (code == UCloudCamera_SecretkeyNil)
                                            {
                                            //密钥为空
                                            }
                                            else if (code == UCloudCamera_PreviewOK)
                                            {
                                            //预览视图准备好  
                                            }
                                            else if (code == UCloudCamera_PublishOk)
                                            {
                                            //底层推流配置完毕                                            
                                            }
                                            else if (code == UCloudCamera_StartPublish)
                                            {
                                            //开始直播
                                            }
                                            else if (code == UCloudCamera_Permission)
                                            {
                                            //相机授权
                                            }
                                            else if (code == UCloudCamera_Micphone)
                                            {
                                            //麦克风授权
                                            }
                                            
                                        }
                                            deviceBlock:^(AVCaptureDevice *dev) {
                                            //相机回掉(定制相机参数)
                                            }cameraData:^CMSampleBufferRef(CMSampleBufferRef buffer) {
                                            //若果不需要裸流，不建议在这里执行操作，讲增加额外的功耗
                                                return nil;
                                            }];


3、加入聊天室

    EMError *error = nil;
    [[EMClient sharedClient].roomManager joinChatroom:_chatroomId error:&error];
    if (!error) {
        加入聊天室成功
    }
4、设置消息监听

	 [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
	 
	 
	- (void)didReceiveMessages:(NSArray *)aMessages
	{
	//收到普通消息
	}

	- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
	{
	//收到cmd消息
	}


4、发送消息

    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"发送内容"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroomId from:from to:aChatroomId body:body ext:nil];
    message.chatType = EMChatTypeChatRoom;
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
    	if (!error) {
		//消息发送成功
        }
    }];


### 观看直播
**具体代码参考demo EaseLiveViewController**

通过指定流id观看直播
	
	#define PlayDomain(id) [NSString stringWithFormat:@"rtmp://vlive3.rtmp.cdn.ucloud.com.cn/ucloud/%@", id];
	
    NSString *path = PlayDomain(path);
    
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

加入聊天室及接发消息通发起直播



###发送弹幕
设置扩展字段实现，UI上根据相应字段做弹幕的显示

    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:"弹幕"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroomId from:from to:aChatroomId body:body ext:@{@"is_barrage_msg":@(1)}];
    message.chatType = EMChatTypeChatRoom;
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
    	if (!error) {
    	//发送成功
        }
    }];
    


###发送礼物

通过发送透传消息实现礼物的发送，UI上根据礼物类型做相应的显示

    EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"cmd_gift"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aChatroomId  from:from to:toUser body:aChatroomId  ext:nil];
    message.chatType = EMChatTypeChatRoom;
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
    	if (!error) {
    	//发送成功
        }
    }];

这里只是做一个简单演示，可通过设置扩展消息设置礼物的具体类型及数量等


> 环信及ucloud文档地址：[http://docs.easemob.com/im/300iosclientintegration/40emmsg](http://docs.easemob.com/im/300iosclientintegration/40emmsg)，
> [https://docs.ucloud.cn/upd-docs/ulive/index.html](https://docs.ucloud.cn/upd-docs/ulive/index.html)
