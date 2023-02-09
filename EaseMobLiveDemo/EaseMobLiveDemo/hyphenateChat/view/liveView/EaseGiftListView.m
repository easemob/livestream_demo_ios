//
//  EaseGiftListView.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/6.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseGiftListView.h"
#import "EaseDefaultDataHelper.h"
#import "EaseLiveGiftHelper.h"

#define kButtonDefaultHeight 50.f
#define kDefaultPageSize 10

@interface EaseGiftlistCell : UITableViewCell

@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UIView *userInfo;

@end

@implementation EaseGiftlistCell

- (UIView*)userInfo
{
    if (_userInfo == nil) {
        _userInfo = [[UIView alloc]initWithFrame:CGRectMake(self.width-280, (54-20)/2, 120, 20)];
        _userInfo.backgroundColor = [UIColor clearColor];
        UIImageView *avatar = [[UIImageView alloc]initWithFrame:CGRectMake(self.width-220, 1, 18, 18)];
        avatar.image = [UIImage imageNamed:@"default_anchor_avatar"];
        avatar.layer.cornerRadius = 9;
        [_userInfo addSubview:avatar];
        [_userInfo addSubview:self.userLabel];
        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@18);
            make.top.equalTo(_userInfo.mas_top).offset(1);
            make.left.equalTo(avatar.mas_right).offset(5);
        }];
        UILabel *constMsgLabel = [[UILabel alloc]init];
        constMsgLabel.text = @"send";
        constMsgLabel.font = [UIFont systemFontOfSize:13.f];
        constMsgLabel.backgroundColor = [UIColor clearColor];
        constMsgLabel.textAlignment = NSTextAlignmentCenter;
        constMsgLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        [_userInfo addSubview:constMsgLabel];
        [constMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@30);
            make.height.equalTo(@20);
            make.left.equalTo(_userLabel.mas_right).offset(5);
            make.top.equalTo(_userInfo.mas_top).offset(1);
        }];
    }
    return _userInfo;
}

- (UILabel*)userLabel
{
    if (_userLabel == nil) {
        _userLabel = [[UILabel alloc]init];
        _userLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _userLabel.font = [UIFont systemFontOfSize:13.f];
        _userLabel.backgroundColor = [UIColor clearColor];
        _userLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _userLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView addSubview:self.userInfo];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    /*
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width=60.0f;
    self.textLabel.frame = textLabelFrame;*/
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end

@interface EaseGiftListView() <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *giftView;
@property (nonatomic, strong) UIImageView *giftImg;
@property (nonatomic, strong) UIButton *giftListBtn;
@property (nonatomic, strong) UITableView *giftTableView;

@property (nonatomic, strong) UILabel *exceptionalGift;//打赏

@property (nonatomic, strong) NSMutableArray *giftStatisticsArray;//礼物统计

@end

@implementation EaseGiftListView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.giftView];
        [self.giftView addSubview:self.exceptionalGift];
        [self.giftView addSubview:self.giftListBtn];
        [self.giftView addSubview:self.giftTableView];
        
    }
    return self;
}

#pragma mark - getter

- (UIView*)giftView
{
    if (_giftView == nil) {
         _giftView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 320.f, self.width, 320.f)];
        _giftView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _giftView;
}

- (UILabel*)exceptionalGift
{
    if (_exceptionalGift == nil) {
        _exceptionalGift = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 160, 15, 144, 20)];
        _exceptionalGift.font = [UIFont systemFontOfSize:13.f];
        _exceptionalGift.textColor = [UIColor whiteColor];
        _exceptionalGift.backgroundColor = [UIColor clearColor];
        _exceptionalGift.textAlignment = NSTextAlignmentRight;
        _exceptionalGift.text = [NSString stringWithFormat:@"Total %d copies  rewarded amount %lu",[EaseDefaultDataHelper.shared.giftNumbers intValue],(unsigned long)[EaseDefaultDataHelper.shared.rewardCount count]];
    }
    return _exceptionalGift;
}

- (NSMutableArray*)giftStatisticsArray
{
    if (_giftStatisticsArray == nil) {
        _giftStatisticsArray = [[NSMutableArray alloc]init];
        for (NSString *giftId in [EaseDefaultDataHelper.shared.giftStatisticsCount allKeys]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            [tempArray addObject:giftId];//礼物id
            NSMutableDictionary *tempDic = (NSMutableDictionary*)[EaseDefaultDataHelper.shared.giftStatisticsCount objectForKey:giftId];
            for (NSString *user in [tempDic allKeys]) {
                [tempArray addObject:user];//用户名
                [tempArray addObject:[tempDic objectForKey:user]];//数量
                [_giftStatisticsArray addObject:tempArray];
            }
        }
    }
    return _giftStatisticsArray;
}

- (UIImageView*)giftImg
{
    if (_giftImg == nil) {
        _giftImg = [[UIImageView alloc]initWithFrame:CGRectMake(5, 16, 18, 18)];
        _giftImg.image = [UIImage imageNamed:@"giftrecord"];
    }
    return _giftImg;
}

- (UIButton*)giftListBtn
{
    if (_giftListBtn == nil) {
        _giftListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _giftListBtn.frame = CGRectMake(0, 0, KScreenWidth/2, kButtonDefaultHeight);
        [_giftListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_giftListBtn setTitle:@"gift record" forState:UIControlStateNormal];
        _giftListBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_giftListBtn.titleLabel setFont:[UIFont fontWithName:@"Alibaba-PuHuiTi" size:14.f]];
        _giftListBtn.tag = 100;
        [_giftListBtn addSubview:self.giftImg];
    }
    return _giftListBtn;
}

- (UITableView*)giftTableView
{
    if (_giftTableView == nil) {
        _giftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_giftListBtn.frame), _giftView.width, _giftView.height - CGRectGetMaxY(_giftListBtn.frame)) style:UITableViewStylePlain];
        _giftTableView.dataSource = self;
        _giftTableView.delegate = self;
        _giftTableView.backgroundColor = [UIColor clearColor];
        _giftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _giftTableView.tableFooterView = [[UIView alloc] init];
    }
    return _giftTableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.giftStatisticsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EaseGiftlistCell *cell;
    if (tableView == _giftTableView) {
        static NSString *CellIdentifierMember = @"giftCase";
        NSMutableArray *tempArray = [self.giftStatisticsArray objectAtIndex:indexPath.row];
        cell = (EaseGiftlistCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierMember];
        if (cell == nil) {
            cell = [[EaseGiftlistCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMember];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"x%@",tempArray[2]];
        NSString *giftid = (NSString*)tempArray[0];
        int index = [[giftid substringFromIndex:5] intValue];
        NSDictionary *dict = EaseLiveGiftHelper.sharedInstance.giftArray[index-1];
        cell.imageView.image = [UIImage imageNamed:(NSString *)[dict allKeys][0]];
        cell.userLabel.text = tempArray[1];
    }
    
    /*
    CALayer *cellImageLayer = cell.imageView.layer;
    [cellImageLayer setCornerRadius:15];
    [cellImageLayer setMasksToBounds:YES];*/
    
    CGSize itemSize = CGSizeMake(38, 38);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.textLabel.textColor= [UIColor whiteColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.f;
}

@end
