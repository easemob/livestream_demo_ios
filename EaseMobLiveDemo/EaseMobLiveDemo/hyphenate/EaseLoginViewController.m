//
//  EaseLoginViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "EaseLoginViewController.h"

#import "UIViewController+DismissKeyboard.h"

@interface EaseLoginViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation EaseLoginViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"登录环信";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    [self setupForDismissKeyboard];
    
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.registerButton];
    [self.view addSubview:self.loginButton];
}

- (UITextField*)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, CGRectGetWidth(self.view.bounds) - 40, 50)];
        _usernameTextField.delegate = self;
        _usernameTextField.placeholder = @"环信登录账号";
        _usernameTextField.layer.borderWidth = 1.f;
        _usernameTextField.layer.borderColor = [UIColor blackColor].CGColor;
        _usernameTextField.backgroundColor = [UIColor whiteColor];
        
    }
    return _usernameTextField;
}

- (UITextField*)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_usernameTextField.frame) +  20, CGRectGetWidth(self.view.bounds) - 40, 50)];
        _passwordTextField.delegate = self;
        _passwordTextField.placeholder = @"环信登录密码";
        _passwordTextField.layer.borderWidth = 1.f;
        _passwordTextField.layer.borderColor = [UIColor blackColor].CGColor;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.backgroundColor = [UIColor whiteColor];
    }
    return _passwordTextField;
}

- (UIButton*)registerButton
{
    if (_registerButton == nil) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.frame = CGRectMake(CGRectGetMinX(_usernameTextField.frame), KScreenHeight - 150, KScreenWidth - 40, 50.f);
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        _registerButton.layer.borderWidth = 1.f;
        _registerButton.layer.borderColor = [UIColor blackColor].CGColor;
        [_registerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UIButton*)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.frame = CGRectMake(CGRectGetMinX(_usernameTextField.frame), CGRectGetMaxY(_registerButton.frame) + 20, KScreenWidth - 40, 50.f);
        [_loginButton setTitle:@"登陆" forState:UIControlStateNormal];
        _loginButton.layer.borderWidth = 1.f;
        _loginButton.layer.borderColor = [UIColor blackColor].CGColor;
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundColor:[UIColor blackColor]];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (void)registAction
{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"注册中..." toView:nil];
    __weak MBProgressHUD *weakHud = hud;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] registerWithUsername:_usernameTextField.text password:_passwordTextField.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *alertTitle = @"注册成功";
            [weakHud hide:YES];
            if (error) {
                alertTitle = @"注册失败";
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:alertTitle delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alert show];
        });
    });
}

- (void)loginAction
{
    [_passwordTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"登陆中..." toView:nil];
    __weak MBProgressHUD *weakHud = hud;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakHud hide:YES];
            if (!error) {
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登陆失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            }
        });
    });
}

@end
