//
//  CDPhotoManager.m
//  CDNotepad
//
//  Created by Cindy on 2017/1/13.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDPhotoManager.h"

@interface CDPhotoManager ()

@property (nonatomic,weak) id<CDPhotoManagerLoadingAseetDelegate> loadingDelegate;

@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;

@property (nonatomic, strong) dispatch_queue_t photoCurrentQueue;

@end



@implementation CDPhotoManager
@synthesize groupAssets = _groupAssets;


+ (CDPhotoManager *)sharePhotos
{
    static CDPhotoManager *shared;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [[self alloc]init];
        shared.photoCurrentQueue = dispatch_queue_create("com.photoManager.global", DISPATCH_QUEUE_CONCURRENT);
        [shared loadedAssets];
    });
    return shared;
}


#pragma mark 拉伸照片
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size
{
    //创建一个bitmap的context
    //并把他设置成当前的context
    UIGraphicsBeginImageContext(size);
    
    //    UIRectClip(CGRectMake(0, 0, size.width, size.height));
    //绘制图片的大小
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //从当前context中创建一个改变大小后的图片
    UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return endImage;
}

#pragma mark 裁剪照片
+ (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    CGFloat orgX = (image.size.width - size.width) / 2.0;
    CGFloat orgY = (image.size.height - size.height) / 2.0;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect cropRect = CGRectMake(orgX, orgY, width, height);
    CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    
    CGFloat deviceScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(cropRect.size, 0, deviceScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, cropRect.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height), imgRef);
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(imgRef);
    UIGraphicsEndImageContext();
    
    return newImg;
}

#pragma mark 日期转换成字符串
+ (NSString *)date:(NSDate *)date toStringByFormat:(NSString *)format
{
    static NSDateFormatter *dateFormatter = nil;
    if(!dateFormatter){
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    //  eg : format = @"MMMM yyyy" ;  format = @"dd"  ;
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - UI Dispaly
+ (void)showSystemPhotoAlbumListByController:(UIViewController *)controller
{
    CDAlbumGroupViewController *albumController = [[CDAlbumGroupViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:albumController];
    [controller presentViewController:navi animated:YES completion:nil];
}

#pragma mark
+ (void)requestAuthorizationOnComplete:(void(^)(PHAuthorizationStatus status))completeHandler
{
    // Check library permissions
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            completeHandler ? completeHandler(status) : nil;
        }];
    } else {
        completeHandler ? completeHandler(status) : nil;
    }
}

- (void)loadedAssetsCallbackDelegate:(id<CDPhotoManagerLoadingAseetDelegate>)delegate
{
    _loadingDelegate = delegate;
    [self loadedAssets];
}

- (void)loadedAssets
{
    if (NSClassFromString(@"PHAsset")) {
        // Check library permissions
        [CDPhotoManager requestAuthorizationOnComplete:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self performLoadAssetResource];
            } else {
                NSLog(@"相册访问的权限没有被允许！");
            }
        }];
    } else {
        // Assets library
        NSLog(@"没有找到相应的类库和框架！");
    }
}

- (void)performLoadAssetResource
{
    // Initialise
//    assetsDictionary = [[NSMutableDictionary alloc] init];
//    _groupAssets = [[NSMutableArray alloc] init];
    if ([_groupAssets isKindOfClass:[NSMutableArray class]] == NO) {
        _groupAssets = [[NSMutableArray alloc] init];
    }
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        // Photos library iOS >= 8
        [self enumerateAlbumObjects];
    }
}

- (void)enumerateAlbumObjects
{
//    PHFetchOptions *options = [[PHFetchOptions alloc] init];
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:NO]];
    
    dispatch_sync(self.photoCurrentQueue, ^{
        
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO]];
        
        NSMutableArray *groupAssets = [[NSMutableArray alloc] init];
        
        NSArray *allAlbum = @[@(PHAssetCollectionTypeSmartAlbum),@(PHAssetCollectionTypeAlbum)];
        for (NSInteger j = 0; j < [allAlbum count]; j++) {
            PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:[allAlbum[j] integerValue] subtype:PHAssetCollectionSubtypeAny options:options];
            
            for (NSInteger i = 0; i < [result count]; i++) {
                PHAssetCollection *collection = [result objectAtIndex:i];
                // 过滤照片数量为0的相册
                NSInteger count = [[PHAsset fetchAssetsInAssetCollection:collection options:nil] count];
                if (count == 0) {
                    continue;
                }
                
                NSLog(@"------------------------------- Album --------------------------------");
                NSLog(@"localizedTitle = %@; count = %zi;\n",collection.localizedTitle,count);
                
                CDGroupAsset *newGroup;
                BOOL finded = NO;
                for (CDGroupAsset *oldGroup in _groupAssets) {
                    if ([oldGroup.getGroupIdentifier isEqualToString:collection.localIdentifier]) {
                        newGroup = oldGroup;
                        finded = YES;
                        break;
                    }
                }
                // 是否已近存在此相册
                if ([newGroup isKindOfClass:[CDGroupAsset class]] == NO) {
                    newGroup = [[CDGroupAsset alloc] init];
                    newGroup.phCollection = collection;
                }
                
                // 迭代相册中的图片
                NSMutableArray *photoList = [self enumerateAssetListWithGroup:newGroup];
                newGroup.photoAssets = [NSMutableArray arrayWithArray:photoList];
                
                if (newGroup.photoAssets.count > 0) {
                    [groupAssets addObject:newGroup];
                    // 通知代理对象，此相册已经更新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([_loadingDelegate respondsToSelector:@selector(didAddedGroup:fromPhotoManager:)]) {
                            [_loadingDelegate didAddedGroup:newGroup fromPhotoManager:self];
                        }
                    });
                    
                } else {
                    
                    if (finded) {
                        [_groupAssets removeObject:newGroup];
                    }
                    NSLog(@"相册%@中没有找到图片！",collection.localizedTitle);
                }
            }
        }
        
        // 更新当前相册集合
        _groupAssets = [NSMutableArray arrayWithArray:groupAssets];
        
        // 通知代理对象系统相册已经全部更新完成
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_loadingDelegate respondsToSelector:@selector(photoManagerDidRefreshedAlbumAssets)]) {
                [_loadingDelegate photoManagerDidRefreshedAlbumAssets];
            }
        });
    });
                  
}

