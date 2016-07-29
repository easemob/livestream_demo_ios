//
//  EasePublishModel.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EasePublishModel.h"

@implementation EasePublishModel

- (instancetype)initWithName:(NSString*)name
                      number:(NSString*)number
               headImageName:(NSString*)headImageName
                    streamId:(NSString*)streamId
                  chatroomId:(NSString*)chatroomId
{
    self = [super init];
    if (self) {
        self.name = name;
        self.number = number;
        self.headImageName = headImageName;
        self.streamId = streamId;
        self.chatroomId = chatroomId;
    }
    return self;
}

@end
