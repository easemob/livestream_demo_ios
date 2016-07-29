//
//  EaseLoginViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "EaseLoginViewController.h"

#import "UIViewController+DismissKeyboard.h"
#import "EaseSignUpViewController.h"

#define kDefaultHeight 54.f

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.login", @"Log in");
    
    [self setupForDismissKeyboard];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 80.f, KScreenWidth, kDefaultHeight * 2 + 1.f)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:kLiveLastLoginUsername]) {
        self.usernameTextField.text = [ud objectForKey:kLiveLastLoginUsername];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.registerButton];
    self.navigationItem.leftBarButtonItem = nil;
}

- (UITextField*)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.f, 80.f, KScreenWidth - 60.f, kDefaultHeight)];
        _usernameTextField.delegate = self;
        _usernameTextField.placeholder = NSLocalizedString(@"login.textfield.username", @"Username");
        _usernameTextField.backgroundColor = [UIColor clearColor];
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_email"]];
        imageView.frame = CGRectMake(20, CGRectGetMinY(_usernameTextField.frame) + 12, 30.f, 30.f);
        [self.view addSubview:imageView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_usernameTextField.frame) - 1.f, KScreenWidth, 1)];
        line.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.view addSubview:line];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_usernameTextField.frame), KScreenWidth, 1)];
        line2.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.view addSubview:line2];
        
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
        _passwordTextField.returnKeyType = UIReturnKeyGo;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_password"]];
        imageView.frame = CGRectMake(20, CGRectGetMinY(_passwordTextField.frame) + 12, 30.f, 30.f);
        [self.view addSubview:imageView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_passwordTextField.frame), KScreenWidth, 1)];
        line.backgroundColor = RGBACOLOR(217, 217, 217, 1);
        [self.view addSubview:line];
    }
    return _passwordTextField;
}

- (UIButton*)registerButton
{
    if (_registerButton == nil) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.frame = CGRectMake(0, 0, 44.f, 44.f);
        [_registerButton setTitle:NSLocalizedString(@"login.item.signup", @"Sign up") forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UIButton*)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.frame = CGRectMake(0, CGRectGetMaxY(_passwordTextField.frame) + 80.f, KScreenWidth, kDefaultHeight);
        
        [_loginButton setTitle:NSLocalizedString(@"login.button.login", @"Log in") forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundColor:kDefaultSystemBgColor];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (void)registAction
{
    EaseSignUpViewController *signUpView = [[EaseSignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpView animated:YES];
}

- (void)loginAction
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
    
    [_passwordTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    MBProgressHUD *hud = [MBProgressHUD showMessag:NSLocalizedString(@"login.ing", @"Login...") toView:nil];
    __weak MBProgressHUD *weakHud = hud;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient] loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakHud hide:YES];
            if (!error) {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[EMClient sharedClient].currentUsername forKey:kLiveLastLoginUsername];
                [ud synchronize];
                [[EMClient sharedClient].options setIsAutoLogin:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginStateChange" object:@YES];
            } else {
                NSString *alertTitle = NSLocalizedString(@"login.failed", @"Login failed");
                switch (error.code)
                {
                    case EMErrorUserNotFound:
                        alertTitle = NSLocalizedString(@"error.user.notfound", @"User not exist");
                        break;
                    case EMErrorNetworkUnavailable:
                        alertTitle = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                        break;
                    case EMErrorServerNotReachable:
                        alertTitle = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                        break;
                    case EMErrorUserAuthenticationFailed:
                        alertTitle = NSLocalizedString(@"error.invalid.username.password", @"Invalid username or password");
                        break;
                    case EMErrorServerTimeout:
                        alertTitle = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                        break;
                    default:
                        alertTitle = NSLocalizedString(@"login.failed", @"Login failed");
                        break;
                }
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.tips", @"Tips") message:alertTitle delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"alert.cancelButton.title", @"Ok"), nil];
                [alert show];
            }
        });
    });
}

#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _passwordTextField) {
        [self loginAction];
    } else if (textField == _usernameTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    return YES;
}

@end
