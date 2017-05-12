//
//  CDPhotoManager.h
//  CDNotepad
//
//  Created by Cindy on 2017/1/13.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "CDPhotoAsset.h"
#import "CDAlbumGroupViewController.h"
#import "CDCameraViewController.h"

@class CDPhotoManager;


@protocol CDPhotoManagerLoadingAseetDelegate <NSObject>
@optional
- (void)didAddedGroup:(CDGroupAsset *)group fromPhotoManager:(CDPhotoManager *)manager;
- (void)didAddedAsset:(CDPhotoAsset *)asset onGroup:(CDGroupAsset *)group fromPhotoManager:(CDPhotoManager *)manager;

- (void)photoManagerDidRefreshedAlbumAssets;
@end


@interface CDPhotoManager : NSObject

@property (nonatomic, strong ,readonly) NSMutableDictionary <NSString *,NSArray <CDPhotoAsset *>*> *assets;
@property (nonatomic, strong ,readonly) NSMutableArray <CDGroupAsset *> *groupAssets;

@property (nonatomic, strong) NSMutableArray <CDPhotoAsset *> *selectedAssetList;

/**
 请求访问相册的权限
 @param completeHandler 授权操作结果的回调
 */
+ (void)requestAuthorizationOnComplete:(void(^)(PHAuthorizationStatus status))completeHandler;



/**
 获取一个相册的单例对象
 @return 单例引用
 */
+ (CDPhotoManager *)sharePhotos;

#pragma mark 拉伸照片
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size;
#pragma mark 裁剪照片
+ (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size;
/**
 *  按照指定的format格式转换一个日期，返回转换后的字符串
 *
 *  @param date   需要转换的日期
 *  @param format 转换格式
 *
 *  @return 转换后的字符串
 */
+ (NSString *)date:(NSDate *)date toStringByFormat:(NSString *)format;


#pragma mark - UI Dispaly
+ (void)showSystemPhotoAlbumListByController:(UIViewController *)controller;



#pragma mark
/**
 加载（或重新加载）一次系统相册中的所有资源
 @param delegate 加载过程中的事件回调代理对象
 */
- (void)loadedAssetsCallbackDelegate:(id<CDPhotoManagerLoadingAseetDelegate>)delegate;




/**
 生成某个相册资源指定尺寸的图片对象
 @param asset 相册资源对象
 @param targetSize 要生成的尺寸大小
 @param notify 完成后的通知回调
 @return 返回一个同步结果的标识符（用于异步生成过程中途取消操作的入参）
 */
+ (NSInteger)getImageWithAsset:(PHAsset *)asset byTargetSize:(CGSize)targetSize completeNotify:(void(^)(UIImage *image,NSDictionary *info))notify;












// 保存指定照片到指定目录
- (void)saveImageWithAsset:(PHAsset *)asset toSavePathDirectory:(NSString *)savePathDir completeNotify:(void(^)(BOOL saveResult,NSString *saveFullPath))notify;
@end
