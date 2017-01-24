//
//  CDBrowsePhotoViewController.h
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDBrowsePhotoViewController;
@class CDPhotoAsset;

@protocol CDBrowsePhotoViewControllerDelegate <NSObject>

@required
- (BOOL)browseController:(CDBrowsePhotoViewController *)browseController buttonSelectedClickedOnItemPhoto:(CDPhotoAsset *)photo;

@optional
- (BOOL)browseController:(CDBrowsePhotoViewController *)browseController shouldSelectedPhoto:(CDPhotoAsset *)photo;

@end

@interface CDBrowsePhotoViewController : UIViewController

@property (nonatomic,weak) id <CDBrowsePhotoViewControllerDelegate> delegate;

- (instancetype)initWithPhotoList:(NSArray <CDPhotoAsset *>*)photoList andDefaultStartPhoto:(CDPhotoAsset *)defaultPhoto;

@end
