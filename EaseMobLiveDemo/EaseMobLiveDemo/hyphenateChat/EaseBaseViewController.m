//
//  EaseBaseViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 16/7/20.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseBaseViewController.h"

@interface EaseBaseViewController ()

@end

@implementation EaseBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBACOLOR(230, 230, 235, 1);
    
    // Uncomment the following line to preserve selection between presentations.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
}

- (UIButton*)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 44.f, 44.f);
        [_backButton setImage:[UIImage imageNamed:@"icon-backAction"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)tapAction {

}


#pragma mark getter and setter
- (UILabel *)prompt {
    if (_prompt == nil) {
        _prompt = UILabel.new;
        _prompt.textColor = COLOR_HEX(0xFFFFFF);
        _prompt.font = Font(@"Roboto", 20.0);        
        _prompt.textAlignment = NSTextAlignmentLeft;
        _prompt.text = NSLocalizedString(@"main.title", nil);
    }
    return _prompt;
}

- (UIBarButtonItem*)searchBarItem
{
    if (_searchBarItem == nil) {
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(0, 0, 30.f, 30.f);
        [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setImageEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
        _searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    }
    return _searchBarItem;
}

- (void)searchAction {
    
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    }
    return _tapGestureRecognizer;
}

@end
