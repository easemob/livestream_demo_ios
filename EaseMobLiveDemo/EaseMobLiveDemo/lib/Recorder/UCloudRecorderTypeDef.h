//
//  UCloudRecorderTypeDef.h
//  UCloudMediaRecorder
//
//  Created by Sidney on 23/08/16.
//  Copyright © 2016年 https://ucloud.cn/. All rights reserved.
//

#ifndef UCloudRecorderTypeDef_h
#define UCloudRecorderTypeDef_h

typedef NS_ENUM(NSInteger, UCloudCameraCode)
{
    UCloudCamera_COMPLETED =0,
    UCloudCamera_FILE_SIZE = 1,
    UCloudCamera_FILE_DURATION = 2,
    UCloudCamera_CUR_POS = 3,
    UCloudCamera_CUR_TIME = 4,
    UCloudCamera_URL_ERROR = 5,
    UCloudCamera_OUT_FAIL = 6,
    /// 推流开始
    UCloudCamera_STARTED = 7,
    UCloudCamera_READ_AUD_ERROR = 8,
    UCloudCamera_READ_VID_ERROR = 9,
    /// 推流错误
    UCloudCamera_OUTPUT_ERROR = 10,
    /// 推流停止
    UCloudCamera_STOPPED = 11,
    UCloudCamera_READ_AUD_EOS = 12,
    UCloudCamera_READ_VID_EOS = 13,
    /// 推流上行带宽不足
    UCloudCamera_BUFFER_OVERFLOW = 14,
    /// SDK 密钥为空
    UCloudCamera_SecretkeyNil = 15,
    /// 推流域名为空
    UCloudCamera_DomainNil = 16,
    /// SDK 鉴权失败
    UCloudCamera_AuthFail = 17,
    /// SDK 鉴权返回IP列表为空
    UCloudCamera_ServerIpError = 18,
    /// 预览视图准备好
    UCloudCamera_PreviewOK = 19,
    /// 底层推流配置完毕
    UCloudCamera_PublishOk = 20,
    UCloudCamera_StartPublish = 21,
    /// SDK dig错误
    UCloudCamera_DigError = 22,
    /// 推流ID已被占用
    UCloudCamera_AlreadyPublish = 23,
    /// 推流url对应的服务器连接失败
    UCloudCamera_CannotConnect = 24,
    /// 服务器连接异常断开
    UCloudCamera_DisConnected = 25,
    /// 摄像头权限
    UCloudCamera_Permission = 998,
    /// 麦克风权限
    UCloudCamera_Micphone = 999,
};

typedef NS_ENUM(NSInteger, UCloudCameraState)
{
    /// 关闭
    UCloudCameraCode_Off,
    /// 打开
    UCloudCameraCode_On,
    /// 自动
    UCloudCameraCode_Auto,
};

/**
 *  @abstract  视频采集方向
 */
typedef NS_ENUM(NSInteger, UCloudVideoOrientation) {
    UCloudVideoOrientationPortrait           = UIDeviceOrientationPortrait,
    UCloudVideoOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    UCloudVideoOrientationLandscapeRight      = UIDeviceOrientationLandscapeRight,
    UCloudVideoOrientationLandscapeLeft     = UIDeviceOrientationLandscapeLeft
};

/*!
 @enum UCloudVideoBitrate
 @abstract 采集的视频流码率，包括视频流码率和音频流码率，音频流码率默认128kbps
 */

typedef NS_ENUM(NSInteger, UCloudVideoBitrate) {
    UCloudVideoBitrateLow       = 400,
    UCloudVideoBitrateNormal    = 600,
    UCloudVideoBitrateMedium    = 800,
    UCloudVideoBitrateHigh      = 1000
};

#pragma mark Notifications

#ifdef __cplusplus
#define UCLOUD_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define UCLOUD_EXTERN extern __attribute__((visibility ("default")))
#endif

/**
 *  推流出错，重新推流
 */
UCLOUD_EXTERN NSString *const UCloudNeedRestart;


#define System_Version [UIDevice currentDevice].systemVersion.floatValue
#define System_Version_String(x) [[UIDevice currentDevice].systemVersion isEqualToString:x]

#endif /* UCloudRecorderTypeDef_h */
