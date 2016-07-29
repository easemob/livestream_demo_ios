//
//  EaseLiveHeaderListView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/15.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveHeaderListView.h"
#import "EMClient.h"

#define kCollectionIdentifier @"collectionCell"

@interface EaseLiveHeaderCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *headerImage;

- (void)setHeadImage:(UIImage*)image;

@end

@implementation EaseLiveHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _headerImage = [[UIImageView alloc] init];
        _headerImage.image = [UIImage imageNamed:@"live_default_user"];
        _headerImage.frame = CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame));
        _headerImage.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
        _headerImage.layer.masksToBounds = YES;
        [self.contentView addSubview:_headerImage];
    }
    return self;
}

- (void)setHeadImage:(UIImage*)image
{
    _headerImage.image = image;
}

@end

@interface EaseLiveHeaderListView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, assign) NSInteger occupantsCount;

@end

@implementation EaseLiveHeaderListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self addSubview:self.numberLabel];
    }
    return self;
}

#pragma mark - getter

- (UILabel*)numberLabel
{
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 50.f, 0, 40.f, CGRectGetHeight(self.frame))];
        _numberLabel.font = [UIFont systemFontOfSize:15.f];
        _numberLabel.shadowColor = RGBACOLOR(0xb8, 0xb8, 0xb8, 1);
        _numberLabel.shadowOffset = CGSizeMake(0, 1);
        _numberLabel.layer.shadowRadius = 1.f;
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.textAlignment = NSTextAlignmentRight;
    }
    return _numberLabel;
}

- (NSMutableArray*)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView*)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 270.f, CGRectGetHeight(self.frame)) collectionViewLayout:flowLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_collectionView registerClass:[EaseLiveHeaderCell class] forCellWithReuseIdentifier:kCollectionIdentifier];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), 0);
        _collectionView.pagingEnabled = NO;
        _collectionView.userInteractionEnabled = YES;
    }
    return _collectionView;
}

#pragma mark - public
- (void)loadHeaderListWithChatroomId:(NSString*)chatroomId
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager asyncFetchChatroomInfo:chatroomId includeMembersList:YES success:^(EMChatroom *aChatroom) {
        [weakself.dataArray addObjectsFromArray:aChatroom.occupants];
        weakself.occupantsCount = aChatroom.occupantsCount;
        weakself.numberLabel.text = [NSString stringWithFormat:@"%@",@(weakself.occupantsCount)];
        [weakself.collectionView reloadData];
    } failure:^(EMError *aError) {
        //加载失败
    }];
}

- (void)joinChatroomWithUsername:(NSString *)username
{
    if ([self.dataArray count] > 10) {
        [self.dataArray removeObjectAtIndex:0];
    }
    [self.dataArray insertObject:[username copy] atIndex:0];
    self.occupantsCount++;
    self.numberLabel.text = [NSString stringWithFormat:@"%@",@(self.occupantsCount)];
    [self.collectionView reloadData];
}

- (void)leaveChatroomWithUsername:(NSString *)username
{
    for (int index = 0; index < [self.dataArray count]; index ++) {
        NSString *name = [self.dataArray objectAtIndex:index];
        if ([name isEqualToString:username]) {
            [self.dataArray removeObjectAtIndex:index];
        }
    }
    self.occupantsCount--;
    self.numberLabel.text = [NSString stringWithFormat:@"%@",@(self.occupantsCount)];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EaseLiveHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionIdentifier forIndexPath:indexPath];
    
    [cell setHeadImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",arc4random()%6 + 1]]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview = headerView;
        
    }
    if (kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        reusableview = footerview;
    }
    return reusableview;
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetHeight(self.frame), CGRectGetHeight(self.frame));
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
    NSString *username = [self.dataArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeaderWithUsername:)]) {
        [self.delegate didSelectHeaderWithUsername:username];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
