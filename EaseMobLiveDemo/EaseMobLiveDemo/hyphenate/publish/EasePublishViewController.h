//
//  EasePublishViewController.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/3.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CGIKey @"publish3-key"
#define RecordDomain(id) [NSString stringWithFormat:@"rtmp://publish3.cdn.ucloud.com.cn/ucloud/%@", id];
#define PlayDomain(id) [NSString stringWithFormat:@"rtmp://vlive3.rtmp.cdn.ucloud.com.cn/ucloud/%@", id];

@class EaseLiveRoom;
@interface EasePublishViewController : UIViewController

- (instancetype)initWithLiveRoom:(EaseLiveRoom*)room;

@end
