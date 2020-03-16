//
//  EaseChatCell.m
//
//  Created by EaseMob on 16/6/12.
//  Copyright © 2016年 zmw. All rights reserved.
//

#define KCustomerWidth [[UIScreen mainScreen] bounds].size.width - 32
#import "EaseChatCell.h"
#import "Masonry.h"
#import "EaseEmojiHelper.h"
#import "EaseLiveGiftHelper.h"
#import "EaseDefaultDataHelper.h"

@interface EaseChatCell ()
@property (nonatomic,strong)UIView *blankView;
@end

@implementation EaseChatCell


- (void)setMesssage:(EMMessage*)message
{
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2].CGColor;
    self.textLabel.layer.cornerRadius = 2;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.attributedText = [EaseChatCell _attributedStringWithMessage:message];
    self.textLabel.numberOfLines = (int)([EaseChatCell heightForMessage:message]/15.f) + 1;

}

+ (CGFloat)heightForMessage:(EMMessage *)message
{
    if (message) {
        CGRect rect = [[EaseChatCell _attributedStringWithMessage:message] boundingRectWithSize:CGSizeMake(KCustomerWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        if (rect.size.height < 25.f) {
            return 25.f;
        }
        return rect.size.height;
    }
    return 25.f;
}

+ (NSMutableAttributedString*)_attributedStringWithMessage:(EMMessage*)message
{
    NSMutableAttributedString *text = [EaseChatCell latestMessageTitleForConversationModel:message];
    //NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paraStyle,NSFontAttributeName :[UIFont systemFontOfSize:15.0f]};
    [text addAttributes:attributes range:NSMakeRange(0, text.length)];
    return text;
}

extern NSArray<NSString*> *nickNameArray;
+ (NSMutableAttributedString *)latestMessageTitleForConversationModel:(EMMessage*)lastMessage;
{
    NSString *latestMessageTitle = @"";
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case EMMessageBodyTypeText:{
                NSString *didReceiveText = [EaseEmojiHelper
                                            convertEmoji:((EMTextMessageBody *)messageBody).text];
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
            case EMMessageBodyTypeCustom: {
                EMCustomMessageBody *customBody = (EMCustomMessageBody*)messageBody;
                if ([customBody.event isEqualToString:@"chatroom_barrage"]) {
                    latestMessageTitle = (NSString*)[customBody.ext objectForKey:@"txt"];
                } else if ([customBody.event isEqualToString:@"chatroom_like"]) {
                    latestMessageTitle = [NSString stringWithFormat:@"给主播点了%ld个赞",(long)[(NSString*)[customBody.ext objectForKey:@"num"] integerValue]];
                } else if ([customBody.event isEqualToString:@"chatroom_gift"]) {
                    NSString *giftid = [customBody.ext objectForKey:@"id"];
                    int index = [[giftid substringFromIndex:5] intValue];
                    NSDictionary *dict = EaseLiveGiftHelper.sharedInstance.giftArray[index-1];
                    latestMessageTitle = [NSString stringWithFormat:@" 赠送了 %@x%@",NSLocalizedString((NSString *)[dict allKeys][0],@""),(NSString*)[customBody.ext objectForKey:@"num"]];
                }
            } break;
            default: {
            } break;
        }
    }
    
    int random = (arc4random() % 100);
    NSString *randomNickname = nickNameArray[random];
    if ([lastMessage.from isEqualToString:EMClient.sharedClient.currentUsername]) {
        randomNickname = EaseDefaultDataHelper.shared.defaultNickname;
    }
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    if (lastMessage.ext) {
        if ([lastMessage.ext objectForKey:@"em_leave"] || [lastMessage.ext objectForKey:@"em_join"]) {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@",randomNickname,latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.6]} range:NSMakeRange(randomNickname.length + 1, latestMessageTitle.length - randomNickname.length - 1)];
        } else {
            latestMessageTitle = [NSString stringWithFormat:@"%@: %@",randomNickname,latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            NSRange range = [[attributedStr string] rangeOfString:[NSString stringWithFormat:@"%@: " ,randomNickname] options:NSCaseInsensitiveSearch];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(255, 199, 0, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
        }
    } else {
        latestMessageTitle = [NSString stringWithFormat:@"%@: %@",randomNickname,latestMessageTitle];
        attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        NSRange range = [[attributedStr string] rangeOfString:[NSString stringWithFormat:@"%@: " ,randomNickname] options:NSCaseInsensitiveSearch];
        [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(255, 199, 0, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
        if (lastMessage.body.type == EMMessageBodyTypeCustom) {
            EMCustomMessageBody *customBody = (EMCustomMessageBody*)lastMessage.body;
            if ([customBody.event isEqualToString:@"chatroom_like"] || [customBody.event isEqualToString:@"chatroom_gift"]) {
                [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(104, 255, 149, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
            }
        }
    }
    return attributedStr;
}

@end