- (NSMutableArray <CDPhotoAsset *> *)enumerateAssetListWithGroup:(CDGroupAsset *)group
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *resultList = [PHAsset fetchAssetsInAssetCollection:group.phCollection options:options];
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    if ([resultList count] > 0) {
        for (NSInteger i = 0; i < [resultList count]; i ++) {
            PHAsset *asset = [resultList objectAtIndex:i];
            @try {
                CDPhotoAsset *cdPhoto = [[CDPhotoAsset alloc] init];
                cdPhoto.phAsset = asset;
                cdPhoto.assetName = [CDPhotoManager date:asset.creationDate toStringByFormat:@"yyyy-MM-dd HH:mm:ss"];
                cdPhoto.localIdentifier = asset.localIdentifier;
                if (asset.mediaType == PHAssetMediaTypeImage) { // 图片
                    cdPhoto.assetType = AssetMediaTypeAudio;
                } else if (asset.mediaType == AssetMediaTypeImage) { // 视频
                    cdPhoto.assetType = AssetMediaTypeAudio;
                } else if (asset.mediaType == PHAssetMediaTypeVideo) { // 音频
                    cdPhoto.assetType = AssetMediaTypeAudio;
                } else { // 未知
                    cdPhoto.assetType = AssetMediaTypeUnknown;
                }
                [tempArray addObject:cdPhoto];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([_loadingDelegate respondsToSelector:@selector(didAddedAsset:onGroup:fromPhotoManager:)]) {
                        [_loadingDelegate didAddedAsset:cdPhoto onGroup:group fromPhotoManager:self];
                    }
                });
                
            } @catch (NSException *exception) {
                NSLog(@"%@ ------> [%@  （%zi）]",exception,[[NSString stringWithFormat:@"%s",__FILE__] lastPathComponent],__LINE__);
            } @finally {}
        }
    }
    
    return tempArray;
}





#pragma mark
// Load from photos library
+ (NSInteger)getImageWithAsset:(PHAsset *)asset byTargetSize:(CGSize)targetSize completeNotify:(void(^)(UIImage *image,NSDictionary *info))notify
{
    __block PHImageRequestID id_num;
    
    dispatch_sync([CDPhotoManager sharePhotos].photoCurrentQueue, ^{
        
        PHImageManager *imageManager = [PHImageManager defaultManager];
        
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = NO;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            NSLog(@"progress = %f\ninfo = %@",progress,info);
        };
        
        // 按指定尺寸生成图片
        id_num = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"requestImageForAsset:resultHandler: -> %@",info);
                notify ? notify(result,info) : nil;
            });
        }];
        
    });
    
    return id_num;
    
}

- (void)saveImageWithAsset:(PHAsset *)asset toSavePathDirectory:(NSString *)savePathDir completeNotify:(void(^)(BOOL saveResult,NSString *saveFullPath))notify
{
    dispatch_sync([CDPhotoManager sharePhotos].photoCurrentQueue, ^{
        
        PHImageManager *imageManager = [PHImageManager defaultManager];
        
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = NO;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            NSLog(@"progress = %f\ninfo = %@",progress,info);
        };
        
        [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            NSString *url = [[info objectForKey:@"PHImageFileURLKey"] absoluteString];
            NSRange targetRang = [url rangeOfString:@"DCIM"];
            NSString *shortPath;
            if (targetRang.length > 0) {
                shortPath = [url substringWithRange:NSMakeRange(targetRang.location, url.length - targetRang.location)];
            } else {
                shortPath = [url lastPathComponent];
            }
            
            NSString *path = [savePathDir stringByAppendingPathComponent:shortPath];
            [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:imageData attributes:nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                notify ? notify(result,path) : nil;
            });
            
        }];
        
    });
}

@end
