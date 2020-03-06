/*!
 *  \~chinese
 *  @header EMCallConference.h
 *  @abstract 多人会议
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMCallConference.h
 *  @abstract COnference
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EMConferenceRole){
    EMConferenceRoleNone = 0,
    EMConferenceRoleAudience = 1, /*! \~chinese 观众，只能订阅流 \~english Audience, only sub */
    EMConferenceRoleSpeaker = 3, /*! \~chinese 主播，订阅流和发布流 \~english Speaker, pub and sub */
    EMConferenceRoleAdmin = 7, /*! \~chinese 管理员，授权，订阅流，发布流 \~english Admin, authorize, pub and sub */
};

typedef NS_ENUM(NSInteger, EMConferenceType){
    EMConferenceTypeCommunication = 10, /*! \~chinese 普通通信会议，成员最多6人，参会者都是EMConferenceRoleSpeaker \~english Communication，Up to 6 members, member role is EMConferenceRoleSpeaker  */
    EMConferenceTypeLargeCommunication, /*! \~chinese 大型通信会议，成员6-30人, 参会者都是EMConferenceRoleSpeaker \~english Communication, 6-30 members, member role is EMConferenceRoleSpeaker */
    EMConferenceTypeLive, /*! \~chinese 互动视频会议，会议里支持最多6个主播和600个观众 \~english Live，support for up to 6 speakers and 600 audiences. */
};


/*!
 *  \~chinese
 *  多人会议成员对象
 *
 *  \~english
 *  Conference member class
 */
@interface EMCallMember : NSObject

/*!
 *  \~chinese
 *  成员标识符
 *
 *  \~english
 *  Unique member id
 */
@property (nonatomic, strong, readonly) NSString *memberId;


/*!
 *  \~chinese
 *  成员名
 *
 *  \~english
 *  The member name
 */
@property (nonatomic, strong, readonly) NSString *memberName;

/*!
 *  \~chinese
 *  扩展信息
 *
 *  \~english
 *  Extension
 */
@property (nonatomic, strong, readonly) NSString *ext;

@end

/*!
 *  \~chinese
 *  多人会议对象
 *
 *  \~english
 *  Conference class
 */
@interface EMCallConference : NSObject

/*!
 *  \~chinese
 *  会话标识符, 本地生成
 *
 *  \~english
 *  Unique call id, locally generated
 */
@property (nonatomic, strong, readonly) NSString *callId;

/*!
 *  \~chinese
 *  会议标识符,服务器生成
 *
 *  \~english
 *  Unique conference id, server generation
 */
@property (nonatomic, strong, readonly) NSString *confId;

/*!
 *  \~chinese
 *  通话本地的username
 *
 *  \~english
 *  Local username
 */
@property (nonatomic, strong, readonly) NSString *localName;

/*!
 *  \~chinese
 *  会议类型
 *
 *  \~english
 *  The conference type
 */
@property (nonatomic) EMConferenceType type;

/*!
 *  \~chinese
 *  在会议中的角色
 *
 *  \~english
 * Role in the conference
 */
@property (nonatomic) EMConferenceRole role;

/*!
 *  \~chinese
 *  管理员列表
 *
 *  \~english
 *  Administrator's id list
 */
@property (nonatomic, strong) NSArray<NSString *> *adminIds;

/*!
 *  \~chinese
 *  主播列表
 *
 *  \~english
 *  Speaker's id list
 */
@property (nonatomic, strong) NSArray<NSString *> *speakerIds;

/*!
 *  \~chinese
 *  会议标识符,服务器生成
 *
 *  \~english
 *  Unique conference id, server generation
 */
@property (nonatomic) NSInteger memberCount;

/*!
 *  \~chinese
 *  是否启用服务器录制
 *
 *  \~english
 *  Whether server recording is enabled
 */
@property (nonatomic) BOOL willRecord;
@end
