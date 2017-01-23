//
//  CDPhotoCollectionCell.h
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDPhotoCollectionCell;



UIKIT_EXTERN CGFloat const MarginValue;

@protocol CDPhotoCollectionCellDelegate <NSObject>
- (void)collectionCell:(CDPhotoCollectionCell *)cell buttonClicked:(UIButton *)button;
@end

@interface CDPhotoCollectionCell : UICollectionViewCell

@property (nonatomic,assign) id<CDPhotoCollectionCellDelegate> delegate;


#pragma mark - Public Method
- (void)setCellPictureImage:(UIImage *)image;
- (void)setButtonImage:(UIImage *)image;

@end
