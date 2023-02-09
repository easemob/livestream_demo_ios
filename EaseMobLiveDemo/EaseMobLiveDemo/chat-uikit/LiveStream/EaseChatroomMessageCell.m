//
//  ELDChatMessageCell.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "EaseChatroomMessageCell.h"
#import "EaseCustomMessageHelper.h"
#import "EaseHeaders.h"
#import "EaseKitDefine.h"


#define kIconImageViewHeight 28.0
#define kContentLabelMaxWidth 244.0

//#define kContentLabelMaxWidth EaseKitScreenWidth -kIconImageViewHeight -EaseKitPadding *3

#define kNameLabelHeight 14.0
#define kBgViewVPadding 4.0
#define kBgViewHPadding 8.0

typedef NS_ENUM(NSInteger, MSGCellNameLineStyle) {
    MSGCellNameLineStyleName,
    MSGCellNameLineStyleRole,
    MSGCellNameLineStyleMute
};

@interface EaseChatroomMessageCell ()

@property (nonatomic, strong) UIImageView *roleImageView;
@property (nonatomic, strong) UIImageView *muteImageView;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) EMUserInfo *userInfo;
@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic, strong) NSString *msgFrom;
@property (nonatomic, assign) MSGCellNameLineStyle nameLineStyle;

@end

@implementation EaseChatroomMessageCell
- (void)prepare {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    self.nameLineStyle = MSGCellNameLineStyleName;
        
    if (self.customOption.displaySenderAvatar) {
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.roleImageView];
        [self.contentView addSubview:self.muteImageView];
        [self.contentView addSubview:self.messageLabel];
        
        self.avatarImageView.layer.cornerRadius = kIconImageViewHeight * 0.5;
    }else {
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.roleImageView];
        [self.contentView addSubview:self.muteImageView];
        [self.contentView addSubview:self.messageLabel];
        
        self.nameLabel.font = EaseKitNFont(12.0f);
        self.nameLabel.textColor = EaseKitTextLabelGrayColor;
    }

}

- (void)placeSubViews {
    if (self.customOption.displaySenderAvatar) {
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kBgViewVPadding);
            make.left.equalTo(self.contentView).offset(12.0);
            make.size.equalTo(@(kIconImageViewHeight));
        }];
            
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_top).offset(-kBgViewVPadding);
            make.left.equalTo(self.avatarImageView.mas_right).offset(kBgViewHPadding);
            make.right.equalTo(self.messageLabel.mas_right).offset(kBgViewHPadding);
            make.bottom.equalTo(self.messageLabel.mas_bottom).offset(kBgViewVPadding);
        }];
        
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView);
            make.height.equalTo(@(kNameLabelHeight));
            make.left.equalTo(self.avatarImageView.mas_right).offset(16.0);
        }];
        
        
        [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0f);
        }];
        
        [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.roleImageView.mas_right).offset(10.0);
        }];
        
        
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(kBgViewVPadding);
            make.left.equalTo(self.nameLabel);
            make.width.lessThanOrEqualTo(@(kContentLabelMaxWidth));
        }];
    }else {
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_top).offset(-kBgViewVPadding);
            make.left.equalTo(self.contentView).offset(kBgViewHPadding);
            make.right.equalTo(self.muteImageView.mas_right).offset(kBgViewHPadding);
            make.bottom.equalTo(self.messageLabel.mas_bottom).offset(kBgViewVPadding);
        }];

        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kBgViewVPadding);
            make.left.equalTo(self).offset(10.0 + kBgViewHPadding);
            make.height.equalTo(@(kNameLabelHeight));
        }];
        
        [self.roleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0f);
        }];
        
        [self.muteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.roleImageView.mas_right).offset(10.0);
        }];

        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(kBgViewVPadding);
            make.left.equalTo(self.nameLabel);
            make.width.lessThanOrEqualTo(@(kContentLabelMaxWidth));
        }];
    }
   
    
    if(self.customOption.avatarStyle == RoundedCorner) {
        self.avatarImageView.layer.cornerRadius = self.customOption.avatarCornerRadius;
    }else if(self.customOption.avatarStyle == Rectangular) {
        self.avatarImageView.layer.cornerRadius = 0;
    }else {
        // default avatarStyle Circular
    }
    
    
    self.nameLabel.hidden = !self.customOption.displaySenderNickname;

    if (self.customOption.cellBgColor) {
        self.bgView.backgroundColor = self.customOption.cellBgColor;
    }
    
    if (self.customOption.messageLabelColor) {
        self.messageLabel.textColor = self.customOption.messageLabelColor;
    }
    
    if (self.customOption.messageLabelSize) {
        self.messageLabel.font = EaseKitNFont(self.customOption.messageLabelSize);
    }
    
    if (self.customOption.nameLabelColor) {
        self.nameLabel.textColor = self.customOption.nameLabelColor;
    }
    
    if (self.customOption.nameLabelFontSize) {
        self.messageLabel.font  = EaseKitNFont(self.customOption.nameLabelFontSize);
    }
}

