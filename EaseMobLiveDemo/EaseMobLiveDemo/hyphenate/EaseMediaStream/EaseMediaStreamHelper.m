//
//  EaseMediaStreamHelper.m
//  EaseMobLiveDemo
//
//  Created by 娜塔莎 on 2020/4/26.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseMediaStreamHelper.h"
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>
#import "PLPermissionRequestor.h"

@implementation EaseMediaStreamHelper
{
    NSURL *_streamCloudURL;
    NSURL *_streamURL;
    
    PLVideoCaptureConfiguration *videoCaptureConfiguration;
    PLAudioCaptureConfiguration *audioCaptureConfiguration;
    PLVideoStreamingConfiguration *videoStreamingConfiguration;
    PLAudioStreamingConfiguration *audioStreamingConfiguration;
}

- (void)_getStreamCloudURL:(NSString *)chatRoomId {
    NSString *streamServer = @"https://api-demo.qnsdk.com/v1/live/stream/";
    
    NSString *streamURLString = [streamServer stringByAppendingPathComponent:chatRoomId];
    
    _streamCloudURL = [NSURL URLWithString:streamURLString];
}

@end
