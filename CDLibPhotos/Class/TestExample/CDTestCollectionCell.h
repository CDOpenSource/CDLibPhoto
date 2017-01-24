//
//  CDTestCollectionCell.h
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/24.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDTestCollectionCell : UICollectionViewCell

#pragma mark - Public Method
- (void)setCellPictureImage:(UIImage *)image;
- (void)showPicture:(BOOL)show;

@end
