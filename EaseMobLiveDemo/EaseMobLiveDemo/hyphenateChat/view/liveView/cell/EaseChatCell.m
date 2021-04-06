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
#import "EaseCustomMessageHelper.h"

@interface EaseChatCell ()

@property (nonatomic, strong)UIView *blankView;

@end

@implementation EaseChatCell

static EaseLiveRoom *room;

- (void)setMesssage:(EMMessage*)message liveroom:(EaseLiveRoom*)liveroom
{
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2].CGColor;
    self.textLabel.layer.cornerRadius = 2;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.attributedText = [EaseChatCell _attributedStringWithMessage:message];
    self.textLabel.numberOfLines = (int)([EaseChatCell heightForMessage:message]/15.f) + 1;
    room = liveroom;
}

+ (CGFloat)heightForMessage:(EMMessage *)message
{
    if (message) {
        CGRect rect = [[EaseChatCell _attributedStringWithMessage:message] boundingRectWithSize:CGSizeMake(KCustomerWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
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
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paraStyle,NSFontAttributeName :[UIFont systemFontOfSize:15.0f]};
    [text addAttributes:attributes range:NSMakeRange(0, text.length)];
    return text;
}

extern NSMutableDictionary *audienceNickname;
extern NSArray<NSString*> *nickNameArray;
extern NSMutableDictionary *anchorInfoDic;

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
                latestMessageTitle = [EaseCustomMessageHelper getMsgContent:messageBody];
            } break;
            default: {
            } break;
        }
    }
    
    int random = (arc4random() % 100);
    NSString *randomNickname = nickNameArray[random];
    if (![audienceNickname objectForKey:lastMessage.from]) {
        [audienceNickname setObject:randomNickname forKey:lastMessage.from];
    } else {
        randomNickname = [audienceNickname objectForKey:lastMessage.from];
    }
    if ([lastMessage.from isEqualToString:room.anchor]) {
        NSMutableDictionary *anchorInfo = [anchorInfoDic objectForKey:room.roomId];
        if (anchorInfo && [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] && ![[anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR] isEqualToString:@""]) {
            randomNickname = [anchorInfo objectForKey:kBROADCASTING_CURRENT_ANCHOR_NICKNAME];
        }
    }
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
            if ([customBody.event isEqualToString:kCustomMsgChatroomPraise] || [customBody.event isEqualToString:kCustomMsgChatroomGift]) {
                [attributedStr addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(104, 255, 149, 1) range:NSMakeRange(range.length + range.location, attributedStr.length - (range.length + range.location))];
            }
        }
    }
    return attributedStr;
}

@end
