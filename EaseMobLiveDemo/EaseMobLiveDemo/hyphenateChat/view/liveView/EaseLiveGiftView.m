//
//  EaseLiveGiftView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveGiftView.h"
#import "EaseGiftCell.h"
#import "EaseLiveGiftHelper.h"
#import "ELDCountCaculateView.h"
#import "ELDGiftModel.h"
#import "ELDGiftCountDownView.h"

#define kBottomViewHeight 320.0f
#define kSendButtonHeight 32.0f
#define kCollectionPadding 10.0f

#define kCollectionCellWidth  (KScreenWidth - kCollectionPadding * 5) * 0.25
#define kCollectionCellHeight  110.0f

#define kCollectionViewHeight (kCollectionCellHeight * 2 + kCollectionPadding)

//#define kCollectionViewHeight 110.0

static NSString* giftCollectionCellIndentify = @"giftCollectionCell";

@interface EaseLiveGiftView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,EaseGiftCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;


@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *bottomBgView;
@property (nonatomic, strong) UIButton *sendGiftButton;


@property (nonatomic, strong) ELDCountCaculateView *countCaculateView;
@property (nonatomic, strong) NSArray *giftArray;
@property (nonatomic, strong) ELDGiftModel *selectedGiftModel;

@property (nonatomic, strong) NSString *sendSuccessGiftId;

@property (nonatomic, strong) UIImageView *giftTotalValueImageView;
@property (nonatomic, strong) UILabel *giftTotalValueLabel;
@property (nonatomic, strong) ELDGiftCountDownView *countDownView;

@end

@implementation EaseLiveGiftView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.giftArray = [EaseLiveGiftHelper sharedInstance].giftArray;
        [self placeAndLayoutSubviews];
    }
    return self;
}

- (void)placeAndLayoutSubviews {

    [self addSubview:self.bottomBgView];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.collectionView];
    [self.bottomView addSubview:self.countCaculateView];
    [self.bottomView addSubview:self.giftTotalValueImageView];
    [self.bottomView addSubview:self.giftTotalValueLabel];
    [self.bottomView addSubview:self.sendGiftButton];
        
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_bottomView).insets(UIEdgeInsetsMake(50, 0, 0, 0));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_top).offset(-10.0);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bottomView);
        make.height.equalTo(@(kCollectionViewHeight));
        make.bottom.equalTo(self.sendGiftButton.mas_top).offset(-10.0);
    }];
    
    [self.sendGiftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(-10.0 -bottom);
        make.right.equalTo(self.bottomView).offset(-20.0);
        make.height.equalTo(@(kSendButtonHeight));
    }];

    [self.giftTotalValueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftButton);
        make.right.equalTo(self.giftTotalValueLabel.mas_left).offset(-5.0);
        make.size.equalTo(@(20.0));
    }];
    
    [self.giftTotalValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftButton);
        make.right.equalTo(self.sendGiftButton.mas_left).offset(-15.0);
    }];

    [self.countCaculateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sendGiftButton);
        make.left.equalTo(self.bottomView.mas_left).offset(20.0);
        make.height.equalTo(@(kSendButtonHeight));
    }];
    
}


- (void)resetWitGiftId:(NSString *)giftId {
    [self.countCaculateView resetCaculateView];
    [self.collectionView reloadData];
    self.sendSuccessGiftId = giftId;
    [self startShowCountDown];
}

- (void)startShowCountDown {

    NSInteger giftIndex = [[self.sendSuccessGiftId substringFromIndex:self.sendSuccessGiftId.length -1] integerValue];
    
    CGFloat center_y = kCollectionCellHeight * 0.5;
    if (giftIndex >= 5) {
        center_y += kCollectionCellHeight + kCollectionPadding;
    }
    
    if (giftIndex >= 5) {
        giftIndex -= 4;
    }
    CGFloat center_x = kCollectionCellWidth * (giftIndex - 1) + kCollectionCellWidth * 0.5 + giftIndex * kCollectionPadding;

    
    [self addSubview:self.countDownView];
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kCollectionCellWidth));
        make.height.equalTo(@(kCollectionCellHeight));
        make.centerX.equalTo(self.collectionView.mas_left).offset(center_x);
        make.centerY.equalTo(self.collectionView.mas_top).offset(center_y);
    }];
    
    self.countDownView.hidden = NO;
    [self.countDownView startCountDown];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.giftArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EaseGiftCell *cell = (EaseGiftCell*)[collectionView dequeueReusableCellWithReuseIdentifier:giftCollectionCellIndentify forIndexPath:indexPath];
    cell.delegate = self;
            
    ELDGiftModel *giftModel = self.giftArray[row];
    giftModel.selected = [giftModel.giftname isEqualToString:self.selectedGiftModel.giftname];
    
    [cell updateWithGiftModel:giftModel];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCollectionCellWidth, kCollectionCellHeight);

}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - EaseGiftCellDelegate
- (void)giftCellDidSelected:(EaseGiftCell *)aCell
{
    self.selectedGiftModel = aCell.giftModel;
    [self.countCaculateView resetCaculateView];
    [self updateGiftTotalValueWithCount:1];
    [self.collectionView reloadData];
}



