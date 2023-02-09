//
//  EMError+localizedString.m
//  EaseMobLiveDemo
//
//  Created by li xiaoming on 2023/1/6.
//  Copyright © 2023 zmw. All rights reserved.
//

#import "EMError+localizedString.h"

@implementation EMError (localizedString)
- (NSString *)localizedString
{
    NSString* result = self.errorDescription;
    switch (self.code) {
        case EMErrorChatroomMembersFull:
            if ([self.errorDescription containsString:@"blacklist"]) {
                result = NSLocalizedString(@"live.joinFailed.beenBanned", nil);
            }
            break;
        case EMErrorNetworkUnavailable:
            break;
        default:
            break;
    }
    return result;
}
@end
