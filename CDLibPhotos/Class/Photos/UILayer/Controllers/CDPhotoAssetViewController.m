//
//  CDPhotoAssetViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDPhotoAssetViewController.h"
#import "CDPhotoCollectionCell.h"
#import "CDPhotoManager.h"
#import "CDBrowsePhotoViewController.h"

@interface CDPhotoAssetViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CDPhotoCollectionCellDelegate,CDBrowsePhotoViewControllerDelegate>
{
    NSMutableArray <NSString *> *_selectedPhotoLocalIdentifierList;
    
    UIView *_viewBottom;
    UILabel *_labelTotalCount;
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
        for (CDPhotoAsset *photo in [[CDPhotoManager sharePhotos] selectedAssetList]) {
            [_selectedPhotoLocalIdentifierList addObject:photo.localIdentifier];
        }
        _photoList = photoList;
    }
    return self;
}


#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initBottomView];
    
    self.collectionViewPhotos.dataSource =self;
    self.collectionViewPhotos.delegate = self;
    
    [self.collectionViewPhotos reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _labelTotalCount.text = [NSString stringWithFormat:@"已选中 %zi 张",_selectedPhotoLocalIdentifierList.count];
    [self.collectionViewPhotos reloadData];
}

#pragma mark 
- (void)initBottomView
{
    _viewBottom = [[UIView alloc] init];
    _viewBottom.backgroundColor = DefineColorRGB(0, 0, 0, 0.6);
    [self.view addSubview:_viewBottom];
    [_viewBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewBottom.superview);
        make.right.equalTo(_viewBottom.superview);
        make.bottom.equalTo(_viewBottom.superview);
        make.height.equalTo(@40.0);
    }];
    
    _labelTotalCount = [[UILabel alloc] init];
    _labelTotalCount.textColor = [UIColor whiteColor];
    _labelTotalCount.font = [UIFont boldSystemFontOfSize:13.0];
    _labelTotalCount.text = [NSString stringWithFormat:@"已选中 %zi 张",_selectedPhotoLocalIdentifierList.count];
    [_viewBottom addSubview:_labelTotalCount];
    [_labelTotalCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_labelTotalCount.superview).offset(10.0);
        make.top.equalTo(_labelTotalCount.superview);
        make.bottom.equalTo(_labelTotalCount.superview);
        //        make.width.equalTo()
    }];
    
    // 选中按钮
    UIButton *buttonDone = [[UIButton alloc] init];
    buttonDone.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [buttonDone setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [buttonDone addTarget:self action:@selector(buttonDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [buttonDone setTitle:@"完成" forState:UIControlStateNormal];
    [_viewBottom addSubview:buttonDone];
    [buttonDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(buttonDone.superview);
        make.top.equalTo(buttonDone.superview);
        make.bottom.equalTo(buttonDone.superview);
        make.width.equalTo(@70);
    }];
}

- (void)buttonDoneClicked:(UIButton *)button
{
    NSMutableArray *tempSelected = [[NSMutableArray alloc] init];
    CDGroupAsset *group = [[[CDPhotoManager sharePhotos] groupAssets] firstObject];
    NSArray *allAsset = [NSArray arrayWithArray:group.photoAssets];
    for (CDPhotoAsset *photo in allAsset) {
        if ([_selectedPhotoLocalIdentifierList containsObject:photo.localIdentifier]) {
            [tempSelected addObject:photo];
        }
    }
    [[CDPhotoManager sharePhotos] setSelectedAssetList:tempSelected];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  Collection View Delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.collectionViewPhotos registerClass:[CDPhotoCollectionCell class] forCellWithReuseIdentifier:@"CDPhotoCollectionCell"];
    __block CDPhotoCollectionCell * cell = (CDPhotoCollectionCell *)[self.collectionViewPhotos dequeueReusableCellWithReuseIdentifier:@"CDPhotoCollectionCell" forIndexPath:indexPath];
    [cell setShowModel:0];
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
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    CGFloat width;
//    if (collectionView.cd_width > 320) {
        width = (collectionView.cd_width - flow.sectionInset.left - flow.sectionInset.right - MarginValue*3.0)/4.0 - 0.0;
//    } else {
//        width = (collectionView.cd_width - flow.sectionInset.left - flow.sectionInset.right - MarginValue*2.0)/3.0 - 0.0;
//    }
    CGSize size = CGSizeMake(width, width);
    
    return size;
}

#pragma mark  Item  Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return MarginValue+1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return MarginValue;
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
    _labelTotalCount.text = [NSString stringWithFormat:@"已选中 %zi 张",_selectedPhotoLocalIdentifierList.count];
}

#pragma mark - CDBrowsePhotoViewControllerDelegate
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

- (void)buttonDoneClickedOnBrowseController:(CDBrowsePhotoViewController *)browseController
{
    [self buttonDoneClicked:nil];
}

- (BOOL)browseController:(CDBrowsePhotoViewController *)browseController shouldSelectedPhoto:(CDPhotoAsset *)photo
{
    return [_selectedPhotoLocalIdentifierList containsObject:photo.localIdentifier];
}

- (NSInteger)numberOfSelectedPhotosOnBrowseController:(CDBrowsePhotoViewController *)browseController
{
    return _selectedPhotoLocalIdentifierList.count;
}

#pragma mark - Getetr Method
- (UICollectionView *)collectionViewPhotos
{
    if (_collectionViewPhotos == nil) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        //        flowLayout.isSuspend = YES;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, MarginValue, 0, MarginValue);
        _collectionViewPhotos.collectionViewLayout = flowLayout;
        _collectionViewPhotos = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionViewPhotos.backgroundColor = [UIColor whiteColor];
        _collectionViewPhotos.alwaysBounceVertical = YES;
        [self.view addSubview:_collectionViewPhotos];
        [_collectionViewPhotos mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(64.0);
            make.left.equalTo(self.view).offset(0);
            make.right.equalTo(self.view).offset(0);
            make.bottom.equalTo(self.view).offset(-40);
        }];
        
    }
    return _collectionViewPhotos;
}

@end
