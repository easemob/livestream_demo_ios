//
//  EaseCreateLiveViewController.m
//  EaseMobLiveDemo
//
//  Created by EaseMob on 17/2/27.
//  Copyright © 2017年 zmw. All rights reserved.
//

#import "EaseCreateLiveViewController.h"
#import "EasePublishViewController.h"
#import "UIViewController+DismissKeyboard.h"
#import "EaseLiveRoom.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kDefaultHeight 45.f
#define kDefaultTextHeight 50.f
#define kDefaultWidth (KScreenWidth - 75.f)

@interface EaseCreateLiveViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSString *_coverpictureurl;
    BOOL _isRelevance;
    NSMutableArray *_relevanceArray;
    EaseLiveRoom *_liveRoom;
}

@property (nonatomic, strong) UIButton *relevanceBtn;
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *coverLabel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UITextField *relevanceTextField;
@property (nonatomic, strong) UITextField *liveNameTextField;
@property (nonatomic, strong) UITextField *liveDescTextField;
@property (nonatomic, strong) UITextField *anchorDescTextField;

@property (nonatomic, strong) UIButton *createLiveBtn;
@property (nonatomic, strong) UIButton *showPickerBtn;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIPickerView *relevancePicker;

@property (nonatomic, strong) UIScrollView *mainView;

@end

@implementation EaseCreateLiveViewController

- (instancetype)initWithRelevance:(BOOL)isRelevance
{
    self = [super init];
    if (self) {
        _isRelevance = isRelevance;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"publish.title", @"Create Live");
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.view.backgroundColor = RGBACOLOR(251, 251, 251, 1);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.relevanceBtn];
    
    [self.view addSubview:self.mainView];
    [self.mainView addSubview:self.coverImageView];
    [self.coverImageView addSubview:self.coverLabel];
    if (_isRelevance) {
        self.title = NSLocalizedString(@"publish.relevance.title", @"Relevance Room");
        
        UIButton *backBtn = (UIButton*)[self.navigationItem.leftBarButtonItem customView];
        [backBtn setTitle:NSLocalizedString(@"publish.back", @"Back") forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = nil;
        [self.mainView addSubview:self.relevanceTextField];
        [self.mainView addSubview:self.showPickerBtn];
    }
    [self.mainView addSubview:self.liveNameTextField];
    [self.mainView addSubview:self.liveDescTextField];
//    [self.mainView addSubview:self.anchorDescTextField];
    [self.mainView addSubview:self.createLiveBtn];
    
    [self setupForDismissKeyboard];
    
    if (_isRelevance) {
        MBProgressHUD *hud = [MBProgressHUD showMessag:@"获取关联直播间" toView:self.view];
        __weak MBProgressHUD *weakHud = hud;
        [[EaseHttpManager sharedInstance] getLiveRoomListWithUsername:[EMClient sharedClient].currentUsername
                                                                 page:0
                                                             pagesize:100
                                                           completion:^(NSArray *roomList, BOOL success) {
                                                               if (success) {
                                                                   _relevanceArray = [NSMutableArray arrayWithArray:roomList];
                                                               } else {
                                                                   [weakHud setLabelText:@"获取失败"];
                                                               }
                                                               [weakHud hide:YES afterDelay:0.5];
                                                           }];
    }
    
    if (KScreenHeight <= 675.f) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (UIScrollView*)mainView
{
    if (_mainView == nil) {
        _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _mainView.backgroundColor = RGBACOLOR(251, 251, 251, 1);
    }
    return _mainView;
}

- (UIButton*)backBtn
{
    if (_backBtn == nil) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, 0, 70.f, 30.f);
        [_backBtn setTitle:NSLocalizedString(@"publish.home", @"Home") forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, -5, 0)];
        [_backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, -5, 0)];
        [_backBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton*)relevanceBtn
{
    if (_relevanceBtn == nil) {
        _relevanceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _relevanceBtn.frame = CGRectMake(0, 0, 85.f, 44.f);
        [_relevanceBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, -5, -30)];
        [_relevanceBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_relevanceBtn setTitle:NSLocalizedString(@"publish.relevance", @"Relevance") forState:UIControlStateNormal];
        [_relevanceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_relevanceBtn addTarget:self action:@selector(relevanceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _relevanceBtn;
}

- (UIImageView*)coverImageView
{
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((KScreenWidth-185)/2, 20, 185, 185)];
        _coverImageView.backgroundColor = [UIColor whiteColor];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoAction)];
        [_coverImageView addGestureRecognizer:tap];
    }
    return _coverImageView;
}

