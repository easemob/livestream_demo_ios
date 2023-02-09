//
//  MISMISDatePickerSheet.m
//  Eduapp
//
//  Created by maokebing on 12-8-16.
//  Copyright (c) 2012年 eduapp. All rights reserved.
//

#import "MISDatePickerSheet.h"

@interface MISDatePickerSheet()

@property(nonatomic, strong) UIDatePicker* datePicker;

@end

@implementation MISDatePickerSheet

-(instancetype)initWithDatePickerMode:(UIDatePickerMode)mode {
	self = [super initWithFrame:[UIScreen mainScreen].bounds];
	if (self) {
		self.datePicker.datePickerMode = mode;
		
		[self prepare];
	}
	return self;
}

#pragma mark - Pirvate Methods

- (void)prepare {
	self.backgroundColor = [UIColor clearColor];

	UIView* upBg = [[UIView alloc] init];
	upBg.backgroundColor = [UIColor clearColor];
	UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
	[upBg addGestureRecognizer:recognizer];
	
	UIView* downBg = [[UIView alloc] init];
	downBg.backgroundColor = [UIColor whiteColor];
	
	//toolsBar
	UIToolbar* toolBar = [[UIToolbar alloc] init];
	toolBar.barStyle = UIBarStyleDefault;
	UIBarButtonItem* fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem* fixItemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixItemSpace.width = 20.0f;
	
	UIBarButtonItem* confirmItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"publish.ok", nil) style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];
	NSArray* array = [NSArray arrayWithObjects:fixItem, confirmItem, fixItemSpace, nil];
	toolBar.items = array;
	
	//layout
    CGFloat bottomOffset = 0.0f;
    if (@available(iOS 11.0, *)) {
        bottomOffset = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
	CGFloat yPoint = CGRectGetHeight(self.bounds) - CGRectGetHeight(self.datePicker.bounds) - 44.0f - bottomOffset;
	upBg.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), yPoint);
	downBg.frame = CGRectMake(0, yPoint, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - yPoint);
	
	toolBar.frame = CGRectMake(0.0, yPoint, CGRectGetWidth(self.bounds), 44.0f);
	
	yPoint += 44.0f;
	self.datePicker.frame = CGRectMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.datePicker.bounds)) / 2.0f, yPoint, CGRectGetWidth(self.datePicker.bounds), CGRectGetHeight(self.datePicker.bounds));
	
	UIView* line = [[UIView alloc] init];
	CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
	line.backgroundColor = [UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0];
	line.frame = CGRectMake(0, yPoint, UIScreen.mainScreen.bounds.size.width, onePixel);
	
	[self addSubview:upBg];
	[self addSubview:downBg];
	[self addSubview:toolBar];
	[self addSubview:self.datePicker];
	[self addSubview:line];

}


#pragma mark -Getter & Setter

- (UIDatePicker *)datePicker {
	if (!_datePicker) {
		_datePicker = [[UIDatePicker alloc] init];
        _datePicker.locale = [NSLocale currentLocale];
        
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle =  UIDatePickerStyleWheels;
        } else {
            // Fallback on earlier versions
        }
        
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker setDate:[NSDate date] animated:YES];
        [_datePicker setMaximumDate:[NSDate date]];
        
        NSDate* minDate = [ELDUtil dateFromString:@"1900-01-01"];
        NSDate* maxDate = [ELDUtil dateFromString:@"2099-12-31"];

        _datePicker.minimumDate = minDate;
        _datePicker.maximumDate = maxDate;
    
	}
	return _datePicker;
}

- (void)setDate:(NSDate *)aDate {
	if (aDate) {
		self.datePicker.date = aDate;
	}
}

- (void)setMaxDate:(NSDate *)aMaxDate {
    self.datePicker.maximumDate = aMaxDate;
}

- (void)setMinDate:(NSDate *)aMinDate {
		self.datePicker.minimumDate = aMinDate;
}

- (NSDate *)date {
	return self.datePicker.date;
}

- (NSDate *)minDate {
	return self.datePicker.minimumDate;
}

- (NSDate *)maxDate {
	return self.datePicker.maximumDate;
}

#pragma mark - Event

- (void)confirm{
	NSDate* date = self.datePicker.date;
	if (self.dateBlock) {
		self.dateBlock(date);
	}

	//remove
	[self cancel];
}


- (void)cancel{
	[UIView animateWithDuration:0.20f animations:^{
		self.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[self removeFromSuperview];
	}];
}

#pragma mark - Public Mehods

- (void)show {
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	[window addSubview:self];
	
	self.alpha = 0.0f;
	[UIView animateWithDuration:0.20f animations:^{
		self.alpha = 1.0f;
	}];
}


@end
