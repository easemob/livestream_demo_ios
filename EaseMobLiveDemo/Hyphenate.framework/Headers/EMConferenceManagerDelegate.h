/*!
 *  \~chinese
 *  @header EMConferenceManagerDelegate.h
 *  @abstract 此协议定义了多人实时语音/视频相关的回调
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMConferenceManagerDelegate.h
 *  @abstract This protocol defines a multiplayer real-time voice / video related callback
 *  @author Hyphenate
 *  @version 3.00
 */

#ifndef EMConferenceManagerDelegate_h
#define EMConferenceManagerDelegate_h

#import <Foundation/Foundation.h>

#import "EMCommonDefs.h"
#import "EMCallEnum.h"
#import "EMCallConference.h"
#import "EMCallStream.h"
#import "EMConferenceAttribute.h"

@class EMError;

/*!
 *  \~chinese
 *  多人实时语音/视频相关的回调
 *
 *  \~english
 *  Callbacks of multiplayer real time voice/video
 */

@protocol EMConferenceManagerDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  有人加入会议
 *
 *  @param aConference       会议实例
 *  @param aMember           加入的用户
 *
 *  \~english
 *  Someone joined the conference
 *
 *  @param aConference       EMConference instance
 *  @param aMember           The joined user
 */
- (void)memberDidJoin:(EMCallConference *)aConference
               member:(EMCallMember *)aMember;

/*!
 *  \~chinese
 *  有人离开会议
 *
 *  @param aConference       会议实例
 *  @param aMember           离开的用户
 *
 *  \~english
 *  Someone leaved the conference
 *
 *  @param aConference       EMConference instance
 *  @param aMember           The leaved user
 */
- (void)memberDidLeave:(EMCallConference *)aConference
                member:(EMCallMember *)aMember;

/*!
 *  \~chinese
 *  自己的角色发生变化
 *
 *  @param aConference       会议实例
 *
 *  \~english
 *  The role has changed
 *
 *  @param aConference       EMConference instance
 */
- (void)roleDidChanged:(EMCallConference *)aConference;

/*!
 *  \~chinese
 *  有新的数据流上传
 *
 *  @param aConference       会议实例
 *  @param aStream           数据流实例
 *
 *  \~english
 *  New data streams pulished
 *
 *  @param aConference       EMConference instance
 *  @param aStream           EMCallStream instance
 */
- (void)streamDidUpdate:(EMCallConference *)aConference
              addStream:(EMCallStream *)aStream;

/*!
 *  \~chinese
 *  有数据流移除
 *
 *  @param aConference       会议实例
 *  @param aStream           数据流实例
 *
 *  \~english
 *  Stream removed
 *
 *  @param aConference       EMConference instance
 *  @param aStream           EMCallStream instance
 */
- (void)streamDidUpdate:(EMCallConference *)aConference
           removeStream:(EMCallStream *)aStream;

/*!
 *  \~chinese
 *  数据流有更新（是否静音，视频是否可用）
 *
 *  @param aConference       会议实例
 *  @param aStream           数据流实例
 *
 *  \~english
 *  Stream is updated (whether it is mute, video is available)
 *
 *  @param aConference       EMConference instance
 *  @param aStream           EMCallStream instance
 */
- (void)streamDidUpdate:(EMCallConference *)aConference
                 stream:(EMCallStream *)aStream;

/*!
 *  \~chinese
 *  会议已经结束
 *
 *  @param aConference       会议实例
 *  @param aReason           结束原因
 *  @param aError            错误信息
 *
 *  \~english
 *  The conference is over
 *
 *  @param aConference       EMConference instance
 *  @param aReason           The end reason
 *  @param aError            The error
 */
- (void)conferenceDidEnd:(EMCallConference *)aConference
                  reason:(EMCallEndReason)aReason
                   error:(EMError *)aError;

/*!
 *  \~chinese
 *  数据流已经开始传输数据
 *
 *  @param aConference       会议实例
 *  @param aStreamId         数据流ID
 *
 *  \~english
 *  The stream has already begun to transfer data
 *
 *  @param aConference       EMConference instance
 *  @param aStreamId         Stream ID
 */
- (void)streamStartTransmitting:(EMCallConference *)aConference
                       streamId:(NSString *)aStreamId;

/*!
 *  \~chinese
 *  用户A和用户B正在通话中，用户A的网络状态出现不稳定，用户A会收到该回调
 *
 *  @param aSession  会话实例
 *  @param aStatus   当前状态
 *
 *  \~english
 *  User A and B is on the call, A network status is not stable, A will receive the callback
 *
 *  @param aSession  Session instance
 *  @param aStatus   Current status
 */
- (void)conferenceNetworkDidChange:(EMCallConference *)aConference
                            status:(EMCallNetworkStatus)aStatus;


/*!
 *  \~chinese
 *  用户A用户B在同一个会议中，用户A开始说话时，用户B会收到该回调
 *
 *  @param aSession     会话实例
 *  @param aStreamIds   数据流ID列表
 *
 *  \~english
 *  User A and B is on the call, when A starts speaking, B will receive the callback
 *
 *  @param aSession     Session instance
 *  @param aStreamIds   The list of stream id
 */
- (void)conferenceSpeakerDidChange:(EMCallConference *)aConference
                 speakingStreamIds:(NSArray *)aStreamIds;



- (void)conferenceAttributeUpdated:(EMCallConference *)aConference
                        attributes:(NSArray <EMConferenceAttribute *>*)attrs;


#pragma mark - EM_DEPRECATED_IOS 3.4.3

/*!
 *  \~chinese
 *  有人加入会议
 *
 *  @param aConference       会议实例
 *  @param aUserName         加入的用户
 *
 *  \~english
 *  Someone joined the conference
 *
 *  @param aConference       EMConference instance
 *  @param aUserName         The joined user
 */
- (void)userDidJoin:(EMCallConference *)aConference
               user:(NSString *)aUserName EM_DEPRECATED_IOS(3_1_0, 3_4_3, "Use -[EMConferenceManagerDelegate memberDidJoin:member:]");

/*!
 *  \~chinese
 *  有人离开会议
 *
 *  @param aConference       会议实例
 *  @param aMember           离开的用户
 *
 *  \~english
 *  Someone leaved the conference
 *
 *  @param aConference       EMConference instance
 *  @param aMember           The leaved user
 */
- (void)userDidLeave:(EMCallConference *)aConference
                user:(NSString *)aUserName EM_DEPRECATED_IOS(3_1_0, 3_4_3, "Use -[EMConferenceManagerDelegate memberDidLeave:member:]");

/*!
 *  \~chinese
 *  被邀请加入会议
 *
 *  @param aConfId       会议ID (EMCallConference.confId)
 *  @param aPassword     会议密码
 *  @param aExt          扩展信息
 *
 *  \~english
 *  Invited to join the conference
 *
 *  @param aConfId       Conference ID (EMCallConference.confId)
 *  @param aPassword     The password of the conference
 *  @param aExt          Extended Information
 */
- (void)userDidRecvInvite:(NSString *)aConfId
                 password:(NSString *)aPassword
                      ext:(NSString *)aExt EM_DEPRECATED_IOS(3_1_0, 3_4_3, "Use -DELETE");


@end


#endif /* EMConferenceManagerDelegate_h */