- (UILabel*)coverLabel
{
    if (_coverLabel == nil) {
        _coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (_coverImageView.height - 15)/2, _coverImageView.width, 15.f)];
        _coverLabel.textColor = RGBACOLOR(200, 200, 200, 1);
        _coverLabel.text = NSLocalizedString(@"publish.addcoverimage", @"Add a Cover Image");
        _coverLabel.font = [UIFont systemFontOfSize:15.f];
        _coverLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _coverLabel;
}

- (UITextField*)relevanceTextField
{
    if (_relevanceTextField == nil) {
        _relevanceTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_coverImageView.frame), kDefaultWidth, kDefaultTextHeight)];
        _relevanceTextField.delegate = self;
        _relevanceTextField.placeholder = NSLocalizedString(@"publish.liveroomid", @"Live Room ID");
        _relevanceTextField.backgroundColor = [UIColor clearColor];
        _relevanceTextField.returnKeyType = UIReturnKeyNext;
        _relevanceTextField.font = [UIFont systemFontOfSize:15.f];
        _relevanceTextField.enabled = NO;
        _relevanceTextField.userInteractionEnabled = YES;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _relevanceTextField.height - 1, _relevanceTextField.width, 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [_relevanceTextField addSubview:line];
    }
    return _relevanceTextField;
}

- (UIButton*)showPickerBtn
{
    if (_showPickerBtn == nil) {
        _showPickerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _showPickerBtn.frame = CGRectMake(CGRectGetMaxX(_relevanceTextField.frame) - 20.f, _relevanceTextField.top + (_relevanceTextField.height - 20.f)/2, 20.f, 20.f);
        [_showPickerBtn setImage:[UIImage imageNamed:@"open"] forState:UIControlStateNormal];
        [_showPickerBtn addTarget:self action:@selector(showPickerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showPickerBtn;
}

- (UITextField*)liveNameTextField
{
    if (_liveNameTextField == nil) {
        _liveNameTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_coverImageView.frame), kDefaultWidth, kDefaultTextHeight)];
        if (_isRelevance) {
            _liveNameTextField.top = CGRectGetMaxY(_relevanceTextField.frame);
            _liveNameTextField.hidden = YES;
        }
        _liveNameTextField.delegate = self;
        _liveNameTextField.placeholder = NSLocalizedString(@"publish.liveName", @"Live Name");
        _liveNameTextField.backgroundColor = [UIColor clearColor];
        _liveNameTextField.returnKeyType = UIReturnKeyNext;
        _liveNameTextField.font = [UIFont systemFontOfSize:15.f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _liveNameTextField.height - 1, _liveNameTextField.width, 1)];
        line.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        [_liveNameTextField addSubview:line];
        
    }
    return _liveNameTextField;
}

