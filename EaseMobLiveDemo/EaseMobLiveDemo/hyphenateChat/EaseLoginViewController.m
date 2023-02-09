//
//  EaseLoginViewController.m
//
//  Created by EaseMob on 16/5/9.
//  Copyright © 2016年 zilong.li All rights reserved.
//

#import "EaseLoginViewController.h"

#import "EaseDefaultDataHelper.h"
#import "EMUserAgreementView.h"
#import "EMProtocolViewController.h"

@interface RightView : UIView
@property (nonatomic, strong) UIButton *rightViewBtn;
@end

@implementation RightView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 46, 22);
        [self addSubview:self.rightViewBtn];
    }
    return self;
}

- (UIButton *)rightViewBtn
{
    if (_rightViewBtn == nil) {
        _rightViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightViewBtn.frame = CGRectMake(0, 0, 22, 22);
        UIImage* image = [UIImage imageNamed:@"x"];
        [_rightViewBtn setImage:image forState:UIControlStateNormal];
    }
    return _rightViewBtn;
}

@end

@interface EaseLoginViewController ()<UITextFieldDelegate,EMUserProtocol>

@property (strong, nonatomic) UILabel* titleLabel;
@property (strong, nonatomic) UITextField *phoneNumberTextField;
@property (strong, nonatomic) UITextField *smsCodeTextField;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton* smsButton;
@property (nonatomic, strong) EMUserAgreementView *userAgreementView;//用户协议
@property (nonatomic) NSInteger codeTs;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) CGFloat loadingAngle;
@property (nonatomic, strong) RightView* rightView;
@end

@implementation EaseLoginViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = NSLocalizedString(@"title.login", @"Log in");
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIApplication sharedApplication].delegate.window.backgroundColor;
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.phoneNumberTextField];
    [self.view addSubview:self.smsCodeTextField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.smsButton];
    [self.view addSubview:self.userAgreementView];
    [self.view addSubview:self.loadingImageView];
    [self layoutSubViews];
    [self.view bringSubviewToFront:self.smsButton];

    self.navigationItem.leftBarButtonItem = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubViews
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@30);
        make.right.equalTo(self.view).offset(-30);
        make.centerY.equalTo(self.view).multipliedBy(0.2);
        make.height.equalTo(@30);
    }];
    
    [self.phoneNumberTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@48);
    }];
    
    [self.smsCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneNumberTextField.mas_bottom).offset(20);
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@48);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smsCodeTextField.mas_bottom).offset(20);
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@48);
    }];
    
    [self.smsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.smsCodeTextField).offset(-20);
        make.height.equalTo(@30);
        make.centerY.equalTo(self.smsCodeTextField);
    }];
    
    [self.userAgreementView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginButton.mas_bottom).offset(20);
            make.left.right.equalTo(self.titleLabel);
            make.height.equalTo(@50);
    }];
    [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.loginButton);
    }];
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.54 alpha:1.0];
        _titleLabel.text = NSLocalizedString(@"login.title", nil);
        _titleLabel.font = [UIFont fontWithName:@"SFPro-Medium" size:24];
    }
    return _titleLabel;
}

- (UITextField*)phoneNumberTextField
{
    if (_phoneNumberTextField == nil) {
        _phoneNumberTextField = [[UITextField alloc] init];
        _phoneNumberTextField.delegate = self;
        _phoneNumberTextField.textColor = [UIColor whiteColor];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.36 green:0.36 blue:0.36 alpha:1.0];
        NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login.textfield.username", @"Username") attributes:dict];
        [_phoneNumberTextField setAttributedPlaceholder:attribute];
        _phoneNumberTextField.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        _phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumberTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        _phoneNumberTextField.font = [UIFont systemFontOfSize:15.f];
        _phoneNumberTextField.layer.borderWidth = 1;
        _phoneNumberTextField.layer.cornerRadius = 22;
        _phoneNumberTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
        _phoneNumberTextField.rightView = self.rightView;
        _phoneNumberTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _phoneNumberTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
    }
    return _phoneNumberTextField;
}

- (UITextField*)smsCodeTextField
{
    if (_smsCodeTextField == nil) {
        _smsCodeTextField = [[UITextField alloc] init];
        _smsCodeTextField.delegate = self;
        _smsCodeTextField.textColor = [UIColor whiteColor];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.36 green:0.36 blue:0.36 alpha:1.0];
        dict[NSFontAttributeName] = [UIFont fontWithName:@"PingFang SC" size:16];
        NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"login.textfield.password", @"Password") attributes:dict];
        [_smsCodeTextField setAttributedPlaceholder:attribute];
        _smsCodeTextField.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        _smsCodeTextField.font = [UIFont systemFontOfSize:15.f];
        _smsCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _smsCodeTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        _smsCodeTextField.layer.borderWidth = 1;
        _smsCodeTextField.layer.cornerRadius = 22;
        _smsCodeTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _smsCodeTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _smsCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _smsCodeTextField;
}

