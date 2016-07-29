//
//  EaseChatViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/7.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseChatViewController.h"

#import "EaseInputTextView.h"
#import "EaseChatToolbar.h"

@interface EaseSimpleChatToolbar : EaseChatToolbar

@end

@implementation EaseSimpleChatToolbar

- (void)reloadSubviews
{
    for (EaseChatToolbarItem *item in self.inputViewLeftItems) {
        [item.button removeFromSuperview];
    }
    
    for (EaseChatToolbarItem *item in self.inputViewRightItems) {
        [item.button removeFromSuperview];
    }
    
    self.inputTextView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.inputTextView.layer.cornerRadius = 0.f;
    self.inputTextView.layer.borderWidth = 0.f;
    [self layoutSubviews];
}

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    [self.inputTextView resignFirstResponder];
    return result;
}

@end

@interface EaseChatViewController () <EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource>

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) EaseSimpleChatToolbar *simpleChatToolbar;

@end

@implementation EaseChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.conversation.conversationId;
    
    self.dataSource = self;
    self.delegate = self;
    
    [self setChatToolbar:self.simpleChatToolbar];
    
    self.tableView.backgroundColor = RGBACOLOR(230, 230, 235, 1);
    
    if (!_isHideLeftBarItem) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    }
}

- (void)dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (EaseSimpleChatToolbar*)simpleChatToolbar
{
    if (_simpleChatToolbar == nil) {
        _simpleChatToolbar = [[EaseSimpleChatToolbar alloc] initWithFrame:CGRectMake(0, KScreenHeight - 54, KScreenWidth, 54) type:EMChatToolbarTypeChat];
        _simpleChatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_simpleChatToolbar reloadSubviews];
    }
    return _simpleChatToolbar;
}

- (UIButton*)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 44.f, 44.f);
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)backAction
{
    [self.chatToolbar endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
    EMMessage *message = [self.conversation latestMessage];
    if (message == nil) {
        [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId deleteMessages:NO];
    }
}

- (void)setViewHeight:(CGFloat)height
{
    self.view.height = height;
    self.tableView.height = height - 54;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