- (UITextField*)liveDescTextField
{
    if (_liveDescTextField == nil) {
        _liveDescTextField = [[UITextField alloc] initWithFrame:CGRectMake((KScreenWidth - kDefaultWidth)/2, CGRectGetMaxY(_liveNameTextField.frame), kDefaultWidth, kDefaultTextHeight)];
        if (_isRelevance) {
            _liveDescTextField.hidden = YES;
        }
        _liveDescTextField.delegate = self;
        _liveDescTextField.placeholder = NSLocalizedString(@"publish.liveDesc", @"Live Description");
        _liveDescTextField.backgroundColor = [UIColor clearColor];
        _liveDescTextField.returnKeyType = UIReturnKeyNext;
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
        if (_isRelevance) {
            _anchorDescTextField.hidden = YES;
        }
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

- (UIButton*)createLiveBtn
{
    if (_createLiveBtn == nil) {
        _createLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _createLiveBtn.frame = CGRectMake((KScreenWidth - kDefaultWidth)/2, _liveDescTextField.bottom + 51.f, kDefaultWidth, kDefaultHeight);
        [_createLiveBtn setTitle:NSLocalizedString(@"publish.button.live", @"Publish Live") forState:UIControlStateNormal];
        [_createLiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_createLiveBtn setBackgroundColor:kDefaultLoginButtonColor];
        _createLiveBtn.layer.cornerRadius = 4.f;
        
        if (_isRelevance) {
            [_createLiveBtn setBackgroundColor:RGBACOLOR(185, 185, 185, 1)];
            _createLiveBtn.enabled = NO;
            [_createLiveBtn addTarget:self action:@selector(modifyAction) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [_createLiveBtn addTarget:self action:@selector(createAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_mainView setContentSize:CGSizeMake(KScreenWidth, CGRectGetMaxY(_createLiveBtn.frame) + 75.f)];
    }
    return _createLiveBtn;
}

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

- (UIPickerView*)relevancePicker
{
    if (_relevancePicker == nil) {
        _relevancePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 264, KScreenWidth, 200)];
        _relevancePicker.delegate = self;
        _relevancePicker.dataSource = self;
        _relevancePicker.backgroundColor = [UIColor whiteColor];
    }
    return _relevancePicker;
}

- (UIView*)pickerView
{
    if (_pickerView == nil) {
        _pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, KScreenWidth - 100, 50)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"publish.liveroomid", @"Live Room ID");
        label.textColor = RGBACOLOR(76, 76, 76, 1);
        label.font = [UIFont systemFontOfSize:17.f];
        
        UIButton *canceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        canceBtn.frame = CGRectMake(10, 0, 60, 50);
        [canceBtn setTitle:NSLocalizedString(@"publish.cancel", @"Cancel") forState:UIControlStateNormal];
        [canceBtn setTitleColor:RGBACOLOR(76, 76, 76, 1) forState:UIControlStateNormal];
        [canceBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [canceBtn addTarget:self action:@selector(hidePickerAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveBtn.frame = CGRectMake(KScreenWidth - 60, 0, 50, 50);
        [saveBtn setTitle:NSLocalizedString(@"publish.save", @"Save") forState:UIControlStateNormal];
        [saveBtn setTitleColor:RGBACOLOR(25, 163, 255, 1) forState:UIControlStateNormal];
        [saveBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [saveBtn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 314, KScreenWidth, 50)];
        btnView.backgroundColor = [UIColor whiteColor];
        [btnView addSubview:canceBtn];
        [btnView addSubview:label];
        [btnView addSubview:saveBtn];
        
        UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btnView.frame) + 0.5, KScreenWidth, 0.5)];
        separateLine.backgroundColor = RGBACOLOR(220, 220, 220, 1);
        
        [_pickerView addSubview:btnView];
        [_pickerView addSubview:self.relevancePicker];
        [_pickerView addSubview:separateLine];
    }
    return _pickerView;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (editImage) {
        _coverLabel.hidden = YES;
        _coverImageView.image = editImage;
        NSData *fileData = UIImageJPEGRepresentation(editImage, 1.0);
        [[EaseHttpManager sharedInstance] uploadFileWithData:fileData
                                                  completion:^(NSString *url, BOOL success) {
                                                      if (success) {
                                                          _coverpictureurl = url;
                                                      }
                                                  }];
    } else {
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_relevanceArray count];
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0, 0, 0, 0);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    }
    if (component == 0) {
        pickerLabel.text =  [_relevanceArray objectAtIndex:row];
    }
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}


#pragma mark - action

- (void)photoAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.photo", @"Take photo") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
#if TARGET_OS_IPHONE
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            self.imagePicker.editing = YES;
            self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            [self presentViewController:self.imagePicker animated:YES completion:NULL];
        }
