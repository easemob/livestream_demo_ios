//
//  EaseLoginViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "EaseLoginViewController.h"

#import "EaseSignUpViewController.h"
#import "EaseDefaultDataHelper.h"

#define kDefaultHeight 45.f
#define kDefaultTextHeight 50.f
#define kDefaultWidth (KScreenWidth - 75.f)

@interface EaseLoginViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIView *loginView;

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
    
    self.loginView = [[UIView alloc] initWithFrame:CGRectMake(0, 216.f, KScreenWidth, kDefaultTextHeight * 2 + 1.f)];
    self.loginView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.loginView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.loginView addSubview:self.usernameTextField];
    [self.loginView addSubview:self.passwordTextField];
    [self.view addSubview:self.loginButton];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:kLiveLastLoginUsername]) {
        self.usernameTextField.text = [ud objectForKey:kLiveLastLoginUsername];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.registerButton];
    self.navigationItem.leftBarButtonItem = nil;

    if (KScreenHeight <= 568.f) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITextField*)usernameTextField
{
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, 0, kDefaultWidth, kDefaultTextHeight)];
        _usernameTextField.delegate = self;
        _usernameTextField.placeholder = NSLocalizedString(@"login.textfield.username", @"Username");
        _usernameTextField.backgroundColor = [UIColor clearColor];
        _usernameTextField.returnKeyType = UIReturnKeyNext;
        _usernameTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_usernameTextField.frame), CGRectGetMaxY(_usernameTextField.frame) + 1.f, CGRectGetWidth(_usernameTextField.frame), 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [self.loginView addSubview:line];
        
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
        _passwordTextField.returnKeyType = UIReturnKeyGo;
        _passwordTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_passwordTextField.frame), CGRectGetMaxY(_passwordTextField.frame) + 1.f, CGRectGetWidth(_passwordTextField.frame), 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [self.loginView addSubview:line];
    }
    return _passwordTextField;
}

- (UIButton*)registerButton
{
    if (_registerButton == nil) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.frame = CGRectMake(0, 0, 64, 44.f);
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
        _loginButton.frame = CGRectMake((KScreenWidth - kDefaultWidth)/2, _loginView.bottom + 51.f, kDefaultWidth, kDefaultHeight);
        
        [_loginButton setTitle:NSLocalizedString(@"login.button.login", @"Log in") forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundColor:kDefaultLoginButtonColor];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.layer.cornerRadius = 4.f;
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
            [weakHud hideAnimated:YES];
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
    
    CGRect actionViewFrame = _loginView.frame;
    //键盘隐藏
    if (endRect.origin.y == KScreenHeight) {
        actionViewFrame = CGRectMake(0, 216.f, KScreenWidth, kDefaultHeight * 3 + 1.f);
    }
    //键盘显示
    else if(beginRect.origin.y == KScreenHeight){
        actionViewFrame.origin.y = 100.f;
    }
    //键盘告诉变化
    else{
        actionViewFrame.origin.y = 100.f;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _loginView.frame = actionViewFrame;
    }];
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
