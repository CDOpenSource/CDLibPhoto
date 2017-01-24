//
//  CDPhotoAssetViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDPhotoAssetViewController.h"
#import "CDPhotoCollectionCell.h"
#import "CDPhotoAsset.h"
#import "CDBrowsePhotoViewController.h"

@interface CDPhotoAssetViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CDPhotoCollectionCellDelegate,CDBrowsePhotoViewControllerDelegate>
{
    NSMutableArray <NSString *> *_selectedPhotoLocalIdentifierList;
}
@property (nonatomic,strong) NSArray <CDPhotoAsset *> *photoList;
@property (nonatomic,strong) UICollectionView *collectionViewPhotos;

@end

@implementation CDPhotoAssetViewController

#pragma mark 
- (instancetype)initWithPhotoList:(NSArray <CDPhotoAsset *>*)photoList
{
    self = [super init];
    if (self) {
        _selectedPhotoLocalIdentifierList = [[NSMutableArray alloc] init];
        _photoList = photoList;
    }
    return self;
}


#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.collectionViewPhotos.dataSource =self;
    self.collectionViewPhotos.delegate = self;
    
    [self.collectionViewPhotos reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionViewPhotos reloadData];
}


#pragma mark -  Collection View Delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.collectionViewPhotos registerClass:[CDPhotoCollectionCell class] forCellWithReuseIdentifier:@"CDPhotoCollectionCell"];
    __block CDPhotoCollectionCell * cell = (CDPhotoCollectionCell *)[self.collectionViewPhotos dequeueReusableCellWithReuseIdentifier:@"CDPhotoCollectionCell" forIndexPath:indexPath];
    [cell setShowModel:1];
    CDPhotoAsset *photo = [_photoList objectAtIndex:indexPath.row];
    [photo getImageType:ThumbnailImageType Complete:^(CretaeImageType type, UIImage *image) {
        [cell setCellPictureImage:image];
    }];
    
    cell.delegate = self;
    if ([_selectedPhotoLocalIdentifierList containsObject:photo.localIdentifier]) {
        [cell setButtonImage:[UIImage imageNamed:@"photo_image_selected_on_status_icon"]];
    } else {
        [cell setButtonImage:[UIImage imageNamed:@"photo_image_selected_off_status_icon"]];
    }

    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CDPhotoAsset *photo = [_photoList objectAtIndex:indexPath.row];

    CDBrowsePhotoViewController *browseController = [[CDBrowsePhotoViewController alloc] initWithPhotoList:self.photoList andDefaultStartPhoto:photo];
    browseController.delegate = self;
    [self.navigationController pushViewController:browseController animated:YES];
    
}

#pragma mark  Item Size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width;
    if (collectionView.cd_width > 320) {
        width = collectionView.cd_width/4.0- 0.5;
    } else {
        width = collectionView.cd_width/3.0- 0.5;
    }
    CGSize size = CGSizeMake(width, width);
    
    return size;
}

#pragma mark  Item  Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return MarginValue;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


#pragma mark  Item Number  And  Section Number
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger number = _photoList.count;
    
    return number;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - Cell Delegate Method
- (void)collectionCell:(CDPhotoCollectionCell *)cell buttonClicked:(UIButton *)button
{
    NSIndexPath *indexPath = [self.collectionViewPhotos indexPathForCell:cell];
    CDPhotoAsset *photo = [_photoList objectAtIndex:indexPath.row];
    if ([_selectedPhotoLocalIdentifierList containsObject:photo.localIdentifier]) {
        [_selectedPhotoLocalIdentifierList removeObject:photo.localIdentifier];
        [cell setButtonImage:[UIImage imageNamed:@"photo_image_selected_off_status_icon"]];
    } else {
        [_selectedPhotoLocalIdentifierList addObject:photo.localIdentifier];
        [cell setButtonImage:[UIImage imageNamed:@"photo_image_selected_on_status_icon"]];
    }
}

#pragma mark - CDBrowsePhotoViewControllerDelegate 
- (BOOL)browseController:(CDBrowsePhotoViewController *)browseController shouldSelectedPhoto:(CDPhotoAsset *)photo
{
    return [_selectedPhotoLocalIdentifierList containsObject:photo.localIdentifier];
}

- (BOOL)browseController:(CDBrowsePhotoViewController *)browseController buttonSelectedClickedOnItemPhoto:(CDPhotoAsset *)photo
{
    if ([_selectedPhotoLocalIdentifierList containsObject:photo.localIdentifier]) {
        [_selectedPhotoLocalIdentifierList removeObject:photo.localIdentifier];
        return NO;
//        [button setImage:[UIImage imageNamed:@"photo_image_selected_off_status_icon"] forState:UIControlStateNormal];
    } else {
        [_selectedPhotoLocalIdentifierList addObject:photo.localIdentifier];
        return YES;
//        [button setImage:[UIImage imageNamed:@"photo_image_selected_on_status_icon"] forState:UIControlStateNormal];
    }
}

#pragma mark - Getetr Method
- (UICollectionView *)collectionViewPhotos
{
    if (_collectionViewPhotos == nil) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        //        flowLayout.isSuspend = YES;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionViewPhotos.collectionViewLayout = flowLayout;
        _collectionViewPhotos = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionViewPhotos.backgroundColor = [UIColor whiteColor];
        _collectionViewPhotos.alwaysBounceVertical = YES;
        [self.view addSubview:_collectionViewPhotos];
        [_collectionViewPhotos mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view).offset(MarginValue);
            make.right.equalTo(self.view).offset(-MarginValue);
            make.bottom.equalTo(self.view);
        }];
        
    }
    return _collectionViewPhotos;
}

@end
