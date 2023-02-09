//
//  ELDPreLivingViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDPreLivingViewController.h"
#import <CoreServices/CoreServices.h>
#import "ELDLivingCountdownView.h"
#import "ELDPublishLiveViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EaseUserInfoManagerHelper.h"

#define kMaxTitleLength 50
#define kCloseBgViewHeight 32.0f

@interface ELDPreLivingViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UITextViewDelegate>


@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *headerBgView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *closeBgView;

@property (nonatomic, strong) UIButton *changeAvatarButton;
@property (nonatomic, strong) UILabel *changeLabel;

@property (nonatomic, strong) UITextView *liveNameTextView;

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *editButton;


@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UILabel *flipHintLabel;
@property (nonatomic, strong) UIButton *goLiveButton;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) EaseLiveRoom *liveRoom;
@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) CGFloat loadingAngle;

@property (nonatomic, strong) ELDLivingCountdownView *livingCountDownView;


@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong)AVCaptureDevice *backDevice;
@property (nonatomic, strong)AVCaptureDevice *frontDevice;
@property (nonatomic, strong)AVCaptureDevice *imageDevice;


@end

@implementation ELDPreLivingViewController
#pragma mark life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeFromBackgroudNotification:) name:ELDPreViewActiveFromBackgroudNotification object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    [self.view addGestureRecognizer:tap];
    
    [self placeAndLayoutSubviews];
        
    [EaseUserInfoManagerHelper fetchOwnUserInfoCompletion:^(EMUserInfo * _Nonnull ownUserInfo) {
        if (ownUserInfo) {
            [self.changeAvatarButton sd_setImageWithURL:[NSURL URLWithString:ownUserInfo.avatarUrl] forState:UIControlStateNormal];
        }
    }];
    
    [self updateAccessCamera];
}

#pragma mark public method
- (void)updateAccessCamera {
    if ([self isCameraAvailable]) {
        [self checkAuthorizationToAccessCamera];
    }else {
        [self startBgCamera];
    }
}


- (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)checkAuthorizationToAccessCamera {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
     completionHandler:^(BOOL granted) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (granted) {
                 [self startBgCamera];
             } else {
                 self.cameraView.hidden = YES;
                 [self showAlertWithTitle:@"Allow Camera access in device settings" messsage:@"Need to allow camera access to Start the Live stream."];
             }
         });
     }];
}


- (void)showAlertWithTitle:(NSString *)title
                  messsage:(NSString *)messsage  {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messsage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Open setting" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
        
        }];

    }];

    [alertController addAction:okAction];

    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)endEdit {
    [self.liveNameTextView resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)placeAndLayoutSubviews {
        
    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.contentView];

    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}

#pragma mark private method
- (void)startAnimation {
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.loadingAngle * (M_PI /180.0f));

    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.loadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        self.loadingAngle += 15;
        [self startAnimation];
    }];
}

- (void)updateLoginStateWithStart:(BOOL)start{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (start) {
            [self.goLiveButton setTitle:@"" forState:UIControlStateNormal];
            self.loadingImageView.hidden = NO;
            [self startAnimation];
            
        }else {
            [self.goLiveButton setTitle:NSLocalizedString(@"pre.golive", nil) forState:UIControlStateNormal];
            self.loadingImageView.hidden = YES;
        }
    });
}


#pragma mark NSNotification
- (void)activeFromBackgroudNotification:(NSNotification *)notify {
    [self updateAccessCamera];
}

#pragma mark action
- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)changeAvatarAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"pre.changeCover", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.photo", nil) style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self camerAction];
    }];
    [cameraAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.albums", nil) style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photoAction];
    }];
    [albumAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"publish.cancel", nil) style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancelAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)photoAction {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePicker.editing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)camerAction {
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
}


- (void)editAction {
    [self.liveNameTextView becomeFirstResponder];
}

- (void)flipAction {
    if (self.imageDevice == self.backDevice) {
        self.imageDevice = self.frontDevice;
    }else {
        self.imageDevice = self.backDevice;
    }
    
}

- (void)goLiveAction {
    if (self.liveNameTextView.text.length == 0) {
        [self showHint:NSLocalizedString(@"live.roomName.empty", nil)];
        return;
    }
    
    self.liveRoom.title = self.liveNameTextView.text;
    
    [self createLiveRoom:self.liveRoom];
}

