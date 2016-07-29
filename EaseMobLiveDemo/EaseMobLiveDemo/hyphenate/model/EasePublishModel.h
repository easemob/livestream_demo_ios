//
//  EasePublishModel.h
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EasePublishModel : NSObject

- (instancetype)initWithName:(NSString*)name
                      number:(NSString*)number
               headImageName:(NSString*)headImageName
                    streamId:(NSString*)streamId
                  chatroomId:(NSString*)chatroomId;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *headImageName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *chatroomId;

@end
