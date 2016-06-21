//
//  ViewController.h
//  H264EncodeProject
//
//  Created by yisanmao on 15-3-18.
//  Copyright (c) 2015年 yisanmao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCloudMediaPlayer.h"
#import "CameraServer.h"
#import "UCloudMediaViewController.h"
#import "PlayerManager.h"

//demo中的推流地址仅供demo测试使用，如果更换推流域名地址，请联系客服或者客户经理索取对应的CGIKey
#define CGIKey @"publish3-key"
#define RecordDomain(id) [NSString stringWithFormat:@"rtmp://publish3.cdn.ucloud.com.cn/ucloud/%@", id];
#define PlayDomain(id) [NSString stringWithFormat:@"rtmp://vlive3.rtmp.cdn.ucloud.com.cn/ucloud/%@", id];

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) PlayerManager *playerManager;

- (void)setBtnStateInSel:(NSInteger)num;
- (BOOL)checkPath;

@end