#endif
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.albums", @"Albums") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        self.imagePicker.editing = YES;
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.cancel", @"Cancel") style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
    }];
    
    [alertController addAction:albumAction];
    [alertController addAction:cameraAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)createAction
{
    EaseLiveRoom *liveRoom = [[EaseLiveRoom alloc] init];
    if (_liveNameTextField.text.length != 0) {
        liveRoom.title = _liveNameTextField.text;
    } else {
        return;
    }
    
    if (_liveDescTextField.text.length != 0) {
        liveRoom.desc = _liveDescTextField.text;
    } else {
        return;
    }
    
    if (_anchorDescTextField.text.length != 0) {
        liveRoom.custom = _anchorDescTextField.text;
    }
    
    liveRoom.session.anchor = [EMClient sharedClient].currentUsername;
    
    if (_coverpictureurl.length != 0){
        liveRoom.coverPictureUrl = _coverpictureurl;
    }
    
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"创建中..." toView:self.view];
    __weak MBProgressHUD *weakHud = hud;
    [[EaseHttpManager sharedInstance] createLiveRoomWithRoom:liveRoom
                                                  completion:^(EaseLiveRoom *room, BOOL success) {
                                                      [weakHud hide:YES];
                                                      if (success) {
                                                          EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:room];
                                                          [weakSelf presentViewController:publishView
                                                                                 animated:YES
                                                                               completion:^{
                                                              [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                                                                               }];
                                                      } else {
                                                          [self showHint:@"创建失败"];
                                                      }
                                                  }];
}