#pragma mark
- (void)setMesssage:(EMChatMessage*)message chatroom:(EMChatroom*)chatroom
{
    
    self.chatroom = chatroom;
    NSString *chatroomOwner = self.chatroom.owner;

    self.msgFrom = message.from;
    
    [self fetchUserInfoWithUserId:self.msgFrom completion:^(NSDictionary * _Nonnull userInfoDic) {
        self.userInfo = [userInfoDic objectForKey:message.from];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
            self.nameLabel.text = self.userInfo.nickName ?:self.userInfo.userId;
            
            CGFloat nameLineWidth = [self nameLabelWidth];
            CGFloat messageLineWidth = [EaseChatroomMessageCell messageLabelSizeWithMessage:message].width;
            
            
            if ([message.from isEqualToString:chatroomOwner]) {
                [self.roleImageView setImage:[UIImage imageNamed:NSLocalizedString(@"live.streamer.imageName",nil)]];
                nameLineWidth += 44.0;
                self.nameLineStyle = MSGCellNameLineStyleRole;
            }else if ([self.chatroom.adminList containsObject:message.from]){
                [self.roleImageView setImage:[UIImage imageNamed:NSLocalizedString(@"live.moderator.imageName",nil)]];
                nameLineWidth += 44.0;
                self.nameLineStyle = MSGCellNameLineStyleRole;
            }else {
                [self.roleImageView setImage:[UIImage imageNamed:@""]];
            }
            
            if ([self.chatroom.muteList containsObject:self.userInfo.userId]) {
                self.muteImageView.hidden = NO;
                nameLineWidth += 16.0;
                self.nameLineStyle = MSGCellNameLineStyleMute;
            }else {
                self.muteImageView.hidden = YES;
            }
            
            if (nameLineWidth >= kContentLabelMaxWidth) {
                nameLineWidth = kContentLabelMaxWidth;
                
                CGFloat nameWidth = nameLineWidth;
                if (self.nameLineStyle == MSGCellNameLineStyleMute) {
                    nameWidth = nameWidth -44.0 -16.0;
                }else if (self.nameLineStyle == MSGCellNameLineStyleRole){
                    nameWidth = nameWidth -44.0;
                }else {
                   // do nothing
                }
                
                [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(nameWidth));
                }];
                
            }
            
            if (nameLineWidth > messageLineWidth) {
                [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                    if (self.nameLineStyle == MSGCellNameLineStyleMute) {
                        make.right.equalTo(self.muteImageView.mas_right).offset(kBgViewHPadding);
                    }else if (self.nameLineStyle == MSGCellNameLineStyleRole){
                        make.right.equalTo(self.roleImageView.mas_right).offset(kBgViewHPadding);
                    }else {
                        make.right.equalTo(self.nameLabel.mas_right).offset(kBgViewHPadding);
                    }
                    
                }];
            }else {
                [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.messageLabel.mas_right).offset(kBgViewHPadding);
                }];
            }
            
            self.messageLabel.attributedText = [EaseChatroomMessageCell _attributedStringWithMessage:message];
        });
    }];
}


- (CGFloat)nameLabelWidth {
    CGFloat nameWidth = [self.nameLabel.text sizeWithAttributes:@{
        NSFontAttributeName:self.nameLabel.font,
        NSParagraphStyleAttributeName:[EaseChatroomMessageCell contentLabelParaStyle]
    }].width;
    
    return nameWidth;
}


+ (CGFloat)heightForMessage:(EMChatMessage *)message
{
    CGFloat height = 0;

    CGSize messageSize = [self messageLabelSizeWithMessage:message];
    height = messageSize.height;
    height += kBgViewVPadding * 3 + kNameLabelHeight;

    return height;
}

+ (CGSize)messageLabelSizeWithMessage:(EMChatMessage *)message {
    CGSize textBlockMinSize = {kContentLabelMaxWidth, CGFLOAT_MAX};
    CGSize retSize;
    NSString *text = [EaseChatroomMessageCell contentWithMessage:message];
    retSize = [text boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{
                                           NSFontAttributeName:[EaseChatroomMessageCell contentFont],
                                           NSParagraphStyleAttributeName:[EaseChatroomMessageCell contentLabelParaStyle]
                                           }
                                 context:nil].size;
    return retSize;
}

+ (NSMutableAttributedString*)_attributedStringWithMessage:(EMChatMessage*)message
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[EaseChatroomMessageCell contentWithMessage:message]];
    
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: [EaseChatroomMessageCell contentLabelParaStyle],NSFontAttributeName :[EaseChatroomMessageCell contentFont]};
    [text addAttributes:attributes range:NSMakeRange(0, text.length)];
    return text;
}


+ (NSString *)contentWithMessage:(EMChatMessage *)message {
    NSString *latestMessageTitle = @"";
    if (message) {
        EMMessageBody *messageBody = message.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[picture]";
            } break;
            case EMMessageBodyTypeText:{
//                NSString *didReceiveText = [EaseEmojiHelper
//                                            convertEmoji:((EMTextMessageBody *)messageBody).text];
//                latestMessageTitle = didReceiveText;
                latestMessageTitle = ((EMTextMessageBody *)messageBody).text;
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"[voice]";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"[Location]";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = @"[video]";
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = @"[document]";
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}


+ (NSMutableParagraphStyle *)contentLabelParaStyle {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.lineSpacing = [EaseChatroomMessageCell lineSpacing];
    return paraStyle;
}

+ (CGFloat)lineSpacing{
    return 4.0f;
}

+ (UIFont *)contentFont {
    return EaseKitBFont(14.0);
}


#pragma mark getter and setter
- (UIImageView *)roleImageView {
    if (_roleImageView == nil) {
        _roleImageView = [[UIImageView alloc] init];
        _roleImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _roleImageView;
}

- (UILabel *)messageLabel {
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [EaseChatroomMessageCell contentFont];
        _messageLabel.textColor = UIColor.whiteColor;
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _messageLabel.preferredMaxLayoutWidth = kContentLabelMaxWidth;
    }
    return _messageLabel;
}

- (UIImageView *)muteImageView {
    if (_muteImageView == nil) {
        _muteImageView = [[UIImageView alloc] init];
        _muteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_muteImageView setImage:[UIImage imageNamed:@"member_mute_icon"]];
    }
    return _muteImageView;
}


@end

#undef kIconImageViewHeight
#undef kContentLabelMaxWidth
#undef kNameLabelHeight
#undef kBgViewVPadding
#undef kBgViewHPadding

