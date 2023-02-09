//
//  ELDWatchMemberAvatarsView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/14.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDWatchMemberAvatarsView.h"

#define kAvatarAlphaBgViewSize 38.0

@interface ELDWatchMemberAvatarsView ()
@property (nonatomic, strong) NSMutableArray *watchArray;
@property (nonatomic, strong) UIView *firstAvatarAlphaBgView;

@end


@implementation ELDWatchMemberAvatarsView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndlayoutSubviews];
    }
    return self;
}

- (void)placeAndlayoutSubviews {
    
    [self addSubview:self.secondMemberImageView];
    [self addSubview:self.firstAvatarAlphaBgView];

    [self.firstAvatarAlphaBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(5.0);
        make.size.equalTo(@(kAvatarAlphaBgViewSize));
    }];
    
    [self.secondMemberImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.firstAvatarAlphaBgView.mas_right).offset(-10.0);
        make.size.equalTo(@(kAvatarHeight));
        make.right.equalTo(self).offset(-5.0);
    }];
}

- (void)updateWatchersAvatarWithUrlArray:(NSArray *)urlArray {
    
    self.hidden = [urlArray count] > 0 ? NO : YES;
    
    if (urlArray.count == 0) {
        return;
    }
    
    self.secondMemberImageView.hidden = urlArray.count > 1 ? NO : YES;
    if (urlArray.count == 1) {
        self.watchArray = [urlArray mutableCopy];
    }else {
        self.watchArray = [[urlArray subarrayWithRange:NSMakeRange(0, 2)] mutableCopy];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.firstMemberImageView sd_setImageWithURL:[NSURL URLWithString:self.watchArray.firstObject] placeholderImage:kDefultUserImage];
        if (self.watchArray.count == 2) {
            [self.secondMemberImageView sd_setImageWithURL:[NSURL URLWithString:self.watchArray[1]] placeholderImage:kDefultUserImage];
        }
    });

    
}

#pragma mark getter and setter
- (UIImageView *)firstMemberImageView {
    if (_firstMemberImageView == nil) {
        _firstMemberImageView = [[UIImageView alloc] init];
        _firstMemberImageView.contentMode = UIViewContentModeScaleAspectFit;
        _firstMemberImageView.layer.cornerRadius = kAvatarHeight * 0.5;
        _firstMemberImageView.clipsToBounds = YES;
        _firstMemberImageView.layer.masksToBounds = YES;
    }
    return _firstMemberImageView;
}

- (UIImageView *)secondMemberImageView {
    if (_secondMemberImageView == nil) {
        _secondMemberImageView = [[UIImageView alloc] init];
        _secondMemberImageView.contentMode = UIViewContentModeScaleAspectFit;
        _secondMemberImageView.layer.cornerRadius = kAvatarHeight * 0.5;
        _secondMemberImageView.clipsToBounds = YES;
        _secondMemberImageView.layer.masksToBounds = YES;
    }
    return _secondMemberImageView;
}

- (NSMutableArray *)watchArray {
    if (_watchArray == nil) {
        _watchArray = NSMutableArray.new;
    }
    return _watchArray;
}

- (UIView *)firstAvatarAlphaBgView {
    if (_firstAvatarAlphaBgView == nil) {
        _firstAvatarAlphaBgView = [[UIView alloc] init];
        _firstAvatarAlphaBgView.layer.cornerRadius = kAvatarAlphaBgViewSize * 0.5;
    
        UIImageView *alphaView = [[UIImageView alloc] init];
        [alphaView setImage:ImageWithName(@"avatar_alpha_bg")];
        
//        UIView *alphaView = [[UIView alloc] init];
//        alphaView.backgroundColor = UIColor.blackColor;
//        alphaView.alpha = 0.5;
        
        [_firstAvatarAlphaBgView addSubview:alphaView];
        [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_firstAvatarAlphaBgView).insets(UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0));
            
        }];
        
        [_firstAvatarAlphaBgView addSubview:self.firstMemberImageView];
        [self.firstMemberImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_firstAvatarAlphaBgView);
            make.centerX.equalTo(_firstAvatarAlphaBgView);
            make.size.equalTo(@(kAvatarHeight));
        }];
        
    }
    return _firstAvatarAlphaBgView;
}

@end

#undef kAvatarAlphaBgViewSize
