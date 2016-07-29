//
//  EaseLiveGiftView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveGiftView.h"

#import "EaseGiftCell.h"

@interface EaseLiveGiftView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *reChargeButton;
@property (nonatomic, strong) UILabel *fortuneLabel;

@end

@implementation EaseLiveGiftView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.collectionView];
        [self.bottomView addSubview:self.fortuneLabel];
        [self.bottomView addSubview:self.reChargeButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.bottom, self.width, 1.f)];
        line.backgroundColor = kDefaultSystemLightGrayColor;
        [self.bottomView addSubview:line];
    }
    return self;
}

#pragma mark - getter

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, _bottomView.height - 54.f) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseGiftCell class] forCellWithReuseIdentifier:@"giftCollectionCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), 0);
        _collectionView.pagingEnabled = YES;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

- (UIView*)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 290.f, self.width, 290.f)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UILabel*)fortuneLabel
{
    if (_fortuneLabel == nil) {
        _fortuneLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.f, _collectionView.bottom, self.width/2, 54.f)];
        _fortuneLabel.font = [UIFont systemFontOfSize:18.f];
        _fortuneLabel.textColor = kDefaultSystemTextColor;
        _fortuneLabel.text = @"目金币数:  321";
    }
    return _fortuneLabel;
}

- (UIButton*)reChargeButton
{
    if (_reChargeButton == nil) {
        _reChargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reChargeButton.frame = CGRectMake(self.width - 94.f - 13.f, _collectionView.bottom + 10.f, 94.f, 34.f);
        _reChargeButton.backgroundColor = kDefaultSystemBgColor;
        [_reChargeButton setTitle:NSLocalizedString(@"button.recharge", @"Recharge") forState:UIControlStateNormal];
        [_reChargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _reChargeButton.layer.cornerRadius = 4.f;
        [_reChargeButton addTarget:self action:@selector(reChargeButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reChargeButton;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseGiftCell *cell = (EaseGiftCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"giftCollectionCell" forIndexPath:indexPath];
    [cell setGiftWithImageName:@"live_gift_default" name:@"测试" price:@"1 金币"];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((_collectionView.width - 40)/5, (_collectionView.height - 10)/2);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(didSelectGiftWithGiftId:)]) {
        [self.giftDelegate didSelectGiftWithGiftId:@""];
    }
    [self removeFromParentView];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - action

- (void)rechargeAction
{
    
}

@end
