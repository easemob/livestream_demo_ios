//
//  EaseKeyBoardView.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseKeyBoardView.h"

#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height
/** APP 的主颜色 */
#define RRSAppColor UIColorFromRGBA(0xF3B826, 1.0)

//16进制RGB的颜色转换
#define UIColorFromRGBA(rgbValue,alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define singleKeyBoardHeight kScreenHeight/4

@implementation EaseKeyBoardView

- (id)initWithNumber:(NSNumber *)number;
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.frame = CGRectMake(0, kScreenHeight - 150, kScreenHeight, 150);
        
        [self initKeyBoardNumber_1];
    }
    return self;
}


- (void)initKeyBoardNumber_1
{
    self.frame=CGRectMake(0, kScreenHeight-243, kScreenWidth, 243);
    int space = 1;
    for (int i = 0; i<9; i++) {
        NSString *str = [NSString stringWithFormat:@"%d",i+1];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        if (i<3) {
            button.frame = CGRectMake(i%3*(kScreenWidth/4)+space, i/3*61, kScreenWidth/4-1, 60);
        }
        else{
            button.frame = CGRectMake(i%3*(kScreenWidth/4)+space, i/3*60+i/3*space, kScreenWidth/4-1, 60);
        }
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:24];
        [button setTitle:str forState:UIControlStateNormal];
        button.tag = i+1;
        [button addTarget:self action:@selector(keyBoardAciont:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }

    //空白格
    UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hideBtn.frame = CGRectMake(space,60*3+3 , kScreenWidth/4-1, 60);
    hideBtn.backgroundColor = [UIColor whiteColor];
    hideBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    hideBtn.tag=12;
    [self addSubview:hideBtn];
    
    // 0

    UIButton *zeroBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    zeroBtn.frame = CGRectMake(kScreenWidth/4+1*space,60*3+3, kScreenWidth/4-1, 60);
    zeroBtn.backgroundColor = [UIColor whiteColor];
    [zeroBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    zeroBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [zeroBtn setTitle:@"0" forState:UIControlStateNormal];
    zeroBtn.tag = 0;
    [zeroBtn addTarget:self action:@selector(keyBoardAciont:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zeroBtn];
    
    UIButton *dianBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    dianBtn.frame=CGRectMake(kScreenWidth/4*2+space,60*3+3, kScreenWidth/4-1, 60);
    dianBtn.backgroundColor = [UIColor whiteColor];
    dianBtn.tag = 11;
    [self addSubview:dianBtn];

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteBtn.frame = CGRectMake(kScreenWidth/4*3+space,1, kScreenWidth/4-1,  60);
    deleteBtn.backgroundColor = [UIColor whiteColor];
    [deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [deleteBtn setTitle:@"x" forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(keyBoardAciont:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.tag = 10;
    [self addSubview:deleteBtn];
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(kScreenWidth/4*3+space,61*1, kScreenWidth/4-1, 181);
    confirmBtn.backgroundColor = RRSAppColor;
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [confirmBtn setTitle:@"confirm" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(keyBoardAciont:) forControlEvents:UIControlEventTouchUpInside];
    confirmBtn.tag = 13;
    [self addSubview:confirmBtn];

}

#pragma 键盘点击按钮事件
- (void)keyBoardAciont:(UIButton *)sender
{
    UIButton* btn = (UIButton*)sender;
    NSInteger number = btn.tag;
    // no delegate, print log info
    if (nil == _delegate) {
        NSLog(@"button tag [%ld]",(long)number);
        return;
    }


    if (number <= 9 && number >= 0) {
        [_delegate numberKeyBoard:number];
        return;
    }

    if (10 == number) {
        [_delegate cancelKeyBoard];
        return;
    }
    if (11 == number) {
        [_delegate periodKeyBoard];
        return;
    }
    if (12 == number) {
        [_delegate changeKeyBoard];
        return;
    }

    if (13 == number) {
        [_delegate finishKeyBoard];
        return;
    }
    
}
@end
