//
//  CDCameraViewController.h
//  CDLibPhotos
//
//  Created by Cindy on 2017/5/12.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDCameraViewController;


@protocol CDCameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(CDCameraViewController *)cameraVC didTakeImage:(UIImage *)image fromInfo:(NSDictionary *)info;

@end

@interface CDCameraViewController : UIImagePickerController

@property (nonatomic,weak) id <CDCameraViewControllerDelegate> cameraDelegate;

@end
