//
//  TwoBallRotationProgressBar.m
//  TwoBallRotationProgressBar
//
//  Created by HailongHan on 15/8/8.
//  Copyright (c) 2015年 hhl. All rights reserved.
//

#define DEFAULT_RADIUS 10
#define DEFAULT_DISTANCE 15
#define DEFAULT_DURATION 1.2

#import "TwoBallRotationProgressBar.h"

@interface TwoBallRotationProgressBar ()

@property (nonatomic,assign) CGFloat radius;
@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) CGFloat distance;

@property (nonatomic,strong) CAShapeLayer *oneLayer;
@property (nonatomic,strong) CAShapeLayer *twoLayer;

@property (nonatomic,assign) CGPoint centerPoint;

@end

@implementation TwoBallRotationProgressBar


-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        //TODO 初始化
        self.backgroundColor = [UIColor clearColor];
        
        [self initProgressBar];
    }
    return self;
}

- (CAShapeLayer *)oneLayer{
    if (!_oneLayer) {
        _oneLayer = [CAShapeLayer layer];
        _oneLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _oneLayer.fillColor = [UIColor redColor].CGColor;
        _oneLayer.path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES].CGPath;
    }
    return _oneLayer;
}

- (CAShapeLayer *)twoLayer{
    if (!_twoLayer) {
        _twoLayer = [CAShapeLayer layer];
        _twoLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _twoLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _twoLayer.fillColor = [UIColor greenColor].CGColor;
        _twoLayer.path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES].CGPath;
    }
    return _twoLayer;
}

/**
 *  初始化进度条
 */
- (void)initProgressBar{    
    
    self.duration = DEFAULT_DURATION;
    self.radius = DEFAULT_RADIUS;
    self.distance = DEFAULT_DISTANCE;
    
    self.centerPoint = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    
    //添加两个CAShapeLayer
    [self.layer addSublayer:self.oneLayer];
    [self.layer addSublayer:self.twoLayer];
}

#pragma mark - 实现接口
- (void)setBallRadius:(CGFloat)radius{
    self.radius = radius;
    self.oneLayer.path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES].CGPath;
    
    self.twoLayer.path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES].CGPath;
}

- (void)setOneBallColor:(UIColor *)oneColor twoBallColor:(UIColor *)twoColor{
    self.oneLayer.fillColor = oneColor.CGColor;
    self.twoLayer.fillColor = twoColor.CGColor;
}

- (void)setAnimatorDuration:(CGFloat)duration{
    self.duration = duration;
}

- (void)setAnimatorDistance:(CGFloat)distance{
    self.distance = distance;
    if (distance > self.bounds.size.width*0.5) {
        self.distance = self.bounds.size.width*0.5;
    }
}

- (void)startAnimator{
    [self startOneBallAnimator];
    [self startTwoBallAnimator];
}

- (void)startOneBallAnimator{
    CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.z"];
    transformAnimation.values = @[@1,@0,@0,@0,@1];
    
    //第一个小球位移动画
    CAKeyframeAnimation *oneFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.centerPoint.x, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x+self.distance, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x-self.distance, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x, self.centerPoint.y);
    [oneFrameAnimation setPath:path];
    
    //第一个小球缩放动画
    CAKeyframeAnimation *oneScaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    oneScaleAnimation.values = @[@1,@0.5,@0.25,@0.5,@1];
    
    
    //第一个小球透明动画
    CAKeyframeAnimation *oneOpacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    oneOpacityAnimation.values = @[@1,@0.5,@0.25,@0.5,@1];

    //组合动画
    CAAnimationGroup *oneGroup = [CAAnimationGroup animation];
    [oneGroup setAnimations:@[transformAnimation,oneFrameAnimation,oneScaleAnimation,oneOpacityAnimation]];
    oneGroup.duration = self.duration;
    oneGroup.repeatCount = HUGE;
    [self.oneLayer addAnimation:oneGroup forKey:@"oneGroup"];
}

- (void)startTwoBallAnimator{
    CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.z"];
    transformAnimation.values = @[@0,@0,@1,@0,@0];
    
    //第二个小球位移动画
    CAKeyframeAnimation *twoFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.centerPoint.x, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x-self.distance, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x+self.distance, self.centerPoint.y);
    CGPathAddLineToPoint(path, NULL, self.centerPoint.x, self.centerPoint.y);
    [twoFrameAnimation setPath:path];
    
    //第二个小球缩放动画
    CAKeyframeAnimation *twoScaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    twoScaleAnimation.values = @[@0.25,@0.5,@1,@0.5,@0.25];
    
    //第二个小球透明动画
    CAKeyframeAnimation *twoOpacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    twoOpacityAnimation.values = @[@0.25,@0.5,@1,@0.5,@0.25];
    
    //组合动画
    CAAnimationGroup *twoGroup = [CAAnimationGroup animation];
    [twoGroup setAnimations:@[transformAnimation,twoFrameAnimation,twoScaleAnimation,twoOpacityAnimation]];
    twoGroup.duration = self.duration;
    twoGroup.repeatCount = HUGE;
    [self.twoLayer addAnimation:twoGroup forKey:@"twoGroup"];
}

- (void)stopAnimator{
    //TODO
}

@end
