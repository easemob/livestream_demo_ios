//
//  EaseSelectHeaderView.m
//  UCloudMediaRecorderDemo
//
//  Created by EaseMob on 16/6/6.
//  Copyright © 2016年 zmw. All rights reserved.
//

#import "EaseSelectHeaderView.h"

@interface  EaseSelectHeaderView ()

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIView *selectView;

@end

@implementation EaseSelectHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataArray = @[@"最新",@"热门",@"明星"];
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    CGFloat width = CGRectGetWidth(self.frame)/[_dataArray count];
    for (int i = 0; i < [_dataArray count]; i++) {
        UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tagBtn.frame = CGRectMake(i*width, 0, width, CGRectGetHeight(self.frame) - 5);
        [tagBtn setTitle:[_dataArray objectAtIndex:i] forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        tagBtn.tag = i;
        if (i == 0) {
            tagBtn.selected = YES;
            _selectBtn = tagBtn;
        }
        [tagBtn addTarget:self action:@selector(tagSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tagBtn];
    }
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(_selectBtn.center.x - 50/2, CGRectGetHeight(self.frame) - 4, 50, 2)];
    _selectView.backgroundColor = [UIColor blackColor];
    [self addSubview:_selectView];
}

- (void)tagSelectAction:(id)sender
{
    UIButton *tagBtn = (UIButton*)sender;
    if (_selectBtn.tag == tagBtn.tag) {
        return;
    }
    _selectBtn.selected = NO;
    _selectBtn = tagBtn;
    _selectBtn.selected = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _selectView.frame;
        frame.origin.x = _selectBtn.center.x - _selectView.frame.size.width/2;
        _selectView.frame = frame;
    }];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectButtonWithIndex:)]) {
        [_delegate didSelectButtonWithIndex:_selectBtn.tag];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
