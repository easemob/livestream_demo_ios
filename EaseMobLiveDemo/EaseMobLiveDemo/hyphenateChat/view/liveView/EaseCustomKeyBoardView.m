//
//  EaseKeyBoardViewController.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2020/2/19.
//  Copyright © 2020 zmw. All rights reserved.
//

#import "EaseCustomKeyBoardView.h"
#import "EaseKeyBoardView.h"

#define kScreenWidth   [UIScreen mainScreen].bounds.size.width
#define kScreenHeight  [UIScreen mainScreen].bounds.size.height


@interface EaseCustomKeyBoardView ()<My_KeyBoardDelegate,UITextFieldDelegate>

@property (nonatomic, strong) EaseKeyBoardView *my_keyboard;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation EaseCustomKeyBoardView

- (instancetype)init {
    
    if (self = [super init]) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(50, 168, kScreenWidth - 100, 50)];
        _textField.delegate = self;
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.placeholder = @"Enter gift amount";
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.layer.borderWidth = 1.0f;
        _textField.layer.borderColor = [UIColor yellowColor].CGColor;
        _textField.layer.cornerRadius = 8.0f;
        _textField.layer.masksToBounds = YES;
        [self addSubview:_textField];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self keyBoardTypeAction];
        [_textField becomeFirstResponder];
    }

    return self;
}

- (void)keyBoardTypeAction
{
    self.my_keyboard = [[EaseKeyBoardView alloc] initWithNumber:@1];
    self.textField.inputView = self.my_keyboard;
    self.my_keyboard.delegate = self;
    [self.textField reloadInputViews];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

// 因为是自定义view 系统的代理 shouldChangeCharactersInRange 不会调用。
- (void)numberKeyBoard:(NSInteger)number
{
    NSString *str = self.textField.text;
    if (str.length >= 3) {
        return;
    }
    //判断 0 输入
    if ([str isEqualToString:@"0"]) {
        self.textField.text = [NSString stringWithFormat:@"%ld",number];
        return;
    }
    self.textField.text = [NSString stringWithFormat:@"%@%ld",str,(long)number];
}

//删除数字
- (void)cancelKeyBoard
{
    NSMutableString *muStr = [[NSMutableString alloc] initWithString:self.textField.text];
    if (muStr.length <= 0) {
        return;
    }
    [muStr deleteCharactersInRange:NSMakeRange([muStr length] - 1, 1)];
    self.textField.text = muStr;
}


#pragma 输入点
-(void)periodKeyBoard{
    
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    
    //判断当前时候存在一个点
    if ([self.textField.text rangeOfString:@"."].location == NSNotFound) {
        //输入中没有点
        NSMutableString  *mutableString=[[NSMutableString alloc]initWithFormat:@"%@%@",self.textField.text,@"."];
        self.textField.text = mutableString;
    }
}

-(void)changeKeyBoard{
//    self.textField.inputView = nil;
//    [self.textField reloadInputViews];
     [self endEditing:YES];
}

-(void)finishKeyBoard{
    [self endEditing:YES];
    //非0&空输入判定
    if (!([self.textField.text isEqualToString:@"0"] || [self.textField.text isEqualToString:@""])) {
        if (self.customGiftNumDelegate && [self.customGiftNumDelegate respondsToSelector:@selector(customGiftNum:)]) {
            [self.customGiftNumDelegate customGiftNum:self.textField.text];
        }
    }
    self.textField.text = @"";
    [self removeFromParentView];
}

@end
