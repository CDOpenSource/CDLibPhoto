//
//  CDPhotoCollectionCell.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDPhotoCollectionCell.h"

CGFloat const MarginValue = 2.0;

@interface CDPhotoCollectionCell ()
@property (nonatomic,strong) UIImageView *imageViewPicture;
@property (nonatomic,strong) UIButton *buttonSelected;

@end


@implementation CDPhotoCollectionCell

#pragma mark - Public Method
- (void)setCellPictureImage:(UIImage *)image
{
    self.imageViewPicture.image = image;
    [self bringSubviewToFront:self.buttonSelected];
}

- (void)setButtonImage:(UIImage *)image
{
    UIImageView *imageview = [self.buttonSelected viewWithTag:1];
    imageview.image = image;
}

- (void)setShowModel:(NSInteger)model
{
    if (model == 0) {
        // 默认是缩略图小图展示选择模式
        self.buttonSelected.hidden = NO;
        self.imageViewPicture.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageViewPicture mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageViewPicture.superview).offset(MarginValue);
            make.right.equalTo(self.imageViewPicture.superview).offset(-MarginValue);
            make.top.equalTo(self.imageViewPicture.superview).offset(MarginValue);
            make.bottom.equalTo(self.imageViewPicture.superview);
        }];
    } else {
        // 整图预览展示选择模式
        self.buttonSelected.hidden = YES;
        self.imageViewPicture.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageViewPicture mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageViewPicture.superview);
            make.right.equalTo(self.imageViewPicture.superview);
            make.top.equalTo(self.imageViewPicture.superview);
            make.bottom.equalTo(self.imageViewPicture.superview);
        }];
    }
}


#pragma mark - IBAction
- (void)buttonClickedEvent:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(collectionCell:buttonClicked:)]) {
        [self.delegate collectionCell:self buttonClicked:_buttonSelected];
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
            make.left.equalTo(self).offset(MarginValue);
            make.right.equalTo(self).offset(-MarginValue);
            make.top.equalTo(self).offset(MarginValue);
            make.bottom.equalTo(self);
        }];
    }
    return _imageViewPicture;
}

- (UIButton *)buttonSelected
{
    if (_buttonSelected == nil) {
        _buttonSelected =[[UIButton alloc] init];
        _buttonSelected.clipsToBounds = YES;
        [_buttonSelected addTarget:self action:@selector(buttonClickedEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_buttonSelected];
        [_buttonSelected mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.height.equalTo(@(SCREEN_WIDTH/3.0/3.0*1.3));
            make.width.equalTo(_buttonSelected.mas_height);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.tag = 1;
        [_buttonSelected addSubview:imageView];
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_buttonSelected.mas_centerX).offset(6.0);
            make.centerY.equalTo(_buttonSelected.mas_centerY).offset(-6.0);
            make.height.equalTo(@(SCREEN_WIDTH/3.0/3.0/3.0*2.0));
            make.width.equalTo(imageView.mas_height);
        }];
        
    }
    return _buttonSelected;
}


@end
