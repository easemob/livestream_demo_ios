//
//  EaseChatCell.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/12.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseChatCell.h"

@interface EaseChatCell ()

@end

@implementation EaseChatCell


- (void)setMesssage:(EMMessage*)message
{
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.shadowColor = [UIColor blackColor];
    self.textLabel.shadowOffset = CGSizeMake(1, 1);
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.attributedText = [EaseChatCell _attributedStringWithMessage:message];
    
    self.textLabel.numberOfLines = (int)([EaseChatCell heightForMessage:message]/15.f) + 1;
}

+ (CGFloat)heightForMessage:(EMMessage *)message
{
    if (message) {
        CGRect rect = [[EaseChatCell _attributedStringWithMessage:message] boundingRectWithSize:CGSizeMake(KScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (rect.size.height < 25.f) {
            return 25.f;
        }
        return rect.size.height;
    }
    return 25.f;
}

+ (NSMutableAttributedString*)_attributedStringWithMessage:(EMMessage*)message
{
    
    NSString *text = [EaseChatCell latestMessageTitleForConversationModel:message];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paraStyle,NSFontAttributeName :[UIFont systemFontOfSize:15.0f]};
    [string addAttributes:attributes range:NSMakeRange(0, string.length)];
    if ([message.from isEqualToString:[EMClient sharedClient].currentUsername]) {
        NSRange range = [text rangeOfString:[NSString stringWithFormat:@"%@: " ,[EMClient sharedClient].currentUsername] options:NSCaseInsensitiveSearch];
        [string addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(25, 163, 255, 1) range:NSMakeRange(range.length + range.location, text.length - (range.length + range.location))];
    }
    return string;
}

+ (NSString *)latestMessageTitleForConversationModel:(EMMessage*)lastMessage;
{
    NSString *latestMessageTitle = @"";
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"[语音]";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"[位置]";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = @"[视频]";
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = @"[文件]";
            } break;
            default: {
            } break;
        }
    }
    
    if (lastMessage.ext) {
        if ([lastMessage.ext objectForKey:@"em_leave"] || [lastMessage.ext objectForKey:@"em_join"]) {
            latestMessageTitle = [NSString stringWithFormat:@" %@ %@",lastMessage.from,latestMessageTitle];
        } else {
            latestMessageTitle = [NSString stringWithFormat:@" %@: %@",lastMessage.from,latestMessageTitle];
        }
    } else {
        latestMessageTitle = [NSString stringWithFormat:@" %@: %@",lastMessage.from,latestMessageTitle];
    }
    return latestMessageTitle;
}

@end
