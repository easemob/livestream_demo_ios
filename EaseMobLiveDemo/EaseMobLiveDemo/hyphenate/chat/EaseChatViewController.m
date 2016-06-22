//
//  EaseChatViewController.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/7.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseChatViewController.h"

@interface EaseChatViewController () <EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource>

@end

@implementation EaseChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
    
    [self.chatBarMoreView removeItematIndex:4];
    [self.chatBarMoreView removeItematIndex:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
