//
//  ACDContainerSearchTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ELDContainerTableViewController.h"
#import "MISScrollPage.h"

@interface ELDContainerTableViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@end

@implementation ELDContainerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    [self.table reloadData];
}


- (void)viewWillAppearForIndex:(NSUInteger)index{

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    self.editing = NO;
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    
}


- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = NSMutableArray.new;
    }
    return _dataArray;
}


@end