- (void)createLiveRoom:(EaseLiveRoom *)liveRoom {
    [self updateLoginStateWithStart:YES];

    ELD_WS
    [self createLiveRoom:liveRoom completion:^(EaseLiveRoom *liveRoom, BOOL success) {
        if (success) {
            weakSelf.liveRoom = liveRoom;
            [self modifyLiveRoomStatus:weakSelf.liveRoom completion:^(EaseLiveRoom *liveRoom, BOOL success) {
                [self updateLoginStateWithStart:NO];
                if (success) {
                    weakSelf.liveRoom = liveRoom;
                    [weakSelf showStartCountDownView];
                    [weakSelf showHint:NSLocalizedString(@"live.createSuccess", nil)];
                }else  {
                    [weakSelf showHint:NSLocalizedString(@"live.start.failed", nil)];
                }
            }];
        }else{
            [self updateLoginStateWithStart:NO];
            [weakSelf showHint:NSLocalizedString(@"live.start.failed", nil)];
        }
    }];
    
}

- (void)showStartCountDownView {
    self.contentView.hidden = YES;
    
    [self.view addSubview:self.livingCountDownView];
    [self.livingCountDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.livingCountDownView startCountDown];
}


#pragma mark - CreateRoom
-(void)uploadCoverImageView:(void(^)(BOOL success))completion{
    ELD_WS
    [EaseHttpManager.sharedInstance uploadFileWithData:_fileData completion:^(NSString *url, BOOL success) {
        if (success) {
            weakSelf.liveRoom.coverPictureUrl = url;
        }
        completion(success);
    }];
}



- (void)createLiveRoom:(EaseLiveRoom *)liveRoom completion:(void(^)(EaseLiveRoom *liveRoom,BOOL success))completion{

    [EaseHttpManager.sharedInstance createLiveRoomWithRoom:liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
        
        if (success) {
            _liveRoom = room;
        }
        
        completion(room,success);
    }];
}

- (void)modifyLiveRoomStatus:(EaseLiveRoom *)liveRoom completion:(void(^)(EaseLiveRoom *liveRoom,BOOL success))completion {
    
    [EaseHttpManager.sharedInstance modifyLiveroomStatusWithOngoing:liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
        completion(room,success);
    }];
    
}

#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    _fileData = UIImageJPEGRepresentation(editImage, 1.0);
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

    if (editImage) {
        [self uploadCoverImageView:^(BOOL success) {
            [self hideHud];
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.changeAvatarButton setImage:editImage forState:UIControlStateNormal];
                });
            }else{
                [self showHint:NSLocalizedString(@"live.setCover.failed", nil)];
            }
        }];
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    if (selectedRange && pos) {
        return;
    }
    NSInteger realLength = textView.text.length;
    if (realLength > kMaxTitleLength) {
        textView.text = [textView.text substringToIndex:kMaxTitleLength];
    }

    self.countLabel.text = [NSString stringWithFormat:@"%lu/%d",(unsigned long)textView.text.length,kMaxTitleLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"]){
        return NO;
    }
    return  YES;
}

#pragma mark gette and setter
- (UIView *)cameraView {
    if (_cameraView == nil) {
        _cameraView = [[UIView alloc] init];
        [_cameraView.layer addSublayer:self.previewLayer];
    }
    return _cameraView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _contentView.backgroundColor = UIColor.clearColor;
        
        [_contentView addSubview:self.closeBgView];
        [_contentView addSubview:self.closeButton];
        [_contentView addSubview:self.headerBgView];
        [_contentView addSubview:self.flipButton];
        [_contentView addSubview:self.flipHintLabel];
        [_contentView addSubview:self.goLiveButton];

        [self.closeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.closeButton);
            make.size.equalTo(@(kCloseBgViewHeight));
        }];

        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(40.0);
            make.right.equalTo(_contentView).offset(-kEaseLiveDemoPadding * 1.6);
            make.size.equalTo(@30.0);
        }];
        
        [self.headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.closeButton.mas_bottom).offset(kEaseLiveDemoPadding * 2.6);
            make.left.equalTo(_contentView).offset(kEaseLiveDemoPadding * 1.6);
            make.right.equalTo(_contentView).offset(-kEaseLiveDemoPadding * 1.6);
        }];
        
        
        [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.bottom.equalTo(self.flipHintLabel.mas_top).offset(-14.0);
        }];
        
        [self.flipHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.height.equalTo(@12.0);
            make.bottom.equalTo(self.goLiveButton.mas_top).offset(-26.0);
        }];

        [self.goLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@48.0);
            make.left.equalTo(_contentView).offset(kEaseLiveDemoPadding * 4.8);
            make.right.equalTo(_contentView).offset(-kEaseLiveDemoPadding * 4.8);
            make.bottom.equalTo(_contentView).offset(-62.0);
        }];
    }
    return _contentView;
}

