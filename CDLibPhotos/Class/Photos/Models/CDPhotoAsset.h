//
//  CDPhotoAsset.h
//  PhotoLibrary
//
//  Created by Cindy on 2017/1/18.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class PHAsset;
@class PHAssetCollection;



@interface CDGroupAsset : NSObject
@property (nonatomic,strong) PHAssetCollection *phCollection;
@property (nonatomic,assign) NSInteger photoCounts;
@property (nonatomic,retain) NSString *collectionName;
@property (nonatomic,retain) NSString *localIdentifier;


- (void)getCoverImageComplete:(void(^)(UIImage *image))complete;

@end





#pragma mark - PHAsset
typedef enum : NSUInteger {
    ThumbnailImageType = 0,
    FullImageType = 1,
} CretaeImageType;

// 相册资源类型
typedef enum : NSUInteger {
    AssetMediaTypeUnknown = 0,
    AssetMediaTypeImage   = 1,
    AssetMediaTypeVideo   = 2,
    AssetMediaTypeAudio   = 3,
} CDMediaType;

@interface CDPhotoAsset : NSObject

@property (nonatomic,strong) PHAsset *phAsset;
@property (nonatomic,retain) NSString *assetName;
@property (nonatomic,assign) CDMediaType assetType;
@property (nonatomic,retain) NSString *localIdentifier;



- (void)getImageType:(CretaeImageType)imageType Complete:(void(^)(CretaeImageType type, UIImage *image))complete;

@end
