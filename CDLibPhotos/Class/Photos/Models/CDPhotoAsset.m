//
//  CDPhotoAsset.m
//  PhotoLibrary
//
//  Created by Cindy on 2017/1/18.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDPhotoAsset.h"
#import "CDPhotoManager.h"



#pragma mark - ——————【CDPhotoAsset】——————

@interface CDPhotoAsset ()
@property (nonatomic,strong) UIImage *thumbnailImage;
@property (nonatomic,strong) UIImage *fullImage;
@end

@implementation CDPhotoAsset
#pragma mark - Public Method
- (void)getImageType:(CretaeImageType)imageType Complete:(void(^)(CretaeImageType type, UIImage *image))complete
{
    CGFloat imageSize;
    UIScreen *screen = [UIScreen mainScreen];
    if (imageType == FullImageType) {
        if ([_fullImage isKindOfClass:[UIImage class]]) {
            complete(imageType,_fullImage);
            return;
        } else {
            imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.0;
        }
    } else if (imageType == ThumbnailImageType) {
        if ([_thumbnailImage isKindOfClass:[UIImage class]]) {
            complete(imageType,_thumbnailImage);
            return;
        } else{
            imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 0.2;
        }
    }
    
    // 开始生成图片
    CGSize imageTargetSize = CGSizeMake(imageSize * screen.scale, imageSize * screen.scale);
    [CDPhotoManager getImageWithAsset:self.phAsset byTargetSize:imageTargetSize completeNotify:^(UIImage *image, NSDictionary *info) {
        if (imageType == FullImageType) {
            _fullImage = image;
            complete(imageType,_fullImage);
        } else if (imageType == ThumbnailImageType) {
            CGFloat fitWidth = image.size.width > image.size.height ? image.size.height : image.size.width;
            CGSize resize = CGSizeMake(fitWidth, fitWidth);
            _thumbnailImage = [CDPhotoManager resizeImage:image size:resize];
            complete(imageType,_thumbnailImage);
        }
    }];
    
}

#pragma mark - Setter Method
- (void)setPhAsset:(PHAsset *)phAsset
{
    _phAsset = phAsset;
    
    _thumbnailImage = nil;
    _fullImage = nil;
}

@end







#pragma mark - ——————【CDGroupAsset】——————
@interface CDGroupAsset ()
@property (nonatomic,strong) UIImage *coverImage;
@property (nonatomic,copy) NSString *coverImageLocalIdentifier;
@end

@implementation CDGroupAsset

// 返回相册的封面缩略图
- (void)getCoverImageComplete:(void(^)(UIImage *image))complete
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *resultList = [PHAsset fetchAssetsInAssetCollection:self.phCollection options:options];
    __block PHAsset *asset = [resultList firstObject];
    
    if ([_coverImage isKindOfClass:[UIImage class]] && [_coverImageLocalIdentifier isEqualToString:asset.localIdentifier]) {
        complete(_coverImage);
        return;
    } else{
        UIScreen *screen = [UIScreen mainScreen];
        // 开始生成图片
        CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 0.2;
        CGSize imageTargetSize = CGSizeMake(imageSize * screen.scale, imageSize * screen.scale);
        [CDPhotoManager getImageWithAsset:asset byTargetSize:imageTargetSize completeNotify:^(UIImage *image, NSDictionary *info) {
            CGFloat fitWidth = image.size.width > image.size.height ? image.size.height : image.size.width;
            CGSize resize = CGSizeMake(fitWidth, fitWidth);
            _coverImage = [CDPhotoManager resizeImage:image size:resize];
            if ([_coverImage isKindOfClass:[UIImage class]]) {
                _coverImageLocalIdentifier = asset.localIdentifier;
            }
            complete(_coverImage);
        }];
    }
}

- (NSString *)getGroupName
{
    return self.phCollection.localizedTitle;
}

- (NSString *)getGroupIdentifier
{
    return self.phCollection.localIdentifier;
}

#pragma mark - Setter Methos
- (void)setPhCollection:(PHAssetCollection *)phCollection
{
    _phCollection = phCollection;
    _coverImage = nil;
}


#pragma mark - Getter Method
- (NSMutableArray <CDPhotoAsset *> *)photoAssets
{
    if ([_photoAssets isKindOfClass:[NSMutableArray class]] == NO) {
        _photoAssets = [[NSMutableArray alloc] init];
    }
    return _photoAssets;
}

@end



















