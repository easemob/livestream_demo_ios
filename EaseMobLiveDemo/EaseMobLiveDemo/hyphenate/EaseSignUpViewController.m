//
//  EaseSignUpViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/18.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSignUpViewController.h"

#define kDefaultHeight 45.f
#define kDefaultTextHeight 50.f
#define kDefaultWidth (KScreenWidth - 75.f)

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
    
    _registerView = [[UIView alloc] initWithFrame:CGRectMake(0, 157.f, KScreenWidth, kDefaultTextHeight * 3 + 1.f)];
    _registerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_registerView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.registerView addSubview:self.usernameTextField];
    [self.registerView addSubview:self.passwordTextField];
    [self.registerView addSubview:self.passwordConfirmTextField];
    [self.view addSubview:self.registerButton];
    
    if (KScreenHeight <= 568.f) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
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
        _registerButton.frame = CGRectMake((KScreenWidth - kDefaultWidth)/2, _registerView.bottom + 51.f, kDefaultWidth, kDefaultHeight);
        
        [_registerButton setTitle:NSLocalizedString(@"login.button.login", @"Log in") forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setBackgroundColor:kDefaultLoginButtonColor];
        [_registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
        _registerButton.layer.cornerRadius = 4.f;
    }
    return _registerButton;
}

- (UITextField*)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, 0.f, kDefaultWidth, kDefaultTextHeight)];
        _usernameTextField.delegate = self;
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        _usernameTextField.placeholder = NSLocalizedString(@"login.textfield.username", @"Username");
        _usernameTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_usernameTextField.frame), CGRectGetMaxY(_usernameTextField.frame) + 1.f, CGRectGetWidth(_usernameTextField.frame), 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [self.registerView addSubview:line];
        
    }
    return _usernameTextField;
}

- (UITextField*)passwordTextField
{
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_usernameTextField.frame) + 1.f, kDefaultWidth, kDefaultTextHeight)];
        _passwordTextField.delegate = self;
        _passwordTextField.placeholder = NSLocalizedString(@"login.textfield.password", @"Password");
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.returnKeyType = UIReturnKeyNext;
        _passwordTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_passwordTextField.frame), CGRectGetMaxY(_passwordTextField.frame) + 1.f, CGRectGetWidth(_passwordTextField.frame), 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [self.registerView addSubview:line];
    }
    return _passwordTextField;
}

- (UITextField*)passwordConfirmTextField
{
    if (_passwordConfirmTextField == nil) {
        _passwordConfirmTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_passwordTextField.frame) + 1.f, kDefaultWidth, kDefaultTextHeight)];
        _passwordConfirmTextField.delegate = self;
        _passwordConfirmTextField.placeholder = NSLocalizedString(@"login.textfield.confirm.password", @"Confirm password");
        _passwordConfirmTextField.secureTextEntry = YES;
        _passwordConfirmTextField.returnKeyType = UIReturnKeyGo;
        _passwordConfirmTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_passwordConfirmTextField.frame), CGRectGetMaxY(_passwordConfirmTextField.frame) + 1.f, CGRectGetWidth(_passwordConfirmTextField.frame), 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
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
    __weak typeof(self) weakSelf = self;
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
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:alertTitle delegate:nil cancelButtonTitle:NSLocalizedString(@"alert.cancelButton.title", @"Ok") otherButtonTitles:nil];
                 [alert show];
             } else {
                 EMError *error = [[EMClient sharedClient] loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
                 if (!error) {
                     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                     [ud setObject:[EMClient sharedClient].currentUsername forKey:kLiveLastLoginUsername];
                     [ud synchronize];
                     [[EMClient sharedClient].options setIsAutoLogin:YES];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@YES];
                 } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:NSLocalizedString(@"login.signup.succeed", @"Sign up succeed") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"alert.cancelButton.title", @"Ok"), nil];
                     [alert show];
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                 }
             }
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
        actionViewFrame = CGRectMake(0, 157.f, KScreenWidth, kDefaultHeight * 3 + 1.f);
    }
    //键盘显示
    else if(beginRect.origin.y == KScreenHeight){
        actionViewFrame.origin.y = 50.f;
    }
    //键盘告诉变化
    else{
        actionViewFrame.origin.y = 50.f;
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
