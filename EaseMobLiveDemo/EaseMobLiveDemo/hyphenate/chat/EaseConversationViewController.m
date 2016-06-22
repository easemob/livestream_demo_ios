//
//  EaseConversationViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/4.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseConversationViewController.h"
#import "AppDelegate.h"
#import "EaseChatViewController.h"

@interface EaseConversationViewController () <EMChatManagerDelegate,EaseConversationListViewControllerDelegate,EaseConversationListViewControllerDataSource,EaseMessageViewControllerDataSource>

@end

@implementation EaseConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"私聊";
    self.delegate = self;
    self.dataSource = self;
    
    [self tableViewDidTriggerHeaderRefresh];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshAndSortView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - EaseConversationListViewControllerDelegate

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel
{
    if (conversationModel) {
        EMConversation *conversation = conversationModel.conversation;
        if (conversation) {
            EaseChatViewController *messageView = [[EaseChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
            [self.navigationController pushViewController:messageView animated:YES];
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (delegate.mainVC) {
                [delegate.mainVC setupUnreadMessageCount];
            }
            [self.tableView reloadData];
        }
    }
}

#pragma mark - EaseConversationListViewControllerDataSource
- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                                    modelForConversation:(EMConversation *)conversation
{
    EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
    if (model.conversation.type == EMConversationTypeChat) {
        return model;
    }
    return nil;
}

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages
{
    [self refreshAndSortView];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (delegate.mainVC) {
        [delegate.mainVC setupUnreadMessageCount];
    }
}

- (void)didUpdateConversationList:(NSArray *)aConversationList
{
    [self tableViewDidTriggerHeaderRefresh];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (delegate.mainVC) {
        [delegate.mainVC setupUnreadMessageCount];
    }
}

@end
