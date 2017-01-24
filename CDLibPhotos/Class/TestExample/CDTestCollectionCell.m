//
//  CDTestCollectionCell.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/24.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDTestCollectionCell.h"


@interface CDTestCollectionCell()
@property (nonatomic,strong) UIImageView *imageViewPicture;
@property (nonatomic,strong) UILabel *labelAdd;
@end


@implementation CDTestCollectionCell

#pragma mark - Public Method
- (void)setCellPictureImage:(UIImage *)image
{
    self.imageViewPicture.image = image;
//    [self bringSubviewToFront:self.buttonSelected];
}

- (void)showPicture:(BOOL)show
{
    if (show) {
        self.imageViewPicture.hidden = NO;
        self.labelAdd.hidden = YES;
    } else {
        self.labelAdd.hidden = NO;
        self.imageViewPicture.hidden = YES;
    }
}

#pragma mark - Getter Method
- (UIImageView *)imageViewPicture
{
    if (_imageViewPicture == nil) {
        _imageViewPicture = [[UIImageView alloc] init];
        _imageViewPicture.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewPicture.clipsToBounds = YES;
        _imageViewPicture.layer.cornerRadius = 3.0f;
        [self addSubview:_imageViewPicture];
        [_imageViewPicture mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
            make.top.equalTo(self).offset(0);
            make.bottom.equalTo(self);
        }];
    }
    return _imageViewPicture;
}

- (UILabel *)labelAdd
{
    if (_labelAdd == nil) {
        _labelAdd = [[UILabel alloc] init];
        _labelAdd.text = @"+";
        _labelAdd.contentMode = UIViewContentModeCenter;
        _labelAdd.textAlignment = NSTextAlignmentCenter;
        _labelAdd.textColor = DefineColorRGB(220, 220, 220, 1.0);
        _labelAdd.font = [UIFont systemFontOfSize:60];
        _labelAdd.layer.borderColor = DefineColorRGB(220, 220, 220, 1.0).CGColor;
        _labelAdd.layer.borderWidth = 1.0f;
        _labelAdd.layer.cornerRadius = 3.0;
//        _labelAdd.backgroundColor = [UIColor yellowColor];
        [self addSubview:_labelAdd];
        [_labelAdd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            
        }];
    }
    return _labelAdd;
}

@end
