//
//  EaseLiveGiftView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/21.
//  Copyright © 2016年 zmw. All rights reserved.
//

#define kDEfaultGiftSelectedColor RGBACOLOR(19,84,254,0.2)
#define kDEfaultGiftBorderSelectedColor RGBACOLOR(91,148,255,1)

#import "EaseLiveGiftView.h"

#import "EaseGiftCell.h"
#import "EaseLiveGiftHelper.h"

@interface EaseLiveGiftView () <UICollectionViewDelegate,UICollectionViewDataSource,EaseGiftCellDelegate>
{
    long _giftNum;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *brushGiftBtn;
@property (nonatomic, strong) UILabel *fortuneLabel;
@property (nonatomic, strong) UIView *giftTagView;

@property (nonatomic, strong) UIView *selectedGiftNumView;
@property (nonatomic, strong) UILabel *selectedGiftDesc;
@property (nonatomic, strong) UIButton *giftNumBtn;

@property (nonatomic, strong) NSArray *giftArray;
@property (nonatomic, strong) EaseGiftCell *selectedGiftCell;

@end

@implementation EaseLiveGiftView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.bottomView];
        [self addSubview:self.giftTagView];
        [self.bottomView addSubview:self.collectionView];
        [self.bottomView addSubview:self.selectedGiftDesc];
        [self.bottomView addSubview:self.brushGiftBtn];
        [self.bottomView addSubview:self.selectedGiftNumView];

        self.selectedGiftDesc.hidden = YES;
        self.selectedGiftNumView.hidden = YES;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.bottom, self.width, 1.f)];
        line.backgroundColor = kDefaultSystemLightGrayColor;
        [self.bottomView addSubview:line];
        self.giftArray = [EaseLiveGiftHelper sharedInstance].giftArray;
        
        _giftNum = 1;
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
        _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}

- (UIView*)giftTagView
{
    if (_giftTagView == nil) {
        _giftTagView = [[UIView alloc]initWithFrame:CGRectMake(0, _bottomView.top - 50.f, self.width, 50.f)];
        _giftTagView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UIImageView *giftImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10.f, 20.f, 20.f)];
        giftImg.image = [UIImage imageNamed:@"ic_Gift"];
        [_giftTagView addSubview:giftImg];
        UILabel *giftTag = [[UILabel alloc]initWithFrame:CGRectMake(40.f, 10.f, 40.f, 20.f)];
        giftTag.text = @"礼物";
        giftTag.font = [UIFont systemFontOfSize:16.f];
        giftTag.textColor = [UIColor whiteColor];
        giftTag.backgroundColor = [UIColor clearColor];
        [_giftTagView addSubview:giftTag];
    }
    return _giftTagView;
}

- (UILabel*)fortuneLabel
{
    if (_fortuneLabel == nil) {
        _fortuneLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.f, _collectionView.bottom, self.width/2, 54.f)];
        _fortuneLabel.font = [UIFont systemFontOfSize:18.f];
        _fortuneLabel.textColor = kDefaultSystemTextColor;
        _fortuneLabel.text = @"金币数:  321";
    }
    return _fortuneLabel;
}

- (UIView *)selectedGiftNumView
{
    if (_selectedGiftNumView == nil) {
        _selectedGiftNumView = [[UIView alloc] initWithFrame:CGRectMake(self.width - 120 - 94, _collectionView.bottom + 10.f, 110.f, 34.f)];
        _selectedGiftNumView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        
        UIButton *subtractBtn = [[UIButton alloc]init];
        [subtractBtn setTitle:@"-" forState:UIControlStateNormal];
        [subtractBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        subtractBtn.layer.cornerRadius = 15.f;
        subtractBtn.backgroundColor = [UIColor blackColor];
        subtractBtn.titleLabel.font = [UIFont systemFontOfSize:26.f];
        [subtractBtn addTarget:self action:@selector(subtractGiftNumAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectedGiftNumView addSubview:subtractBtn];
        [subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@30.f);
            make.left.equalTo(_selectedGiftNumView.mas_left);
            make.top.equalTo(_selectedGiftNumView.mas_top).offset(2.f);
        }];
        
        self.giftNumBtn = [[UIButton alloc]init];
        [_giftNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_giftNumBtn setTitle:@"1" forState:UIControlStateNormal];
        _giftNumBtn.layer.cornerRadius = 15.f;
        _giftNumBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [_giftNumBtn addTarget:self action:@selector(giftNumCustom) forControlEvents:UIControlEventTouchUpInside];
        [_selectedGiftNumView addSubview:self.giftNumBtn];
        [self.giftNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@30.f);
            make.left.equalTo(subtractBtn.mas_right).offset(10.f);
            make.top.equalTo(_selectedGiftNumView.mas_top).offset(4.f);
        }];
        
        UIButton *addtBtn = [[UIButton alloc]init];
        [addtBtn setTitle:@"+" forState:UIControlStateNormal];
        [addtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addtBtn.layer.cornerRadius = 15.f;
        addtBtn.backgroundColor = [UIColor blackColor];
        addtBtn.titleLabel.font = [UIFont systemFontOfSize:26.f];
        [addtBtn addTarget:self action:@selector(addGiftNumAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectedGiftNumView addSubview:addtBtn];
        [addtBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@30.f);
            make.right.equalTo(_selectedGiftNumView.mas_right);
            make.top.equalTo(_selectedGiftNumView.mas_top).offset(2.f);
        }];
    }
    return _selectedGiftNumView;
}