#pragma mark - action
//刷礼物
- (void)sendGiftAction {
    if (self.selectedGiftModel) {
        if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(didConfirmGiftModel:giftNum:)]) {
            [self.giftDelegate didConfirmGiftModel:self.selectedGiftModel giftNum:self.countCaculateView.giftCount];
            
            [self.countCaculateView resetCaculateView];
        }
    }

}

//自定义礼物数量
- (void)giftNumCustom
{
    if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(giftNumCustom:)]) {
        [self.giftDelegate giftNumCustom:self];
    }
}

#pragma mark - getter and setter
- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseGiftCell class] forCellWithReuseIdentifier:giftCollectionCellIndentify];
                
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
        _collectionView.contentSize = CGSizeMake(KScreenWidth, kCollectionViewHeight);

    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(kCollectionCellWidth, kCollectionCellHeight);
    flowLayout.minimumLineSpacing = kCollectionPadding;
    flowLayout.minimumInteritemSpacing = kCollectionPadding;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, kCollectionPadding, 0, kCollectionPadding);
    
    return flowLayout;
}

- (UIView*)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.layer.cornerRadius = 12.0f;
        _bottomView.clipsToBounds = YES;
        _bottomView.userInteractionEnabled = YES;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualView.layer.cornerRadius = 12.0f;

        [_bottomView addSubview:visualView];
        [visualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomView).insets(UIEdgeInsetsMake(0, 0, -20, 0));
        }];
    }
    return _bottomView;
}

- (UIView *)bottomBgView {
    if (_bottomBgView == nil) {
        _bottomBgView = [[UIView alloc] init];
        _bottomView.alpha = 0.8;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualView.layer.cornerRadius = 12.0f;

        [_bottomBgView addSubview:visualView];
        [visualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_bottomBgView);
        }];
    }
    return _bottomBgView;
}


- (ELDCountCaculateView *)countCaculateView {
    if (_countCaculateView == nil) {
        _countCaculateView = [[ELDCountCaculateView alloc] init];
        _countCaculateView.layer.cornerRadius = kSendButtonHeight* 0.5;
        _countCaculateView.layer.borderWidth = 1.0;
        _countCaculateView.layer.borderColor = TextLabelGrayColor.CGColor;
        
        ELD_WS
        _countCaculateView.tapBlock = ^{
            
        };
        
        _countCaculateView.countBlock = ^(NSInteger count) {
            [weakSelf updateGiftTotalValueWithCount:count];
        };
        
    }
    return _countCaculateView;
}

- (void)updateGiftTotalValueWithCount:(NSInteger)count {
    if (self.selectedGiftModel) {
        NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] init];
        
        NSAttributedString *attributeString = [ELDUtil attributeContent:NSLocalizedString(@"gift.subTotal", nil) color:TextLabelGrayColor font:Font(@"PingFang SC",14.0)];
        
        NSAttributedString *totalAttString = [ELDUtil attributeContent:[NSString stringWithFormat:@" %@",@(self.selectedGiftModel.giftValue * count)] color:TextLabelWhiteColor font:Font(@"PingFang SC",14.0)];
        
        [mutableAttString appendAttributedString:attributeString];
        [mutableAttString appendAttributedString:totalAttString];

        self.giftTotalValueLabel.attributedText = mutableAttString;
    
    }
}


- (UIButton*)sendGiftButton
{
    if (_sendGiftButton == nil) {
        _sendGiftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendGiftButton.frame = CGRectMake(self.width - 94.f, _collectionView.bottom + 10.f, 80.f, 34.f);
        [_sendGiftButton setImage:ImageWithName(NSLocalizedString(@"gift.sendGift",nil)) forState:UIControlStateNormal];
        _sendGiftButton.layer.cornerRadius = 10.f;
        [_sendGiftButton addTarget:self action:@selector(sendGiftAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendGiftButton;
}

- (UIImageView *)giftTotalValueImageView {
    if (_giftTotalValueImageView == nil) {
        _giftTotalValueImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"receive_gift_icon")];
        _giftTotalValueImageView.contentMode = UIViewContentModeScaleAspectFill;
        _giftTotalValueImageView.layer.masksToBounds = YES;
    }
    return _giftTotalValueImageView;
}

- (UILabel*)giftTotalValueLabel
{
    if (_giftTotalValueLabel == nil) {
        _giftTotalValueLabel = [[UILabel alloc] init];
        _giftTotalValueLabel.textColor = [UIColor whiteColor];
        _giftTotalValueLabel.font = [UIFont systemFontOfSize:14.f];
        _giftTotalValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _giftTotalValueLabel;
}

- (ELDGiftCountDownView *)countDownView {
    if (_countDownView == nil) {
        _countDownView = [[ELDGiftCountDownView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80.0)];
        ELD_WS
        _countDownView.countDownFinishBlock = ^{
            [weakSelf.countDownView removeFromSuperview];
        };
        _countDownView.hidden = YES;
    }
    return _countDownView;
}



@end

#undef kBottomViewHeight
#undef kSendButtonHeight
#undef kCollectionPadding
#undef kCollectionCellWidth
#undef kCollectionCellHeight
#undef kCollectionViewHeight
