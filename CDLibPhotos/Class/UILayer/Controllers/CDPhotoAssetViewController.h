//
//  CDPhotoAssetViewController.h
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDPhotoAsset;

@interface CDPhotoAssetViewController : UIViewController

- (instancetype)initWithPhotoList:(NSArray <CDPhotoAsset *>*)photoList;

@end
