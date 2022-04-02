//
//  EaseLiveCreateViewController.m
//  EaseMobLiveDemo
//
//  Created by easemob on 2021/11/23.
//  Copyright © 2021 zmw. All rights reserved.
//

#import "EaseLiveCreateViewController.h"
#import <CoreServices/CoreServices.h>
#import "EasePublishViewController.h"

@interface EaseLiveCreateViewController ()
<
    UITextFieldDelegate,
    UIActionSheetDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIPickerViewDelegate
>
{
    EaseLiveRoom *_liveRoom;
    NSData *_fileData;
    NSString *_coverpictureurl;
}
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITextField *liveNameTextField;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation EaseLiveCreateViewController
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
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:true];
}
#pragma mark - Getter
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
#pragma mark - Action
- (IBAction)coverPicker:(UITapGestureRecognizer *)sender {
    
}
- (IBAction)coverAction:(UIButton *)sender {
    UIAlertController *coverAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [coverAlert addAction:[UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self camerAction];
    }]];
    [coverAlert addAction:[UIAlertAction actionWithTitle:@"相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photoAction];
    }]];
    [coverAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:coverAlert animated:true completion:nil];
}
- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)createAction:(UIButton *)sender {
    if (_liveNameTextField.text.length == 0) {
        [self showHint:@"填入直播间名称"];
        return;
    }
    
    _fileData = UIImageJPEGRepresentation(_coverImageView.image, 1.0);
    if (!_fileData) {
        _fileData = [NSData new];
    }
    
    _liveRoom = [[EaseLiveRoom alloc] init];
    _liveRoom.title =_liveNameTextField.text;
    _liveRoom.anchor = [EMClient sharedClient].currentUsername;
    if (sender.tag == 100) {
        //传统
        _liveRoom.liveroomType = kLiveBroadCastingTypeLIVE;
    }else if (sender.tag == 200){
        //急速
        _liveRoom.liveroomType = kLiveBroadCastingTypeAGORA_SPEED_LIVE;
    }else if (sender.tag == 300){
        //互动
        _liveRoom.liveroomType = kLiveBroadCastingTypeAGORA_INTERACTION_LIVE;
    }
    
    MBProgressHUD *picHud = [MBProgressHUD showMessag:@"上传直播间封面..." toView:self.view];
    __weak MBProgressHUD *weaPicHud = picHud;
    __block typeof(_liveRoom) blockLiveRoom = _liveRoom;
    __weak typeof(self) weakSelf = self;
    [self uploadCoverImageView:^(BOOL success) {
        [weaPicHud hideAnimated:YES];
        if (success) {
            [weakSelf createLiveRoom:blockLiveRoom completion:^(EaseLiveRoom *liveRoom, BOOL success) {
                if (success) {
                    [self modifyLiveRoomStatus:blockLiveRoom completion:^(EaseLiveRoom *liveRoom, BOOL success) {
                        
                    }];
                }else{
                    [weakSelf showHint:@"开始直播失败"];
                }
            }];
        }else{
            [weaPicHud hideAnimated:YES];
            [self showHint:@"设置封面图失败"];
        }
    }];
    
}
#pragma mark - CreateRoom
-(void)uploadCoverImageView:(void(^)(BOOL success))completion{
    __block typeof(_liveRoom) blockLiveRoom = _liveRoom;
    [EaseHttpManager.sharedInstance uploadFileWithData:_fileData completion:^(NSString *url, BOOL success) {
        
        if (success) {
            blockLiveRoom.coverPictureUrl = url;
        }
        
        completion(success);
    }];
}
-(void)createLiveRoom:(EaseLiveRoom *)liveRoom completion:(void(^)(EaseLiveRoom *liveRoom,BOOL success))completion{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"开始直播..." toView:self.view];
    __weak MBProgressHUD *weakHud = hud;
    [EaseHttpManager.sharedInstance createLiveRoomWithRoom:liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
        [weakHud hideAnimated:YES];
        
        if (success) {
            _liveRoom = room;
        }
        
        completion(room,success);
    }];
}
-(void)modifyLiveRoomStatus:(EaseLiveRoom *)liveRoom completion:(void(^)(EaseLiveRoom *liveRoom,BOOL success))completion{
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在更新直播..." toView:self.view];
    __weak MBProgressHUD *weakHud = hud;
    __weak typeof(self) weakSelf = self;
    [EaseHttpManager.sharedInstance modifyLiveroomStatusWithOngoing:liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
        [weakHud hideAnimated:YES];
        EasePublishViewController *publishView = [[EasePublishViewController alloc] initWithLiveRoom:_liveRoom];
        publishView.modalPresentationStyle = 0;
        [weakSelf presentViewController:publishView
                               animated:YES
                             completion:^{
            [publishView setFinishBroadcastCompletion:^(BOOL isFinish) {
                if (isFinish)
                    [weakSelf dismissViewControllerAnimated:false completion:nil];
            }];
        }];
    }];
}
#pragma mark - UIImagePickerController
- (void)photoAction{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePicker.editing = YES;
    self.imagePicker.modalPresentationStyle = 0;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}
- (void)camerAction{
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (editImage) {
        _coverView.hidden = YES;
        _coverImageView.image = editImage;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TexfiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_liveNameTextField resignFirstResponder];
    return true;
}
@end
