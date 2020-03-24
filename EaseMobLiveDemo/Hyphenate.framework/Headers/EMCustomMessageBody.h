/*!
 *  \~chinese
 *  @header EMCmdMessageBody.h
 *  @abstract 命令消息体
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMCmdMessageBody.h
 *  @abstract Command message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMMessageBody.h"

/*!
 *  \~chinese
 *  自定义消息体
 *
 *  \~english
 *  Custom message body
 */
@interface EMCustomMessageBody : EMMessageBody

@property (nonatomic, copy) NSString *event;

@property (nonatomic, copy) NSDictionary *ext;

- (instancetype)initWithEvent:(NSString *)aEvent ext:(NSDictionary *)aExt;

@end
