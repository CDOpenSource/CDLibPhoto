//
//  CDCameraViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/5/12.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDCameraViewController.h"
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface CDCameraViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation CDCameraViewController


#pragma mark -
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        if (iOS8_UP) {
            
            AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if ((authorizationStatus == AVAuthorizationStatusRestricted || authorizationStatus == AVAuthorizationStatusDenied) && iOS8_UP) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                [alertView show];
            } else {
                NSLog(@"设备相机访问权限已经获取");
            }
            
        } else {
            
            NSLog(@"设备系统小于ios8！");
            
        }
        
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.delegate = self;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (iOS8_UP) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
    } else {
        NSLog(@"设备不支持照相功能");
    }
}

#pragma mark - View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"Picking Media Info ----> %@",info);
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        // 获取拍照的图片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if ([self.cameraDelegate respondsToSelector:@selector(cameraViewController:didTakeImage:fromInfo:)]) {
            [self.cameraDelegate cameraViewController:self didTakeImage:image fromInfo:info];
        }
        
        // 存储图片到"相机胶卷"
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
}

// 成功保存图片到相册中, 必须调用此方法, 否则会报参数越界错误
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存失败--->%@",error);
    } else {
        NSLog(@"保存成功--->%@",contextInfo);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        NSLog(@"设置");
        if (iOS8_UP) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}




@end