- (UILabel*)selectedGiftDesc
{
    if (_selectedGiftDesc == nil) {
        _selectedGiftDesc = [[UILabel alloc] initWithFrame:CGRectMake(13.f, _collectionView.bottom, self.width/2, 54.f)];
        _selectedGiftDesc.font = [UIFont systemFontOfSize:18.f];
        _selectedGiftDesc.textColor = [UIColor whiteColor];
    }
    return _selectedGiftDesc;
}

- (UIButton*)brushGiftBtn
{
    if (_brushGiftBtn == nil) {
        _brushGiftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _brushGiftBtn.frame = CGRectMake(self.width - 94.f, _collectionView.bottom + 10.f, 80.f, 34.f);
        _brushGiftBtn.backgroundColor = [UIColor brownColor];
        [_brushGiftBtn setTitle:@"赠送" forState:UIControlStateNormal];
        [_brushGiftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _brushGiftBtn.layer.cornerRadius = 10.f;
        [_brushGiftBtn addTarget:self action:@selector(brushGiftACtion) forControlEvents:UIControlEventTouchUpInside];
    }
    return _brushGiftBtn;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.giftArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EaseGiftCell *cell = (EaseGiftCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"giftCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    //选中状态
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedView.backgroundColor = kDEfaultGiftSelectedColor;
    selectedView.alpha = 0.2;
    selectedView.layer.borderWidth = 1;
    selectedView.layer.borderColor = kDEfaultGiftBorderSelectedColor.CGColor;
    selectedView.layer.cornerRadius = 2;
    cell.selectedBackgroundView = selectedView;
    
    NSDictionary *dict = self.giftArray[row];
    [cell setGiftWithImageName:(NSString *)[dict allKeys][0] name:NSLocalizedString((NSString *)[dict allKeys][0], @"")  price:((NSNumber *)[dict objectForKey:[dict allKeys][0]]).description];
    cell.giftId = [NSString stringWithFormat:@"gift_%ld",(long)(row+1)];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((_collectionView.width - 40)/4, (_collectionView.height - 10)/2);
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
    
}

#pragma mark - EaseGiftCellDelegate

- (void)giftCellDidSelected:(EaseGiftCell *)aCell
{
    self.selectedGiftDesc.hidden = NO;
    self.selectedGiftNumView.hidden = NO;
    self.selectedGiftDesc.text = aCell.nameLabel.text;
    self.selectedGiftCell = aCell;
}

#pragma mark - EaseCustomKeyBoardDelegate

//自定义礼物数量
- (void)customGiftNum:(NSString *)giftNum
{
    _giftNum = (long)[giftNum longLongValue];
    [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
}

#pragma mark - action
//刷礼物
- (void)brushGiftACtion
{
    self.selectedGiftDesc.hidden = YES;
    self.selectedGiftNumView.hidden = YES;
    if (self.selectedGiftCell) {
        if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(didConfirmGift:giftNum:)]) {
            [self.giftDelegate didConfirmGift:self.selectedGiftCell giftNum:_giftNum];
        }
    }
}

//增加礼物数量
- (void)addGiftNumAction
{
    if (_giftNum >= 999) {
        return;
    }
    _giftNum += 1;
    [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
}

//减少礼物数量
- (void)subtractGiftNumAction
{   
    if (_giftNum <= 1) {
        return;
    } else {
        _giftNum -= 1;
        [self.giftNumBtn setTitle:[NSString stringWithFormat:@"%lu",_giftNum] forState:UIControlStateNormal];
    }
}

//自定义礼物数量
- (void)giftNumCustom
{
    if (self.giftDelegate && [self.giftDelegate respondsToSelector:@selector(giftNumCustom:)]) {
        [self.giftDelegate giftNumCustom:self];
    }
}

@end
