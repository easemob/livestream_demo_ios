//
//  EaseCustomSwitch.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/3/2.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseCustomSwitch.h"

@interface EaseCustomSwitch ()

@property(nonatomic,strong) UIView * btnView;

@property(nonatomic,strong) UILabel * contentLabel;

@property(nonatomic,strong) UITapGestureRecognizer * tapGes;

@property(nonatomic,assign) BOOL isOn;

//数据

@property(nonatomic,strong) UIFont * textFont;

@property(nonatomic,copy) NSString * onText;
@property(nonatomic,copy) NSString * offText;

@property(nonatomic,strong) UIColor * bgOnColor;
@property(nonatomic,strong) UIColor * bgOffColor;

@property(nonatomic,strong) UIColor * btnOnColor;
@property(nonatomic,strong) UIColor * btnOffColor;

@property(nonatomic,strong) UIColor * textOnColor;
@property(nonatomic,strong) UIColor * textOffColor;

@end

@implementation EaseCustomSwitch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
- (instancetype)initWithTextFont:(UIFont *)textFont OnText:(NSString *)onText offText:(NSString *)offText onBackGroundColor:(UIColor *)bgOnColor offBackGroundColor:(UIColor *)bgOffColor onButtonColor:(UIColor *)btnOnColor offButtonColor:(UIColor *)btnOffColor onTextColor:(UIColor *)textOnColor andOffTextColor:(UIColor *)textOffColor isOn:(BOOL)isOn frame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.isOn = isOn;
        self.frame = frame;
        
        if (onText) {
            self.onText = onText;
        } else {
            //缺省值
            self.onText = @"text";
        }
        
        if (offText) {
            self.offText = offText;
        } else {
            //缺省值
            self.offText = @"text";
        }
        
        if (bgOnColor) {
            self.bgOnColor = bgOnColor;
        } else {
            //缺省值
            self.bgOnColor = [UIColor redColor];
        }
        
        if (bgOffColor) {
            self.bgOffColor = bgOffColor;
        } else {
            //缺省值
            self.bgOffColor = [UIColor lightGrayColor];
        }
        
        if (btnOnColor) {
            self.btnOnColor = btnOnColor;
        } else {
            //缺省值
            self.btnOnColor = [UIColor whiteColor];
        }
        
        if (btnOffColor) {
            self.btnOffColor = btnOffColor;
        } else {
            //缺省值
            self.btnOffColor = [UIColor whiteColor];
        }
        
        if (textOnColor) {
            self.textOnColor = textOnColor;
        } else {
            //缺省值
            self.textOnColor = [UIColor redColor];
        }
        
        if (textOffColor) {
            self.textOffColor = textOffColor;
        } else {
            //缺省值
            self.textOffColor = [UIColor lightGrayColor];
        }
        
        if (textFont) {
            self.textFont = textFont;
        } else {
            //缺省值
            self.textFont = [UIFont systemFontOfSize:9];
        }
        
        
        [self prepareUI];
        
        if (self.isOn) {
            [self stateOn];
        } else {
            [self stateOff];
        }
    }
    return self;
}


- (void)layoutSubviews {
    [self frameSetup];
}



- (void)prepareUI {
    
    [self addSubview:self.btnView];
    
    [self.btnView addSubview:self.contentLabel];
    
    [self frameSetup];
    
    [self addGestureRecognizer:self.tapGes];
    
}

- (void)frameSetup {
    
    CGFloat x,y,w,h;
    
    if (self.isOn) {
        x = self.frame.size.width - self.btnView.frame.size.width - 2;
    } else {
        x = 2;
    }
    //x = 2;
    y = 2;
    w = self.frame.size.height - 2 * 2;
    h = self.frame.size.height - 2 * 2;
    self.btnView.frame = CGRectMake(x, y, w, h);
    
    self.btnView.layer.cornerRadius = w / 2;
    self.btnView.layer.masksToBounds = YES;
    
    x = 0;
    y = 0;
    self.contentLabel.frame = CGRectMake(x, y, w, h);
    
    self.layer.cornerRadius = self.frame.size.height * 0.5;
    self.layer.masksToBounds = YES;
    
}


//关闭状态的UI
- (void)stateOff {
    
    self.backgroundColor = self.bgOffColor;
    
    self.btnView.backgroundColor = self.btnOffColor;
    
    self.contentLabel.textColor = self.textOffColor;
    
    self.contentLabel.text = self.offText;
    

    CGFloat x,y,w,h;
    
    x = 2;
    y = 2;
    w = self.frame.size.height - 2 * 2;
    h = self.frame.size.height - 2 * 2;
    self.btnView.frame = CGRectMake(x, y, w, h);
    
}


//打开状态的UI
- (void)stateOn {
    
    self.backgroundColor = self.bgOnColor;
    
    self.btnView.backgroundColor = self.btnOnColor;
    
    self.contentLabel.textColor = self.textOnColor;
    
    self.contentLabel.text = self.onText;
    
    
    CGFloat x,y,w,h;
    
    x = self.frame.size.width - self.btnView.frame.size.width - 2;
    y = 2;
    w = self.frame.size.height - 2 * 2;
    h = self.frame.size.height - 2 * 2;
    self.btnView.frame = CGRectMake(x, y, w, h);
    
}


//改变开关状态
- (void)changeState {
    
    __weak EaseCustomSwitch * weakSelf = self;
    self.isOn = !self.isOn;
    
    //block非空判断,不写会崩溃
    if (self.changeStateBlock) {
        self.changeStateBlock(self.isOn);
    } else {
        NSLog(@"self.changeStateBlock() is nil");
    }
    
    //UIView动画改变UI布局
    if (self.isOn) {
        [UIView animateWithDuration:0 animations:^{
            [weakSelf stateOn];
        }];
    }else{
        [UIView animateWithDuration:0 animations:^{
            [weakSelf stateOff];
        }];
    }
    
    NSLog(@"SwitchisOn:%d",self.isOn);
    
}



#pragma mark - 懒加载

- (UILabel *)contentLabel{
    if (!_contentLabel){
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.text = @"";
        _contentLabel.font = _textFont;
        _contentLabel.textColor = [UIColor colorWithRed:225./255. green:223./255. blue:223./255. alpha:1];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

- (UIView *)btnView{
    if (!_btnView){
        _btnView = [[UIView alloc] init];
    }
    
    return _btnView;
}


- (UITapGestureRecognizer *)tapGes{
    if (!_tapGes){
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeState)];
    }
    return _tapGes;
}


@end
