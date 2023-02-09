//
//  LXCalendarOneController.m
//  LXCalendar
//
//  Created by chenergou on 202117/11/3.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXCalendarOneController.h"
#import "LXCalender.h"
#import "LXCalendarCategoryHeader.h"

@interface LXCalendarOneController ()
@property(nonatomic,strong)LXCalendarView *calenderView;
@property(nonatomic,strong)LXCalendarDayModel *selectedModel;

@end

@implementation LXCalendarOneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor =[UIColor whiteColor];
    
    [self setupNavbar];
    
    self.calenderView =[[LXCalendarView alloc]initWithFrame:CGRectMake(20, 80, KScreenWidth - 40, 0)];
    
    self.calenderView.currentMonthTitleColor =[UIColor hexStringToColor:@"2c2c2c"];
    self.calenderView.lastMonthTitleColor =[UIColor hexStringToColor:@"8a8a8a"];
    self.calenderView.nextMonthTitleColor =[UIColor hexStringToColor:@"8a8a8a"];
    
    self.calenderView.isHaveAnimation = NO;
    
    self.calenderView.isCanScroll = YES;
    self.calenderView.isShowLastAndNextBtn = YES;
    
    self.calenderView.isShowLastAndNextDate = NO;

    self.calenderView.todayTitleColor =[UIColor redColor];
    
    self.calenderView.selectBackColor =[UIColor greenColor];
    
    [self.calenderView dealData];
    
    self.calenderView.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:self.calenderView];
    
    ELD_WS
    
    self.calenderView.selectBlock = ^(LXCalendarDayModel *selectedModel) {
        weakSelf.selectedModel = selectedModel;
        
        NSString *dateString = [NSString stringWithFormat:@"%@-%@-%@",[@(selectedModel.year) stringValue],[weakSelf convert2StringWithInt:selectedModel.month],[weakSelf convert2StringWithInt:selectedModel.day]];
        NSLog(@"====== dateString:%@",dateString);
        
        if (weakSelf.selectedBlock) {
            weakSelf.selectedBlock(dateString);
        }
        [weakSelf.calenderView updateCalendarWithSelectedModel:weakSelf.selectedModel];
    };
    
}

- (void)setupNavbar {
    [self.navigationController.navigationBar setBarTintColor:ViewControllerBgBlackColor];
    self.navigationItem.leftBarButtonItem = [ELDUtil customLeftButtonItem:NSLocalizedString(@"profile.edit", nil) action:@selector(backAction) actionTarget:self];
}

- (NSString *)convert2StringWithInt:(NSInteger)intValue {
    NSString *result = [@(intValue) stringValue];
    if (result.length == 1) {
        result = [NSString stringWithFormat:@"0%@",result];
    }
    return result;
}


@end
