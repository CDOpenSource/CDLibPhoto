//
//  CDMainTestViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/24.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDMainTestViewController.h"
#import "CDTestCollectionCell.h"
#import "CDPhotoManager.h"

@interface CDMainTestViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) NSArray <CDPhotoAsset *> *selectedPhotoList;
@property (nonatomic,strong) UICollectionView *collectionViewTest;
@end

@implementation CDMainTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"功能测试";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.collectionViewTest.dataSource = self;
    self.collectionViewTest.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedPhotoList = [NSMutableArray arrayWithArray:[[CDPhotoManager sharePhotos] selectedAssetList]];
    [self.collectionViewTest reloadData];
}


#pragma mark - collection view delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CDTestCollectionCell";
    [self.collectionViewTest registerClass:[CDTestCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    CDTestCollectionCell * cell = (CDTestCollectionCell *)[self.collectionViewTest dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    if (indexPath.row == self.selectedPhotoList.count) {
        // 添加item
        [cell showPicture:NO];
    } else {
        [cell showPicture:YES];
        CDPhotoAsset *photo = [self.selectedPhotoList objectAtIndex:indexPath.row];
        [photo getImageType:FullImageType Complete:^(CretaeImageType type, UIImage *image) {
            [cell setCellPictureImage:image];
        }];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedPhotoList.count + 1;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [CDPhotoManager showSystemPhotoAlbumListByController:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionViewTest.cd_width/4.0 - 3.0;
    return CGSizeMake(width, width);
}

#pragma mark  Item  Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - Getter Method
- (UICollectionView *)collectionViewTest
{
    if (_collectionViewTest == nil) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        //        flowLayout.isSuspend = YES;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _collectionViewTest.collectionViewLayout = flowLayout;
        _collectionViewTest = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionViewTest.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionViewTest.alwaysBounceVertical = YES;
        [self.view addSubview:_collectionViewTest];
        [_collectionViewTest mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(2.0);
            make.left.equalTo(self.view).offset(2.0);
            make.right.equalTo(self.view).offset(-2.0);
            make.bottom.equalTo(self.view).offset(2.0);
        }];
    }
    return _collectionViewTest;
}

@end
