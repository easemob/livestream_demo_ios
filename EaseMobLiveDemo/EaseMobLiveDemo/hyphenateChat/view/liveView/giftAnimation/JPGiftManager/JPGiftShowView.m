//
//  JPGiftShowView.m
//  JPGiftManager
//
//  Created by Keep丶Dream on 2018/3/13.
//  Copyright © 2018年 dong. All rights reserved.
//

#import "JPGiftShowView.h"
#import "JPGiftModel.h"
#import "UIImageView+WebCache.h"

#define kBgViewHeight 36.0
#define kUserAvatarHeight 32.0

static const NSInteger animationTime = 5;

@interface JPGiftShowView()
{
    NSInteger _num;
    NSTimer *_timer;
    NSInteger _refreshInterval;//刷新间隔
}

/** 背景 */
@property(nonatomic,strong) UIView *contentView;

@property(nonatomic,strong) UIView *contentBgView;

/** icon */
@property(nonatomic,strong) UIImageView *userIconView;
/** name */
@property(nonatomic,strong) UILabel *userNameLabel;
/** giftName */
@property(nonatomic,strong) UILabel *giftNameLabel;
/** giftImage */
@property(nonatomic,strong) UIImageView *giftImageView;
/** count */
@property(nonatomic,strong) JPGiftCountLabel *countLabel;
/** 礼物数 */
@property(nonatomic,assign) NSInteger giftCount;
/** 当前礼物总数 */
@property(nonatomic,assign) NSInteger currentGiftCount;
/** model */
@property(nonatomic,strong) JPGiftModel *finishModel;


@end

@implementation JPGiftShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        [self placeAndLayoutSubviews];
    }
    return self;
}

#pragma mark -设置UI
- (void)placeAndLayoutSubviews {
    
    [self addSubview:self.contentBgView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.userIconView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.giftNameLabel];
    [self.contentView addSubview:self.giftImageView];
    [self.contentView addSubview:self.countLabel];

    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12.0);
        make.centerY.equalTo(self);
    }];
    
    [self.userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(2.0);
        make.size.equalTo(@(kUserAvatarHeight));
        make.left.equalTo(self.contentView).offset(2.0);
        make.bottom.equalTo(self.contentView).offset(-2.0);
    }];

    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(3.0);
        make.left.equalTo(self.userIconView.mas_right).offset(8.0);
        
        CGFloat maxWidth = KScreenWidth - 12.0 * 2 -kUserAvatarHeight -kBgViewHeight - 2.0 - 8.0 - 4.0 - 12.0 - 36.0;
        make.width.lessThanOrEqualTo(@(maxWidth));
    }];

    [self.giftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-3.0);
        make.left.equalTo(self.userNameLabel);
    }];

    [self.giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userIconView);
        make.size.equalTo(@(kBgViewHeight));
        make.left.equalTo(self.giftNameLabel.mas_right).offset(4.0);
    }];

    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userIconView);
        make.left.equalTo(self.giftImageView.mas_right).offset(12.0);
        make.right.equalTo(self.contentView).offset(-12.0);
    }];

}


- (void)showGiftShowViewWithModel:(JPGiftModel *)giftModel completeBlock:(completeShowViewBlock)completeBlock{
    
    self.finishModel = giftModel;
    [self.userIconView sd_setImageWithURL:[NSURL URLWithString:giftModel.userAvatarURL] placeholderImage:[UIImage imageNamed:@""]];

    self.userNameLabel.text = giftModel.userName;
    NSString *giftName = giftModel.giftName;
    self.giftNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"gift.Sent", nil),NSLocalizedString(giftName,nil)];
    self.giftImageView.image = giftModel.giftImage;
    self.countLabel.text = [NSString stringWithFormat:@"x%@",[@(giftModel.sendCount) stringValue]];
    [self updateGiftImageView];
    
    self.hidden = NO;
    self.showViewFinishBlock = completeBlock;

    if (self.showViewKeyBlock && self.currentGiftCount == 0) {
        self.showViewKeyBlock(giftModel);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.frame =CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
        self.currentGiftCount = 0;
        [self setGiftCount:giftModel.defaultCount];
        
    }];
}


