//
//  EaseSignUpViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/18.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSignUpViewController.h"

#define kDefaultHeight 54.f

@interface EaseSignUpViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *passwordConfirmTextField;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) UIView *registerView;

@end

@implementation EaseSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.signup", @"Sign up");
    
    [self setupForDismissKeyboard];
    
    _registerView = [[UIView alloc] initWithFrame:CGRectMake(0, 80.f, KScreenWidth, kDefaultHeight * 3 + 1.f)];
    _registerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_registerView];
    
    [self.registerView addSubview:self.usernameTextField];
    [self.registerView addSubview:self.passwordTextField];
    [self.registerView addSubview:self.passwordConfirmTextField];
    [self.view addSubview:self.registerButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (UIButton*)registerButton
{
    if (_registerButton == nil) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.frame = CGRectMake(0, _registerView.bottom + 80.f, KScreenWidth, kDefaultHeight);
        
        [_registerButton setTitle:NSLocalizedString(@"login.button.signup", @"Ok") forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:kDefaultSystemBgColor];
        [_registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UITextField*)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.f, 0.f, KScreenWidth - 60.f, kDefaultHeight)];
        _usernameTextField.delegate = self;
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        
        _usernameTextField.placeholder = NSLocalizedString(@"login.textfield.username", @"Username");
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_email"]];
        imageView.frame = CGRectMake(20, CGRectGetMinY(_usernameTextField.frame) + 12, 30.f, 30.f);
        [self.registerView addSubview:imageView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_usernameTextField.frame) - 1.f, KScreenWidth, 1)];
        line.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.registerView addSubview:line];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_usernameTextField.frame), KScreenWidth, 1)];
        line2.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.registerView addSubview:line2];
        
    }
    return _usernameTextField;
}

- (UITextField*)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.f, CGRectGetMaxY(_usernameTextField.frame) + 1.f, KScreenWidth - 60.f, kDefaultHeight)];
        _passwordTextField.delegate = self;
        _passwordTextField.placeholder = NSLocalizedString(@"login.textfield.password", @"Password");
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.returnKeyType = UIReturnKeyNext;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_password"]];
        imageView.frame = CGRectMake(20, CGRectGetMinY(_passwordTextField.frame) + 12, 30.f, 30.f);
        [self.registerView addSubview:imageView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_passwordTextField.frame), KScreenWidth, 1)];
        line.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.registerView addSubview:line];
    }
    return _passwordTextField;
}

- (UITextField*)passwordConfirmTextField
{
    if (_passwordConfirmTextField == nil) {
        _passwordConfirmTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.f, CGRectGetMaxY(_passwordTextField.frame) + 1.f, KScreenWidth - 60.f, kDefaultHeight)];
        _passwordConfirmTextField.delegate = self;
        _passwordConfirmTextField.placeholder = NSLocalizedString(@"login.textfield.confirm.password", @"Confirm password");
        _passwordConfirmTextField.secureTextEntry = YES;
        _passwordConfirmTextField.returnKeyType = UIReturnKeyGo;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_password"]];
        imageView.frame = CGRectMake(20, CGRectGetMinY(_passwordConfirmTextField.frame) + 12, 30.f, 30.f);
        [self.registerView addSubview:imageView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_passwordConfirmTextField.frame), KScreenWidth, 1)];
        line.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.registerView addSubview:line];
    }
    return _passwordConfirmTextField;
}

#pragma mark - action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerAction
{
    if (self.usernameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:NSLocalizedString(@"login.alert.username.empty", @"Username is empty") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.cancelButton.title", @"Ok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.passwordTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:NSLocalizedString(@"login.alert.password.empty", @"Password is empty") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.cancelButton.title", @"Ok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:NSLocalizedString(@"login.alert.password.error", @"Your confirmed password and new password do not match") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.cancelButton.title", @"Ok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
     MBProgressHUD *hud = [MBProgressHUD showMessag:NSLocalizedString(@"login.signuping", @"Sign up...") toView:nil];
     __weak MBProgressHUD *weakHud = hud;
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         EMError *error = [[EMClient sharedClient] registerWithUsername:_usernameTextField.text password:_passwordTextField.text];
         dispatch_async(dispatch_get_main_queue(), ^{
             NSString *alertTitle = NSLocalizedString(@"login.signup.succeed", @"Sign up succeed");
             [weakHud hide:YES];
             if (error) {
                 switch (error.code) {
                     case EMErrorServerNotReachable:
                         alertTitle = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed");
                         break;
                     case EMErrorUserAlreadyExist:
                         alertTitle = NSLocalizedString(@"login.signup.register.repeat", @"You registered user already exists");
                         break;
                     case EMErrorNetworkUnavailable:
                         alertTitle = NSLocalizedString(@"error.connectNetworkFail", @"No network connection");
                         break;
                     case EMErrorServerTimeout:
                         alertTitle = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out");
                         break;
                     default:
                         alertTitle = NSLocalizedString(@"login.signup.failed", @"Sign up failed");
                         break;
                 }
             }
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:alertTitle delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.cancelButton.title", @"Ok") otherButtonTitles:nil];
             [alert show];
         });
     });
}

#pragma mark - notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *beginValue = [userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect beginRect;
    [beginValue getValue:&beginRect];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect actionViewFrame = _registerView.frame;
    NSLog(@"%f",self.view.frame.size.height);
    //键盘隐藏
    if (endRect.origin.y == KScreenHeight) {
        actionViewFrame = CGRectMake(0, 80.f, KScreenWidth, kDefaultHeight * 3 + 1.f);
    }
    //键盘显示
    else if(beginRect.origin.y == KScreenHeight){
        actionViewFrame.origin.y = 20.f;
    }
    //键盘告诉变化
    else{
        actionViewFrame.origin.y = 20.f;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _registerView.frame = actionViewFrame;
    }];
}

#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _passwordConfirmTextField) {
        [self registerAction];
    } else if (textField == _usernameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [_passwordConfirmTextField becomeFirstResponder];
    }
    return YES;
}

@end
