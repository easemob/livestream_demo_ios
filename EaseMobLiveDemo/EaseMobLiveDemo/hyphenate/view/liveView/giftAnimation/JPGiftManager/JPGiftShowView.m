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

static const NSInteger animationTime = 5;

@interface JPGiftShowView()
{
    NSInteger _num;
    NSTimer *_timer;
    NSInteger _refreshInterval;//刷新间隔
}
@property(nonatomic,strong) UIImageView *xImgView;
@end

@implementation JPGiftShowView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //245
        self.backgroundColor = [UIColor blackColor];
        self.hidden = YES;
        [self p_SetUI];
    }
    return self;
}

#pragma mark -设置UI
- (void)p_SetUI {
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, showGiftView_GiftIcon_H)];
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.layer.cornerRadius = showGiftView_GiftIcon_H*0.5;
    [self.bgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.bgView];
    
    self.userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bgView.frame)+showGiftView_UserIcon_LT, showGiftView_UserIcon_LT, showGiftView_UserIcon_WH, showGiftView_UserIcon_WH)];
    self.userIconView.layer.cornerRadius = showGiftView_UserIcon_WH*0.5;
    self.userIconView.layer.masksToBounds = YES;
    [self addSubview:self.userIconView];
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userIconView.frame)+showGiftView_UserName_L, (showGiftView_GiftIcon_H-2*showGiftView_UserName_H-5)*0.5, showGiftView_UserName_W, showGiftView_UserName_H)];
    self.userNameLabel.text = @"system";
    self.userNameLabel.textColor = [UIColor whiteColor];
    self.userNameLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:self.userNameLabel];
    
    self.giftNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.userNameLabel.frame),CGRectGetMaxY(self.userNameLabel.frame)+5, showGiftView_UserName_W*2, showGiftView_UserName_H)];
    self.giftNameLabel.text = @"gift";
    self.giftNameLabel.textColor = [UIColor colorWithRed:255/255.0 green:214/255.0 blue:84/255.0 alpha:1];
    self.giftNameLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.giftNameLabel];
    
    self.giftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userNameLabel.frame), 0, showGiftView_GiftIcon_W, showGiftView_GiftIcon_H)];
    [self addSubview:self.giftImageView];
    
    self.xImgView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.giftImageView.frame)+showGiftView_XNum_L, self.frame.size.height - 18, 13, 11)];
    _xImgView.image = [UIImage imageNamed:@"X"];
    self.xImgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.xImgView];
    
    self.countLabel = [[JPGiftCountLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.giftImageView.frame)+showGiftView_XNum_L+13, (showGiftView_GiftIcon_H-showGiftView_XNum_H)*0.5, showGiftView_XNum_W, self.frame.size.height)];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.countLabel.layer.cornerRadius = self.frame.size.height / 2;
    self.countLabel.font = [UIFont fontWithName:@"Zapfino" size:20.f];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    [self.countLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.countLabel.text = @"";
    [self addSubview:self.countLabel];
}

- (void)showGiftShowViewWithModel:(JPGiftModel *)giftModel completeBlock:(completeShowViewBlock)completeBlock{
    
    self.finishModel = giftModel;
    //[self.userIconView sd_setImageWithURL:[NSURL URLWithString:giftModel.userIcon] placeholderImage:[UIImage imageNamed:@""]];
    self.userIconView.image = giftModel.userIcon;
    self.userNameLabel.text = giftModel.userName;
    self.giftNameLabel.text = [NSString stringWithFormat:@"送 %@",giftModel.giftName];
    //[self.giftImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.giftImage] placeholderImage:[UIImage imageNamed:@""]];
    self.giftImageView.image = giftModel.giftImage;
    self.hidden = NO;
    self.showViewFinishBlock = completeBlock;
    NSLog(@"当前展示的礼物--%@",giftModel.giftName);
    if (self.showViewKeyBlock && self.currentGiftCount == 0) {
        self.showViewKeyBlock(giftModel);
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.frame =CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
        self.currentGiftCount = 0;
        [self setGiftCount:giftModel.defaultCount];
        
    }];}

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
    NSLog(@"累计礼物数 %zd",self.currentGiftCount);
}

- (void)startTimer {
    [self stopTimer];
    _num = 1;
    //ios设备最快刷新60hz 60次/秒
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
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)_num];
    if(_num >= self.currentGiftCount){
        [self stopTimer];
        if (self.currentGiftCount > 1) {
            [self p_SetAnimation:self.countLabel];
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

- (void)p_SetAnimation:(UIView *)view {
    
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.08;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:1.0];
    pulse.toValue= [NSNumber numberWithFloat:1.2];
    
    [[view layer] addAnimation:pulse forKey:nil];
}


@end