- (void)modifyAction
{
    if (_liveRoom == nil) {
        _liveRoom = [[EaseLiveRoom alloc] init];
    }
    
    if (_liveNameTextField.text.length != 0) {
        _liveRoom.title = _liveNameTextField.text;
    }
    
    if (_liveDescTextField.text.length != 0) {
        _liveRoom.desc = _liveDescTextField.text;
    }
    
    if (_anchorDescTextField.text.length != 0) {
        _liveRoom.custom = _anchorDescTextField.text;
    }
    
    if (_coverpictureurl.length != 0){
        _liveRoom.coverPictureUrl = _coverpictureurl;
    }
    
    BOOL ret = _liveRoom.session.anchor.length == 0 || ![_liveRoom.session.anchor isEqualToString:[EMClient sharedClient].currentUsername];
    if (ret) {
        [self showHint:@"请到后台设定此账户为直播间主播"];
        return;
    }
    
    if (_liveRoom.session.status == EaseLiveSessionUnknown) {
        [self showHint:@"直播状态未知,创建失败"];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"创建中..." toView:self.view];
    __weak MBProgressHUD *weakHud = hud;
    __weak typeof(self) weakSelf = self;
    dispatch_block_t modifyBlock = ^{
        [[EaseHttpManager sharedInstance] modifyLiveRoomWithRoom:_liveRoom
                                                      completion:^(EaseLiveRoom *room, BOOL success) {
                                                          [weakHud hide:YES];
                                                          if (success) {
                                                              EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:_liveRoom];
                                                              [weakSelf presentViewController:publishView animated:YES completion:^{
                                                                  [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                                                              }];
                                                          } else {
                                                              [weakSelf showHint:@"创建失败"];
                                                          }
                                                      }];
    };
    if (_liveRoom.session.status == EaseLiveSessionOngoing) {
        modifyBlock();
    } else if (_liveRoom.session.status == EaseLiveSessionNotStart) {
        [[EaseHttpManager sharedInstance] modifyLiveRoomStatusWithRoomId:_liveRoom.roomId
                                                                  status:EaseLiveSessionOngoing
                                                              completion:^(BOOL success) {
                                                                  if (success) {
                                                                      modifyBlock();
                                                                  } else {
                                                                      [weakHud hide:YES];
                                                                      [weakSelf showHint:@"创建失败"];
                                                                  }
                                                              }];
    } else {
        [[EaseHttpManager sharedInstance] createLiveSessionWithRoom:_liveRoom
                                                         completion:^(EaseLiveRoom *room, BOOL success) {
                                                             [weakHud hide:YES];
                                                             if (success) {
                                                                 modifyBlock();
                                                                 EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:room];
                                                                 [weakSelf presentViewController:publishView animated:YES completion:^{
                                                                     [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                                                                 }];
                                                             } else {
                                                                 [weakSelf showHint:@"创建失败"];
                                                             }
                                                         }];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)relevanceAction
{
    EaseCreateLiveViewController *relevanceLiveView = [[EaseCreateLiveViewController alloc] initWithRelevance:YES];
    [self.navigationController pushViewController:relevanceLiveView animated:YES];
}

- (void)showPickerAction
{
    [self.view addSubview:self.pickerView];
}

- (void)hidePickerAction
{
    [self.pickerView removeFromSuperview];
}

- (void)saveAction
{
    [self.pickerView removeFromSuperview];
    if ([_relevanceArray count] == 0) {
        return;
    }
    NSString *value = [_relevanceArray objectAtIndex:[_relevancePicker selectedRowInComponent:0]];
    if (value.length > 0) {
        _relevanceTextField.text = value;
        
        _liveDescTextField.hidden = NO;
        _liveNameTextField.hidden = NO;
        _anchorDescTextField.hidden = NO;
        
        [_createLiveBtn setBackgroundColor:kDefaultLoginButtonColor];
        _createLiveBtn.enabled = YES;
        
        dispatch_block_t block = ^{
            [[EaseHttpManager sharedInstance] getLiveRoomStatusWithRoomId:value
                                                               completion:^(EaseLiveSessionStatus status, BOOL success) {
                                                                   if (success) {
                                                                       if (_liveRoom == nil) {
                                                                           _liveRoom = [[EaseLiveRoom alloc] init];
                                                                       }
                                                                       _liveRoom.session.status = status;
                                                                   }
                                                               }];
        };
        
        __weak typeof(self) weakSelf = self;
        [[EaseHttpManager sharedInstance] getLiveRoomWithRoomId:value
                                                     completion:^(EaseLiveRoom *room, BOOL sucess) {
                                                         if (sucess) {
                                                             _liveRoom = room;
                                                             if (_liveRoom.title.length > 0) {
                                                                 weakSelf.liveNameTextField.text = _liveRoom.title;
                                                             } else {
                                                                 weakSelf.liveNameTextField.text = @"";
                                                             }
                                                             
                                                             if (_liveRoom.desc.length > 0) {
                                                                 weakSelf.liveDescTextField.text = _liveRoom.desc;
                                                             } else {
                                                                 weakSelf.liveDescTextField.text = @"";
                                                             }
                                                             
                                                             if (_liveRoom.custom.length > 0) {
                                                                 weakSelf.anchorDescTextField.text = _liveRoom.custom;
                                                             } else {
                                                                 weakSelf.anchorDescTextField.text = @"";
                                                             }
                                                             
                                                             if (_liveRoom.coverPictureUrl.length > 0) {
                                                                 [weakSelf.coverImageView sd_setImageWithURL:[NSURL URLWithString:_liveRoom.coverPictureUrl] placeholderImage:nil];
                                                                 _coverpictureurl = [_liveRoom.coverPictureUrl copy];
                                                                 _coverLabel.hidden = YES;
                                                             } else {
                                                                 weakSelf.coverImageView.image = nil;
                                                                 _coverpictureurl = nil;
                                                                 _coverLabel.hidden = NO;
                                                             }
                                                         } else {
                                                             weakSelf.liveNameTextField.text = @"";
                                                             weakSelf.liveDescTextField.text = @"";
                                                             weakSelf.anchorDescTextField.text = @"";
                                                             weakSelf.coverImageView.image = nil;
                                                             _coverpictureurl = nil;
                                                             _coverLabel.hidden = NO;
                                                         }
                                                         block();
                                                     }];
    }
}

#pragma mark - notification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *beginValue = [userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect beginRect;
    [beginValue getValue:&beginRect];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect actionViewFrame = _mainView.frame;
    CGPoint point = CGPointMake(0, 0);
    //键盘隐藏
    if (endRect.origin.y == KScreenHeight) {
        actionViewFrame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    }
    //键盘显示
    else if(beginRect.origin.y == KScreenHeight){
        actionViewFrame.origin.y = -150.f;
        point.y = _mainView.contentSize.height - _mainView.height;
    }
    //键盘告诉变化
    else{
        actionViewFrame.origin.y = -150.f;
        point.y = _mainView.contentSize.height - _mainView.height;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _mainView.frame = actionViewFrame;
        _mainView.contentOffset = point;
    }];
}

@end