- (void)updateGiftImageView {
    CGFloat userNameWidth = [self.userNameLabel.text sizeWithAttributes:@{
        NSFontAttributeName:self.userNameLabel.font}].width;
    
    CGFloat giftNameWidth = [self.giftNameLabel.text sizeWithAttributes:@{
        NSFontAttributeName:self.giftNameLabel.font}].width;
    
    if (userNameWidth > giftNameWidth) {
        [self.giftImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel.mas_right).offset(4.0);
        }];
    }else {
        [self.giftImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.giftNameLabel.mas_right).offset(4.0);
        }];

    }
    
}

- (void)hiddenGiftShowView {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame =CGRectMake(-self.frame.size.width, self.frame.origin.y-50, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
        if (self.showViewFinishBlock) {
            self.showViewFinishBlock(YES, self.finishModel.giftKey);
        }
        self.frame =CGRectMake(-self.frame.size.width, self.frame.origin.y+50, self.frame.size.width, self.frame.size.height);

        self.hidden = YES;
        self.currentGiftCount = 0;
        self.countLabel.text = @"";
    }];
}

- (void)setGiftCount:(NSInteger)giftCount {
    
    _giftCount = giftCount;
    self.currentGiftCount += giftCount;
    [self startTimer];
}

- (void)startTimer {
    [self stopTimer];
    _num = 1;

    if (self.currentGiftCount >= 120) {
        _refreshInterval = (NSInteger)(self.currentGiftCount / 120);
    } else {
        _refreshInterval = 1;
    }
    double _timeInterval = 2 / self.currentGiftCount;
    _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(setupBtnText) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)setupBtnText{
    NSLog(@"%s _num:%@",__func__,@(_num));
    
    self.countLabel.text = [NSString stringWithFormat:@"x%ld",(long)_num];
    if(_num >= self.currentGiftCount){
        [self stopTimer];
        if (self.currentGiftCount > 1) {
            [self setAnimation:self.countLabel];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenGiftShowView) object:nil];//可以取消成功。
            [self performSelector:@selector(hiddenGiftShowView) withObject:nil afterDelay:animationTime];
            
        }else {
            [self performSelector:@selector(hiddenGiftShowView) withObject:nil afterDelay:animationTime];
        }
    }
    _num += _refreshInterval;
    if (_num > self.currentGiftCount) {
        _num = self.currentGiftCount;
    }
}

- (void)setAnimation:(UIView *)view {
    
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.08;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:1.0];
    pulse.toValue= [NSNumber numberWithFloat:1.2];
    
    [[view layer] addAnimation:pulse forKey:nil];
}

#pragma mark getter and setter
- (UIView *)contentBgView {
    if (_contentBgView == nil) {
        _contentBgView = [[UIView alloc] init];
        _contentBgView.alpha = 0.6;
        _contentBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _contentBgView.layer.cornerRadius = kBgViewHeight*0.5;
        _contentBgView.clipsToBounds = YES;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];

        [_contentBgView addSubview:visualView];
        [visualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_contentBgView);
        }];
    }
    return _contentBgView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = kBgViewHeight*0.5;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}


- (UIImageView *)userIconView {
    if (_userIconView == nil) {
        _userIconView = [[UIImageView alloc] init];
        _userIconView.contentMode = UIViewContentModeScaleAspectFit;
        _userIconView.layer.cornerRadius = kUserAvatarHeight * 0.5;
        _userIconView.clipsToBounds = YES;
        _userIconView.layer.masksToBounds = YES;
    }
    return _userIconView;
}

- (UILabel *)userNameLabel {
    if (_userNameLabel == nil) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.font = Font(@"Roboto", 12.0);
    }
    return _userNameLabel;
}


- (UILabel *)giftNameLabel {
    if (_giftNameLabel == nil) {
        _giftNameLabel = [[UILabel alloc] init];
        _giftNameLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.74];
        _giftNameLabel.font = Font(@"Roboto", 10.0);
    }
    return _giftNameLabel;
}

- (UIImageView *)giftImageView {
    if (_giftImageView == nil) {
        _giftImageView = [[UIImageView alloc] init];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _giftImageView.clipsToBounds = YES;
        _giftImageView.layer.masksToBounds = YES;
    }
    return _giftImageView;
}


- (JPGiftCountLabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[JPGiftCountLabel alloc] init];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = Font(@"Roboto-BoldCondensedItalic", 24.0);
        _countLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _countLabel;
}



@end

#undef kBgViewHeight
#undef kUserAvatarHeight
