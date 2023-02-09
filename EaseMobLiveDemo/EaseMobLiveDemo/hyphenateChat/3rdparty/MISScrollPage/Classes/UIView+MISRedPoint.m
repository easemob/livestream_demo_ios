//
//  UIView+MISRedPoint.m
//  MISScrollPage
//
//  Created by liu on 2020/3/12.
//

#import "UIView+MISRedPoint.h"

#define kRedPointSize  10.0f

@interface MISRedDot()
@property (nonatomic,  unsafe_unretained) UIView *superView;
@property (nonatomic,  strong) MISRedDotConfig *config;
@end

@implementation MISRedDot

+ (instancetype)defaultDot{
    return [MISRedDot redDotWithConfig:[[MISRedDotConfig alloc] init]];
}

+ (instancetype)redDotWithConfig:(MISRedDotConfig *)config{
    MISRedDot *redDot = [[MISRedDot alloc] initWithConfig:config];
    return redDot;
}

- (instancetype)initWithConfig:(MISRedDotConfig *)config{
    self = [super init];
    if (self) {
        _config = config;
        self.frame = CGRectMake(0, 0, config.size.width, config.size.height);
        self.layer.cornerRadius = config.radius;
        self.backgroundColor = config.color;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self update];
        });
    }else{
        @try {
            [_superView removeObserver:self forKeyPath:@"frame"];
            [_superView removeObserver:self forKeyPath:@"bounds"];
            _superView = nil;
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"] ||
        [keyPath isEqualToString:@"bounds"]) {
        [self update];
    }
}

- (void)update
{
    CGRect frame = self.frame;
    frame.origin.x = CGRectGetWidth(self.superview.frame)-_config.size.width-_config.offsetX;
    frame.origin.y = _config.offsetY;
    self.frame = frame;
    
        // superview is UIButton
    if ([self.superview isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.superview;
        CGRect titleRect = [button titleRectForContentRect:button.bounds];
        CGRect imageRect = [button imageRectForContentRect:button.bounds];
        
        CGFloat maxX = MAX(CGRectGetMaxX(titleRect), CGRectGetMaxX(imageRect));
        
        if (maxX > 0) {
            frame.origin.x = maxX - _config.offsetX;
            self.frame = frame;
        }
    }
}

@end

@implementation MISRedDotConfig

- (instancetype)init{
    self = [super init];
    if (self) {
        _size = CGSizeMake(kRedPointSize, kRedPointSize);
        _radius = kRedPointSize * 0.5;
        _color = COLOR_HEX(0xFF14CC);
    }
    return self;
}
@end


@implementation UIView (MISRedPoint)

- (MISRedDot *)MIS_redDot{
    MISRedDot *redDot;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[MISRedDot class]]) {
            redDot = (MISRedDot *)view;
            break;
        }
    }
    return redDot;
}

- (void)setMIS_redDot:(MISRedDot *)MIS_redDot{
    if (MIS_redDot) {
        MIS_redDot.superView = self;
        [self addSubview:MIS_redDot];
        
        [self addObserver:MIS_redDot forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:MIS_redDot forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

@end

#undef kRedPointSize