- (UIButton*)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_loginButton setTitle:NSLocalizedString(@"login.button.login", @"Log in") forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"loginbackview"] forState:UIControlStateNormal];
        [_loginButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Semibold" size:16.0]];
        [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.titleEdgeInsets = UIEdgeInsetsMake(-7, 0, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
    }
    return _loginButton;
}

- (UIButton *)smsButton
{
    if (_smsButton == nil) {
        _smsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_smsButton setTitle:NSLocalizedString(@"login.smsCode", "") forState:UIControlStateNormal];
        [_smsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_smsButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] forState:UIControlStateDisabled];
        [_smsButton.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size:14]];
        [_smsButton addTarget:self action:@selector(smsCodeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _smsButton;
}

- (EMUserAgreementView *)userAgreementView
{
    if (_userAgreementView == nil) {
        _userAgreementView = [[EMUserAgreementView alloc] initUserAgreement];
        _userAgreementView.delegate = self;
        [_userAgreementView.userAgreementBtn addTarget:self action:@selector(confirmProtocol) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userAgreementView;
}

- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        _loadingImageView.image = ImageWithName(@"loading");
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}

#pragma mark - EMUserProtocol

- (void)didTapUserProtocol:(NSString *)protocolUrl sign:(NSString *)sign
{
    EMProtocolViewController *protocolController = [[EMProtocolViewController alloc]initWithUrl:protocolUrl sign:sign];
    protocolController.modalPresentationStyle = 0;
    [self presentViewController:protocolController animated:YES completion:nil];
}

- (RightView *)rightView
{
    if (_rightView == nil) {
        _rightView = [[RightView alloc] init];
        [_rightView.rightViewBtn addTarget:self action:@selector(removePhoneTextInput) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}
#pragma mark - Action

- (void)removePhoneTextInput
{
    self.phoneNumberTextField.text = @"";
}

- (void)loginAction
{
    [self.view endEditing:YES];
    NSString *name = self.phoneNumberTextField.text;
    if (name.length <= 0) {
        [self showHint:NSLocalizedString(@"login.inputPhoneNumber", nil)];
        return;
    }
    NSString *pswd = self.smsCodeTextField.text;
    if (pswd.length <= 0) {
        [self showHint:NSLocalizedString(@"login.enterSmsCode", nil)];
        return;
    }
    if (!self.userAgreementView.userAgreementBtn.isSelected) {
        [self showHint:NSLocalizedString(@"login.confirmTerms", nil)];
        return;
    }
    
    
    self.loadingAngle = 0;
    [self updateLoginStateWithStart:YES];

    __weak typeof(self) weakself = self;
    void (^finishBlock) (NSString *aName, EMError *aError) = ^(NSString *aName, EMError *aError) {
        [weakself hideHud];
        
        if (!aError) {
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            [self updateLoginStateWithStart:NO];
            //发送自动登录状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ELDloginStateChange object:[NSNumber numberWithBool:YES]];
            
            return ;
        }
        
        NSString *errorDes = NSLocalizedString(@"loginFailPrompt", nil);
        switch (aError.code) {
            case EMErrorUserNotFound:
                errorDes = NSLocalizedString(@"userNotFount", nil);
                break;
            case EMErrorNetworkUnavailable:
                errorDes = NSLocalizedString(@"offlinePrompt", nil);
                break;
            case EMErrorServerNotReachable:
                errorDes = NSLocalizedString(@"notReachServer", nil);
                break;
            case EMErrorUserAuthenticationFailed:
                errorDes = NSLocalizedString(@"userIdOrPwdError", nil);
                break;
            case EMErrorUserLoginTooManyDevices:
                errorDes = NSLocalizedString(@"devicesExceedLimit", nil);
                break;
            case EMErrorUserLoginOnAnotherDevice:
                errorDes = NSLocalizedString(@"loginOnOtherDevice", nil);
                break;
                case EMErrorUserRemoved:
                errorDes = NSLocalizedString(@"userRemovedByServer", nil);
            break;
            default:
                break;
        }
        [self showHint:errorDes];
        [self updateLoginStateWithStart:NO];
    };
    
    [[EaseHttpManager sharedInstance] loginToAppServerWithPhone:[name lowercaseString] smsCode:pswd appkey:EMClient.sharedClient.options.appkey completion:^(NSString * _Nullable response) {
        if (response.length <= 0) {
            [self showHint: NSLocalizedString(@"offlinePrompt", nil)];
            [self updateLoginStateWithStart:NO];
            return;
        }
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSNumber* code = [dic objectForKey:@"code"];
        if (!code) {
            [self showHint: NSLocalizedString(@"offlinePrompt", nil)];
            [self updateLoginStateWithStart:NO];
            return;
        }
        if(code.intValue == 200) {
            NSString* token = [dic objectForKey:@"token"];
            NSString* userId = [dic objectForKey:@"chatUserName"];
            [[EMClient sharedClient] loginWithUsername:[userId lowercaseString] token:token completion:finishBlock];
        } else if(code.intValue == 400){
            NSString* errorInfo = [dic objectForKey:@"errorInfo"];
            if ([errorInfo isEqualToString:@"phone number illegal"]) {
                [self showHint: NSLocalizedString(@"login.wrongPhone", nil)];
                [self updateLoginStateWithStart:NO];
                return;
            }
            if ([errorInfo isEqualToString:@"SMS verification code error."]) {
                [self showHint: NSLocalizedString(@"login.wrongSmsCode", nil)];
                [self updateLoginStateWithStart:NO];
                return;
            }
            if ([errorInfo isEqualToString:@"Please send SMS to get mobile phone verification code."]) {
                [self showHint: NSLocalizedString(@"login.wrongSmsCode", nil)];
                [self updateLoginStateWithStart:NO];
                return;
            }
            [self showHint:errorInfo];
            [self updateLoginStateWithStart:NO];
        } else {
            [self showHint:response];
            [self updateLoginStateWithStart:NO];
        }
    }];
}

- (void)confirmProtocol
{
}

- (void)smsCodeAction
{
    [self.view endEditing:YES];
    NSString* phoneNumber = self.phoneNumberTextField.text;
    if(phoneNumber.length <= 0) {
        [self showHint:NSLocalizedString(@"login.inputPhoneNumber", nil)];
        return;
    }
    NSString *pattern = @"1\\d{10}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:phoneNumber options:0 range:NSMakeRange(0, phoneNumber.length)];
    if (!result || result.count == 0) {
        [self showHint: NSLocalizedString(@"login.wrongPhone", nil)];
        return;
    }

    [[EaseHttpManager sharedInstance] requestSMSWithPhone:phoneNumber completion:^(NSString * _Nonnull response) {
        if (response.length <= 0) {
            [self showHint: NSLocalizedString(@"offlinePrompt", nil)];
            return;
        }
        NSDictionary* body = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        if(body) {
            NSNumber* code = [body objectForKey:@"code"];
            if(code.intValue == 200) {
                [self updateMsgCodeTitle:60];
                [self showHint:NSLocalizedString(@"login.codeSent", nil)];
            } else if (code.intValue == 400) {
                NSString * errorInfo = [body objectForKey:@"errorInfo"];
                if ([errorInfo isEqualToString:@"Please wait a moment while trying to send."]) {
                    [self showHint:NSLocalizedString(@"login.wait", nil)];
                } else
                if ([errorInfo containsString:@"exceed the limit of"]) {
                    [self showHint:NSLocalizedString(@"login.smsCodeLimit", nil)];
                } else {
                    [self showHint: errorInfo];
                }
            } else {
                [self showHint: response];
            }
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _smsCodeTextField) {
        [self loginAction];
    } else if (textField == _phoneNumberTextField) {
        [_smsCodeTextField becomeFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

    if (textField == self.phoneNumberTextField) {
        if (textField.text.length <= 0) {
            self.rightView.hidden = YES;
        } else {
            self.rightView.hidden = NO;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.phoneNumberTextField) {
        self.phoneNumberTextField.rightView.hidden = NO;
        if ([self.phoneNumberTextField.text length] <= 1 && [string isEqualToString:@""])
            self.phoneNumberTextField.rightView.hidden = YES;
    }
    return YES;
}

- (void)updateMsgCodeTitle:(NSInteger)ts
{
    __weak typeof(self) weakself = self;
    self.codeTs = ts;
    if(self.codeTs > 0) {
        [self.smsButton setEnabled:NO];
        NSString* title = [NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"login.getAfter", nil),ts];
        self.smsButton.titleLabel.text = title;
        [self.smsButton setTitle:title forState:UIControlStateDisabled];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakself updateMsgCodeTitle:weakself.codeTs-1];
        });
    }else{
        [self.smsButton setEnabled:YES];
        [self.smsButton setTitle:NSLocalizedString(@"login.smsCode", nil) forState:UIControlStateNormal];
    }
}

- (void)showHint:(NSString *)hint
{
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:win animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.label.numberOfLines = 0;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.cornerRadius = 10;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2];
    hud.contentColor = [UIColor whiteColor];
    hud.margin = 15.f;
    CGPoint offset = hud.offset;
    offset.y = 200;
    hud.offset = offset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)startAnimation {
    if (self.loadingImageView.isHidden) {
        return;
    }
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.loadingAngle * (M_PI /180.0f));

    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.loadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        self.loadingAngle += 15;
        if (self.loadingAngle > 360) {
            self.loadingAngle -= 360;
        }
        [self startAnimation];
    }];
}

- (void)updateLoginStateWithStart:(BOOL)start{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (start) {
            [self.loginButton setTitle:@"" forState:UIControlStateNormal];
            self.loadingImageView.hidden = NO;
            [self startAnimation];
            
        } else {
            [self.loginButton setTitle:NSLocalizedString(@"login.button.login", nil) forState:UIControlStateNormal];
            self.loadingImageView.hidden = YES;
            [self.loadingImageView stopAnimating];
        }
    });
}

@end