- (UIView *)headerBgView {
    if (_headerBgView == nil) {
        _headerBgView = [[UIView alloc] init];
        [_headerBgView addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerBgView);
        }];
    }
    return _headerBgView;
}


- (UIView *)headerView {
    if (_headerView == nil) {

        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = UIColor.blackColor;
        _headerView.alpha = 0.7;
        _headerView.layer.cornerRadius = 8.0;
        
        [_headerView addSubview:self.changeAvatarButton];
        [_headerView addSubview:self.liveNameTextView];
        [_headerView addSubview:self.changeLabel];
        [_headerView addSubview:self.countLabel];
        [_headerView addSubview:self.editButton];

        [self.changeAvatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView).offset(8.0);
            make.left.equalTo(_headerView).offset(8.0);
            make.bottom.equalTo(_headerView).offset(-8.0);
            make.size.equalTo(@84.0);
        }];
        
        [self.changeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.changeAvatarButton);
            make.bottom.equalTo(self.changeAvatarButton).offset(-5.0);
        }];
        
        [self.liveNameTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.changeAvatarButton);
            make.left.equalTo(self.changeAvatarButton.mas_right).offset(12.0);
            make.right.equalTo(_headerView).offset(-12.0f);
            make.bottom.equalTo(self.editButton.mas_top);
        }];

        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.editButton);
            make.left.equalTo(self.liveNameTextView);
            make.width.equalTo(@(50.0));
        }];
            
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_headerView).offset(-kEaseLiveDemoPadding * 1.6);
            make.right.equalTo(_headerView).offset(-kEaseLiveDemoPadding * 1.6);
            make.size.equalTo(@16.0);
        }];
    
    }
    return _headerView;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.layer.cornerRadius = 35;
    }
    return _closeButton;
}

- (UIView *)closeBgView {
    if (_closeBgView == nil) {
        _closeBgView = [[UIView alloc] init];
        _closeBgView.backgroundColor = ELDBlackAlphaColor;
        _closeBgView.layer.cornerRadius = kCloseBgViewHeight * 0.5;
    }
    return _closeBgView;
}


- (UIButton *)changeAvatarButton
{
    if (_changeAvatarButton == nil) {
        _changeAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeAvatarButton addTarget:self action:@selector(changeAvatarAction) forControlEvents:UIControlEventTouchUpInside];
        _changeAvatarButton.layer.cornerRadius = 4.0f;
        [_changeAvatarButton setImage:ImageWithName(@"default_back_image") forState:UIControlStateNormal];
    }
    return _changeAvatarButton;
}

- (UILabel *)changeLabel {
    if (_changeLabel == nil) {
        _changeLabel = [[UILabel alloc] init];
        _changeLabel.font = NFont(12.0f);
        _changeLabel.textColor = [UIColor whiteColor];
        _changeLabel.textAlignment = NSTextAlignmentCenter;
        _changeLabel.text = NSLocalizedString(@"pre.change", nil);
    }
    return _changeLabel;
}

- (UILabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = NFont(14.0f);
        _countLabel.textColor = [UIColor lightGrayColor];
        _countLabel.textAlignment = NSTextAlignmentLeft;
        _countLabel.text = [NSString stringWithFormat:@"%lu/%d",(unsigned long)self.liveNameTextView.text.length,kMaxTitleLength];
    }
    return _countLabel;
}


- (UIButton *)editButton {
    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"Live_edit_name"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)flipButton
{
    if (_flipButton == nil) {
        _flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flipButton setImage:[UIImage imageNamed:@"camera_flip"] forState:UIControlStateNormal];
        [_flipButton addTarget:self action:@selector(flipAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flipButton;
}

- (UIButton *)goLiveButton
{
    if (_goLiveButton == nil) {
        _goLiveButton = [[UIButton alloc] init];
        [_goLiveButton addTarget:self action:@selector(goLiveAction) forControlEvents:UIControlEventTouchUpInside];
        _goLiveButton.titleLabel.font = Font(@"Roboto", 17.0f);
        [_goLiveButton setTitle:NSLocalizedString(@"pre.golive", nil) forState:UIControlStateNormal];
        [_goLiveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

        [_goLiveButton setBackgroundImage:ImageWithName(@"go_live_btn_bg") forState:UIControlStateNormal];
        
        [_goLiveButton addSubview:self.loadingImageView];
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_goLiveButton);
        }];

        
    }
    return _goLiveButton;
}


