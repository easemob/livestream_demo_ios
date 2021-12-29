//
//  EaseCreateLiveViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/27.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseCreateLiveViewController.h"
#import "EasePublishViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreServices/CoreServices.h>
#import "Masonry.h"
#import "EaseLiveroomCoverSettingView.h"
#import "EaseTextField.h"

#define kDefaultHeight 45.f
#define kDefaultTextHeight 50.f
#define kDefaultWidth (KScreenWidth - 75.f)

typedef enum : NSInteger{
    kLiveBroadCasting_Rapid = 0,//极速直播
    kLiveBroadCasting_Traditional//传统直播
}kLiveBroadCastingType;

@interface EaseCreateLiveViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate>
{
    NSString *_coverpictureurl;
    EaseLiveRoom *_liveRoom;
    NSData *_fileData;
}

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UITextField *liveNameTextField;
@property (nonatomic, strong) UITextField *liveDescTextField;
@property (nonatomic, strong) UITextField *anchorDescTextField;

@property (nonatomic, strong) UIButton *traditionalLiveBtn;
@property (nonatomic, strong) UILabel *traditionalLiveLabel;

@property (nonatomic, strong) UIButton *rapidlLiveBtn;
@property (nonatomic, strong) UILabel *rapidLiveLabel;
//@property (nonatomic, strong) CAGradientLayer *gl;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UIView *pickerView;

@property (nonatomic, strong) UIView *mainView;

@end

@implementation EaseCreateLiveViewController

