//
//  MISTabBar.m
//  AFNetworking
//
//  Created by liujinliang on 2020/7/24.
//

#import "ELDTabBar.h"
#import <Masonry/Masonry.h>

#define kAvatarImageViewHeight 26.0f

@interface ELD_TabItem()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView   *iconCoverView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@end
@implementation ELD_TabItem


- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                selectedImage:(UIImage *)selectedImage {
    self = [super init];
    if (self) {
        _image = image;
        _selectedImage = selectedImage;
        _selected = NO;
        self.iconImageView.image = image;
        
        [self addSubview:self.iconImageView];
        [self addSubview:self.iconCoverView];
        
        [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(11.0f);
            make.centerX.equalTo(self);
            make.size.equalTo(@(kAvatarImageViewHeight));
        }];
        
        [self.iconCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.iconImageView);
        }];
                
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf)]];
    }
    return self;
}

- (void)tapSelf {
    if (self.selectedBlock)
        self.selectedBlock(self.tag);
}

- (void)updateTabbarItemWithImage:(UIImage *)image
                    selectedImage:(UIImage *)selectedImage {
    _image = image;
    _selectedImage = selectedImage;
    
    self.iconImageView.layer.cornerRadius = kAvatarImageViewHeight * 0.5;
    self.iconImageView.clipsToBounds = YES;
}

- (void)updateTabbarItemWithUrlString:(NSString *)urlString {
    ELD_WS
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:kDefultUserImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error == nil) {
            weakSelf.image = image;
            weakSelf.selectedImage = image;
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iconImageView.layer.cornerRadius = kAvatarImageViewHeight * 0.5;
        self.iconImageView.clipsToBounds = YES;
    });
}

#pragma mark getter and setter
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = UILabel.new;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = NFont(11.0f);
        _titleLabel.textColor = COLOR_HEX(0xC9CFCF);
    }
    return _titleLabel;
}

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = UIImageView.new;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.clipsToBounds = YES;
    }
    return _iconImageView;
}


- (UIView *)iconCoverView {
    if (_iconCoverView == nil) {
        _iconCoverView = [[UIView alloc] init];
        _iconCoverView.backgroundColor = ViewControllerBgBlackColor;
        _iconCoverView.alpha = 0.5;
        _iconCoverView.layer.cornerRadius = kAvatarImageViewHeight * 0.5;
        _iconCoverView.layer.masksToBounds = YES;
        _iconCoverView.clipsToBounds = YES;
        _iconCoverView.hidden = YES;
    }
    return _iconCoverView;
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
    }
    
    _iconImageView.image = selected ? _selectedImage : _image;
    _titleLabel.textColor = selected ? COLOR_HEX(0x3BD5F1) : COLOR_HEX(0xC9CFCF);

    if (self.tag == 1001) {
        self.iconCoverView.hidden = _selected ? YES : NO;
    }

}

@end


@interface ELDTabBar()
@property (nonatomic,strong) UIView *bottomBarBgView;

@end

@implementation ELDTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectedIndex = -1;
        [self addSubview:self.bottomBarBgView];
        [self.bottomBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark updateItem
- (void)updateTabbarItemIndex:(NSInteger )itemIndex
                    withImage:(UIImage *)image
                selectedImage:(UIImage *)selectedImage {
    if (itemIndex < self.tabItems.count) {
        ELD_TabItem *tabItem = self.tabItems[itemIndex];
        if (tabItem) {
            [tabItem updateTabbarItemWithImage:image selectedImage:selectedImage];
        }
    }
}

- (void)updateTabbarItemIndex:(NSInteger )itemIndex
                withUrlString:(NSString *)urlString {
    if (itemIndex < self.tabItems.count) {
        ELD_TabItem *tabItem = self.tabItems[itemIndex];
        if (tabItem) {
            [tabItem updateTabbarItemWithUrlString:urlString];
        }
    }
}


#pragma mark getter and setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        if (selectedIndex >= 0 && selectedIndex < self.tabItems.count) {
            ELD_TabItem* lastItem = nil;
            ELD_TabItem* currentItem = self.tabItems[selectedIndex];
            if (_selectedIndex != -1) {
                lastItem = self.tabItems[_selectedIndex];
            }
            
            //effect
            lastItem.selected = NO;
            currentItem.selected = YES;
            
            //update index
            _selectedIndex = selectedIndex;
            
            //event callback
            if (self.selectedBlock)
                self.selectedBlock(selectedIndex);
        }
    }
}


- (void)setTabItems:(NSArray<ELD_TabItem *> *)tabItems {
    if (_tabItems != tabItems) {
        if (_tabItems.count > 0) {
            [_tabItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        _tabItems = tabItems.copy;
        if (tabItems.count == 0)
            return;
        
        NSInteger tag = 1000;
        for (ELD_TabItem* item in tabItems) {
            ELD_WS
            item.selectedBlock = ^(NSInteger tag) {
                NSInteger index = tag - 1000;
                weakSelf.selectedIndex = index;
            };
            item.tag = tag++;
            item.selected = NO;
            [self addSubview:item];
        }
                
        UIView* lastView = nil;
        for (ELD_TabItem* item in tabItems) {
            [item mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.left.equalTo(lastView.mas_right);
                    make.width.equalTo(lastView);
                }else {
                    make.left.equalTo(self);
                }
                if (item == tabItems.lastObject) {
                    make.right.equalTo(self);
                }
                make.top.and.bottom.equalTo(self);
            }];
            lastView = item;
        }
    }
}


- (UIView *)bottomBarBgView {
    if (_bottomBarBgView == nil) {
 
        _bottomBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0,100,KScreenWidth, kTabBarHeight)];
        _bottomBarBgView.backgroundColor = UIColor.clearColor;
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:ImageWithName(@"TabbarBg")];
        
        UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth,kTabBarHeight)];
        alphaView.alpha = 0.0;
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = COLOR_HEX(0x212226);

        if (@available(iOS 11.0, *)) {
            [_bottomBarBgView addSubview:alphaView];
            [_bottomBarBgView addSubview:bgImageView];
            [_bottomBarBgView addSubview:bottomView];

            [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_bottomBarBgView);
            }];
        
            [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_bottomBarBgView);
                make.left.right.equalTo(_bottomBarBgView);
            }];
            
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(bgImageView.mas_bottom);
                make.left.right.equalTo(_bottomBarBgView);
                make.bottom.equalTo(_bottomBarBgView);
            }];
            
        }else {
            [_bottomBarBgView addSubview:alphaView];
            [_bottomBarBgView addSubview:bgImageView];

            [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_bottomBarBgView);
            }];
        
            [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_bottomBarBgView);
            }];
            
        }
    }
    return _bottomBarBgView;
}


@end

#undef kAvatarImageViewHeight