- (UITextView*)liveNameTextView
{
    if (_liveNameTextView == nil) {
        _liveNameTextView = [[UITextView alloc] init];
        _liveNameTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _liveNameTextView.scrollEnabled = YES;
        _liveNameTextView.returnKeyType = UIReturnKeySend;
        _liveNameTextView.enablesReturnKeyAutomatically = YES;
        _liveNameTextView.delegate = self;
        _liveNameTextView.text = NSLocalizedString(@"publish.welcome", nil);
        _liveNameTextView.font = NFont(16.0);
        _liveNameTextView.textColor = TextLabelWhiteColor;
        _liveNameTextView.backgroundColor = UIColor.clearColor;
    }
    return _liveNameTextView;
}


- (UILabel *)flipHintLabel {
    if (_flipHintLabel == nil) {
        _flipHintLabel = UILabel.new;
        _flipHintLabel.textColor = COLOR_HEX(0xFFFFFF);
        _flipHintLabel.font = NFont(10.0);
        _flipHintLabel.textAlignment = NSTextAlignmentCenter;
        _flipHintLabel.text = NSLocalizedString(@"pre.flip", nil);
    }
    return _flipHintLabel;
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


- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        _loadingImageView.image = ImageWithName(@"loading");
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}


- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]){
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        } else if ([_session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
            _session.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResize;
        _previewLayer.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    }
    return _previewLayer;
}

- (AVCaptureDevice *)backDevice {
    if (!_backDevice) {
        _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    return _backDevice;
}

- (AVCaptureDevice *)frontDevice {
    if (!_frontDevice) {
        _frontDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    }
    return _frontDevice;
}

- (void)setImageDevice:(AVCaptureDevice *)imageDevice {
    _imageDevice = imageDevice;
    
    [self.session beginConfiguration];
    for (AVCaptureDeviceInput *input in self.session.inputs) {
        if (input.device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera) {
            [self.session removeInput:input];
        }
    }
    NSError *error;
    AVCaptureDeviceInput *imageInput = [AVCaptureDeviceInput deviceInputWithDevice:_imageDevice error:&error];
    if (error) {
        NSLog(@"photoInput init error: %@", error);
    } else {//设置输入
        if ([self.session canAddInput:imageInput]) {
            [self.session addInput:imageInput];
        }
    }
    [self.session commitConfiguration];
}

- (void)startBgCamera {
      self.imageDevice = self.frontDevice;
    
      AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
      if ([self.session canAddOutput:photoOutput]) {
          [self.session addOutput:photoOutput];
      }
    
    [self.session startRunning];

}


- (ELDLivingCountdownView *)livingCountDownView {
    if (_livingCountDownView == nil) {
        _livingCountDownView = [[ELDLivingCountdownView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        _livingCountDownView.backgroundColor = UIColor.clearColor;
        
        ELD_WS
        _livingCountDownView.CountDownFinishBlock = ^{
            [weakSelf.livingCountDownView removeFromSuperview];
            [weakSelf.session stopRunning];

                        
            ELDPublishLiveViewController *livingVC = [[ELDPublishLiveViewController alloc] initWithLiveRoom:weakSelf.liveRoom];
            livingVC.modalPresentationStyle =  UIModalPresentationFullScreen;
            [weakSelf presentViewController:livingVC
                                   animated:YES
                                 completion:^{
            [livingVC setFinishBroadcastCompletion:^(BOOL isFinish) {
                    if (isFinish)
                        [weakSelf dismissViewControllerAnimated:false completion:nil];
            }];
            }];
        };
    }
    return _livingCountDownView;
}

- (NSData *)fileData {
    if (_fileData == nil) {
        _fileData = [NSData data];
    }
    return _fileData;
}


- (EaseLiveRoom *)liveRoom {
    if (_liveRoom == nil) {
        _liveRoom = [[EaseLiveRoom alloc] init];
        _liveRoom.title = self.liveNameTextView.text;
        _liveRoom.anchor = [EMClient sharedClient].currentUsername;
        _liveRoom.liveroomType = kLiveBoardCastingTypeAGORA_CDN_LIVE;
    }
    return _liveRoom;
}

@end

#undef kMaxTitleLength
#undef kCloseBgViewHeight