- (instancetype)initWithLiveroom:(EaseLiveRoom *)liveroom
{
    self = [super init];
    if (self) {
        _liveRoom = liveroom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.title = NSLocalizedString(@"publish.title", @"Create Live");
    self.view.backgroundColor = [UIColor whiteColor];
    self.cancelBtn = [[UIButton alloc]init];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@40);
        make.top.equalTo(self.view).offset(EMVIEWTOPMARGIN + 35);
        make.right.equalTo(self.view).offset(-24);
    }];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.relevanceBtn];
    [self.view addSubview:self.mainView];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cancelBtn.mas_bottom).offset(24);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    UILabel *subjectLabel = [[UILabel alloc] init];
    subjectLabel.text = @"创建直播间";
    subjectLabel.textColor = [UIColor colorWithRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1.0];
    subjectLabel.font = [UIFont systemFontOfSize:18.f];
    [self.mainView addSubview:subjectLabel];
    [subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.mainView);
        make.height.equalTo(@25);
    }];
    
    [self.mainView addSubview:self.liveNameTextField];
    [self.liveNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subjectLabel.mas_bottom).offset(25);
        make.left.equalTo(self.mainView).offset(44);
        make.right.equalTo(self.mainView).offset(-44);
        make.height.equalTo(@44);
    }];
    
    [self.mainView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveNameTextField.mas_bottom).offset(15);
        make.left.equalTo(self.liveNameTextField);
        make.right.equalTo(self.liveNameTextField);
        make.height.equalTo(@(KScreenWidth - 88));
    }];
    
    [self.coverImageView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@100);
        make.left.right.equalTo(self.coverImageView);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.coverImageView);
    }];

    //[self.mainView addSubview:self.liveDescTextField];
    //[self.mainView addSubview:self.anchorDescTextField];
    [self.mainView addSubview:self.traditionalLiveBtn];
    [self.traditionalLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.mas_bottom).offset(55);
        make.left.equalTo(self.liveNameTextField);
        make.right.equalTo(self.liveNameTextField);
        make.height.equalTo(@44);
    }];
    
    [self.mainView addSubview:self.traditionalLiveLabel];
    [self.traditionalLiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.traditionalLiveBtn);
        make.centerX.equalTo(self.traditionalLiveBtn);
        make.width.equalTo(@85);
        make.height.equalTo(@25);
    }];
    
    [self.mainView addSubview:self.rapidlLiveBtn];
    [self.rapidlLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.traditionalLiveBtn.mas_bottom).offset(21);
        make.left.equalTo(self.liveNameTextField);
        make.right.equalTo(self.liveNameTextField);
        make.height.equalTo(@44);
    }];
    
    [self.mainView addSubview:self.rapidLiveLabel];
    [self.rapidLiveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rapidlLiveBtn);
        make.centerX.equalTo(self.rapidlLiveBtn);
        make.width.equalTo(@85);
        make.height.equalTo(@25);
    }];
}
/*
- (void)viewDidAppear:(BOOL)animated
{
    [_traditionalLiveBtn.layer addSublayer:self.gl];
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - getter
- (UIView*)mainView
{
    if (_mainView == nil) {
        _mainView = [[UIView alloc] init];
        _mainView.backgroundColor = [UIColor whiteColor];
    }
    return _mainView;
}

- (UIButton*)backBtn
{
    if (_backBtn == nil) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, 0, 70.f, 30.f);
        //[_backBtn setTitle:NSLocalizedString(@"publish.home", @"Home") forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, -5, 0)];
        [_backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, -5, 0)];
        [_backBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"icon-backAction"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIImageView*)coverImageView
{
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.16];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.masksToBounds = YES;
        _coverImageView.layer.cornerRadius = 22;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverPicker)];
        [_coverImageView addGestureRecognizer:tap];
    }
    return _coverImageView;
}

- (UIView*)coverView
{
    if (_coverView == nil) {
        _coverView = [[UIView alloc]init];
        UIImageView *coverImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"coverImage"]];
        [_coverView addSubview:coverImageView];
        [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@70);
            make.top.equalTo(_coverView);
            make.centerX.equalTo(_coverView);
        }];
        UILabel *coverLabel = [[UILabel alloc]init];
        coverLabel.textColor = [UIColor whiteColor];
        coverLabel.text = @"设置一个吸引人的封面";
        coverLabel.font = [UIFont systemFontOfSize:16.f];
        coverLabel.textAlignment = NSTextAlignmentCenter;
        [_coverView addSubview:coverLabel];
        [coverLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(coverImageView.mas_bottom).offset(10);
            make.left.right.equalTo(_coverView);
        }];
    }
    return _coverView;
}

- (UITextField*)liveNameTextField
{
    if (_liveNameTextField == nil) {
        _liveNameTextField = [[EaseTextField alloc] init];
        _liveNameTextField.delegate = self;
        _liveNameTextField.placeholder = @"请输入直播间名称";
        _liveNameTextField.tintColor = [UIColor blackColor];
        _liveNameTextField.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        _liveNameTextField.returnKeyType = UIReturnKeyDone;
        _liveNameTextField.font = [UIFont systemFontOfSize:15.f];
        _liveNameTextField.layer.cornerRadius = 22;
    }
    return _liveNameTextField;
}

- (UITextField*)liveDescTextField
{
    if (_liveDescTextField == nil) {
        _liveDescTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_liveNameTextField.frame), kDefaultWidth, kDefaultTextHeight)];
        _liveDescTextField.delegate = self;
        _liveDescTextField.placeholder = NSLocalizedString(@"publish.liveDesc", @"Live Description");
        _liveDescTextField.backgroundColor = [UIColor clearColor];
        _liveDescTextField.returnKeyType = UIReturnKeyDone;
        _liveDescTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _liveDescTextField.height - 1, _liveDescTextField.width, 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [_liveDescTextField addSubview:line];
        
    }
    return _liveDescTextField;
}

- (UITextField*)anchorDescTextField
{
    if (_anchorDescTextField == nil) {
        _anchorDescTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_liveDescTextField.frame), kDefaultWidth, kDefaultTextHeight)];
        _anchorDescTextField.delegate = self;
        _anchorDescTextField.placeholder = NSLocalizedString(@"publish.introduceSelf", @"Self-introduction");
        _anchorDescTextField.backgroundColor = [UIColor clearColor];
        _anchorDescTextField.returnKeyType = UIReturnKeyNext;
        _anchorDescTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _anchorDescTextField.height - 1, _anchorDescTextField.width, 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [_anchorDescTextField addSubview:line];
    }
    return _anchorDescTextField;
}

- (UIButton*)traditionalLiveBtn
{
    if (_traditionalLiveBtn == nil) {
        _traditionalLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _traditionalLiveBtn.layer.cornerRadius = 23.5f;
        [_traditionalLiveBtn setBackgroundImage:[UIImage imageNamed:@"createBtnBackImg"] forState:UIControlStateNormal];
        _traditionalLiveBtn.tag = kLiveBroadCasting_Traditional; //传统直播
        [_traditionalLiveBtn addTarget:self action:@selector(createAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _traditionalLiveBtn;
}

- (UIButton*)rapidlLiveBtn
{
    if (_rapidlLiveBtn == nil) {
        _rapidlLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rapidlLiveBtn.layer.cornerRadius = 23.5f;
        [_rapidlLiveBtn setBackgroundImage:[UIImage imageNamed:@"createBtnBackImg"] forState:UIControlStateNormal];
        _rapidlLiveBtn.tag = kLiveBroadCasting_Rapid; //极速直播
        [_rapidlLiveBtn addTarget:self action:@selector(createAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rapidlLiveBtn;
}

- (UILabel *)traditionalLiveLabel
{
    if (_traditionalLiveLabel == nil) {
        _traditionalLiveLabel = [[UILabel alloc] init];
        _traditionalLiveLabel.numberOfLines = 0;
        _traditionalLiveLabel.font = [UIFont systemFontOfSize:18];
        _traditionalLiveLabel.text = @"传统直播";
        [_traditionalLiveLabel setTextColor:[UIColor whiteColor]];
        _traditionalLiveLabel.textAlignment = NSTextAlignmentCenter;
    }
    return  _traditionalLiveLabel;
}

- (UILabel *)rapidLiveLabel
{
    if (_rapidLiveLabel == nil) {
        _rapidLiveLabel = [[UILabel alloc] init];
        _rapidLiveLabel.numberOfLines = 0;
        _rapidLiveLabel.font = [UIFont systemFontOfSize:18];
        _rapidLiveLabel.text = @"极速直播";
        [_rapidLiveLabel setTextColor:[UIColor whiteColor]];
        _rapidLiveLabel.textAlignment = NSTextAlignmentCenter;
    }
    return  _rapidLiveLabel;
}

/*
- (CAGradientLayer *)gl{
    if(_gl == nil){
        _gl = [CAGradientLayer layer];
        _gl.frame = CGRectMake(0,0,_traditionalLiveBtn.frame.size.width,44);
        _gl.startPoint = CGPointMake(0.76, 0.84);
        _gl.endPoint = CGPointMake(0.26, 0.14);
        _gl.colors = @[(__bridge id)[UIColor colorWithRed:90/255.0 green:93/255.0 blue:208/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:4/255.0 green:174/255.0 blue:240/255.0 alpha:1.0].CGColor];
        _gl.locations = @[@(0), @(1.0f)];
        _gl.cornerRadius = 22;
    }
    
    return _gl;
}*/

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (editImage) {
        _coverView.hidden = YES;
        _coverImageView.image = editImage;
        _fileData = UIImageJPEGRepresentation(editImage, 1.0);
        /*
        [[EaseHttpManager sharedInstance] uploadFileWithData:fileData
                                                  completion:^(NSString *url, BOOL success) {
                                                      if (success) {
                                                          [self showHint:@"设置封面图完成"];
                                                          _coverpictureurl = url;
                                                      } else {
                                                          [self showHint:@"设置封面图失败"];
                                                      }
                                                  }];*/
    } else {
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - action

- (void)coverPicker
{
    EaseLiveroomCoverSettingView *coverView = [[EaseLiveroomCoverSettingView alloc]init];
    [coverView setDoneCompletion:^(NSUInteger type) {
        if (type == 0) {
            [self camerAction];
        } else if (type == 1) {
            [self photoAction];
        }
    }];
    [coverView showFromParentView:self.view];
}

- (void)photoAction
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePicker.editing = YES;
    self.imagePicker.modalPresentationStyle = 0;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)camerAction
{
#if TARGET_OS_IPHONE
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        self.imagePicker.editing = YES;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        self.imagePicker.modalPresentationStyle = 0;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
#endif
}

