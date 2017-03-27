//
//  EaseLiveHeaderListView.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/15.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseLiveHeaderListView.h"

#import "EaseLiveCastView.h"
#import "EaseLiveRoom.h"

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
{
    EasePublishModel *_model;
    EaseLiveRoom *_room;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) EaseLiveCastView *liveCastView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger occupantsCount;

@end

@implementation EaseLiveHeaderListView

- (instancetype)initWithFrame:(CGRect)frame model:(EasePublishModel*)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self addSubview:self.collectionView];
        [self addSubview:self.liveCastView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame room:(EaseLiveRoom*)room
{
    self = [super initWithFrame:frame];
    if (self) {
        _room = room;
        [self addSubview:self.collectionView];
        [self addSubview:self.liveCastView];
    }
    return self;
}

#pragma mark - getter

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
        CGFloat width = 135;
        if (KScreenWidth > 320) {
            width = 170;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.width - width - 10.f, 0, width, CGRectGetHeight(self.frame)) collectionViewLayout:flowLayout];
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

- (EaseLiveCastView*)liveCastView
{
    if (_liveCastView == nil) {
        _liveCastView = [[EaseLiveCastView alloc] initWithFrame:CGRectMake(10, 0, 120.f, 30.f) room:_room];
    }
    return _liveCastView;
}

#pragma mark - public
- (void)loadHeaderListWithChatroomId:(NSString*)chatroomId
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:chatroomId
                                                                       completion:^(EMChatroom *aChatroom, EMError *aError) {
                                                                           if (!aError) {
                                                                               weakself.occupantsCount = aChatroom.occupantsCount;
                                                                               [weakself.liveCastView setNumberOfChatroom:weakself.occupantsCount];
                                                                           }
                                                                       }];
    
    [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:chatroomId
                                                                        cursor:nil
                                                                      pageSize:10
                                                                    completion:^(EMCursorResult *aResult, EMError *aError) {
                                                                        if (!aError) {
                                                                            [weakself.dataArray addObjectsFromArray:aResult.list];
                                                                            [weakself.collectionView reloadData];
                                                                        }
                                                                    }];
}

- (void)joinChatroomWithUsername:(NSString *)username
{
    if ([self.dataArray count] > 10) {
        [self.dataArray removeObjectAtIndex:0];
    }
    if ([self.dataArray containsObject:username]) {
        return;
    }
    [self.dataArray insertObject:[username copy] atIndex:0];
    self.occupantsCount++;
    [self.liveCastView setNumberOfChatroom:self.occupantsCount];
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
    [self.liveCastView setNumberOfChatroom:self.occupantsCount];
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
    
    [cell setHeadImage:[UIImage imageNamed:@"live_default_user"]];
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
    return 5.0f;
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
