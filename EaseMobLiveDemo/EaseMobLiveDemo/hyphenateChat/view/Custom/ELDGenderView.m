//
//  ELDGenderView.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/4/7.
//  Copyright © 2022 zmw. All rights reserved.
//

#define kBgViewWidth 30.0
#define kBgViewHeight 16.0

#import "ELDGenderView.h"
@interface ELDGenderView ()
@property (nonatomic, strong)UILabel *ageLabel;
@property (nonatomic, strong)UIImageView *genderImageView;
@property (nonatomic, strong)UIView *bgView;

@end


@implementation ELDGenderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


- (void)placeAndLayoutSubviews {    
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


- (void)updateWithGender:(NSInteger)gender birthday:(NSString *)birthday {
    if (birthday.length > 0) {
        NSInteger age = [ELDUtil ageFromBirthString:birthday];
        self.ageLabel.text = [@(age) stringValue];
    }
    
    if (gender == 1) {
        [self.genderImageView setImage:ImageWithName(@"gender_male")];
        self.bgView.backgroundColor =  GenderMaleBgColor;
    }else if (gender == 2){
        [self.genderImageView setImage:ImageWithName(@"gender_female")];
        self.bgView.backgroundColor =  GenderFemaleBgColor;
    }else if (gender == 3){
        [self.genderImageView setImage:ImageWithName(@"gender_other")];
        self.bgView.backgroundColor =  GenderOtherBgColor;
    }else if (gender == 4){
        [self.genderImageView setImage:ImageWithName(@"gender_secret")];
        self.bgView.backgroundColor =  GenderSecretBgColor;
    }else {
        [self.genderImageView setImage:ImageWithName(@"gender_secret")];
        self.bgView.backgroundColor =  GenderSecretBgColor;
    }
     
}

#pragma mark getter and setter
- (UILabel*)ageLabel
{
    if (_ageLabel == nil) {
        _ageLabel = [[UILabel alloc] init];
        _ageLabel.font = NFont(10.0f);
        _ageLabel.textColor = [UIColor whiteColor];
        _ageLabel.textAlignment = NSTextAlignmentLeft;
        _ageLabel.text = @"0";
    }
    return _ageLabel;
}


- (UIImageView *)genderImageView {
    if (_genderImageView == nil) {
        _genderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gender_male"]];
        _genderImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _genderImageView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = GenderMaleBgColor;
        
        [_bgView addSubview:self.genderImageView];
        [_bgView addSubview:self.ageLabel];

        [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
//            make.left.equalTo(_bgView).offset(2.0);
            make.width.equalTo(@(10.0));
            make.right.equalTo(self.ageLabel.mas_left);
        }];
        
        [self.ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bgView);
            make.left.equalTo(_bgView.mas_centerX);
            make.right.equalTo(_bgView).offset(-2.0);
        }];
    }
    return _bgView;
}

@end

#undef kBgViewWidth
#undef kBgViewHeight