- (void)createAction:(UIButton *)btn
{
    if (_liveNameTextField.text.length == 0) {
        [self showHint:@"填入房间名"];
        return;
    }
    if (!_fileData) {
        _fileData = [NSData new];
    }
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *picHud = [MBProgressHUD showMessag:@"上传直播间封面..." toView:self.view];
    __weak MBProgressHUD *weaPicHud = picHud;
    [[EaseHttpManager sharedInstance] uploadFileWithData:_fileData completion:^(NSString *url, BOOL success) {
        [weaPicHud hideAnimated:YES];
        if (success) {
            _coverpictureurl = url;
            _liveRoom = [[EaseLiveRoom alloc] init];
            _liveRoom.title = _liveNameTextField.text;
            if (_liveDescTextField.text.length != 0) {
                _liveRoom.desc = _liveDescTextField.text;
            }
            _liveRoom.coverPictureUrl = _coverpictureurl;
            _liveRoom.anchor = [EMClient sharedClient].currentUsername;
            if (btn.tag == kLiveBroadCasting_Rapid)
                _liveRoom.liveroomType = kLiveBroadCastingTypeAGORA_SPEED_LIVE;
            if (btn.tag == kLiveBroadCasting_Traditional)
                _liveRoom.liveroomType = kLiveBroadCastingTypeLIVE;
            MBProgressHUD *hud = [MBProgressHUD showMessag:@"开始直播..." toView:self.view];
            __weak MBProgressHUD *weakHud = hud;
            [[EaseHttpManager sharedInstance] createLiveRoomWithRoom:_liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
                [weakHud hideAnimated:YES];
                if (success) {
                    _liveRoom = room;
                    [[EaseHttpManager sharedInstance] modifyLiveroomStatusWithOngoing:_liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
                        EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:_liveRoom];
                        publishView.modalPresentationStyle = 0;
                        [weakSelf presentViewController:publishView
                                               animated:YES
                                             completion:^{
                            [publishView setFinishBroadcastCompletion:^(BOOL isFinish) {
                                if (isFinish)
                                    [weakSelf dismissViewControllerAnimated:NO completion:nil];
                            }];
                        }];
                    }];
                } else {
                    [weakSelf showHint:@"开始直播失败"];
                }
            }];
            [EaseHttpManager sharedInstance];
        } else {
            [weaPicHud hideAnimated:YES];
            [self showHint:@"设置封面图失败"];
            return;
        }
    }];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - notification

- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield {
     [aTextfield resignFirstResponder];//关闭键盘
    return YES;
}
@end
