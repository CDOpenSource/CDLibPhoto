//
//  CDBrowsePhotoViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDBrowsePhotoViewController.h"
#import "CDPhotoAsset.h"
#import "CDPhotoCollectionCell.h"



@interface CDBrowsePhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSInteger _startIndex;
    UIView *_viewNavigation;
    UIButton *_buttonSelected;
    NSInteger _currentIndex;
}
@property (nonatomic,strong) NSArray <CDPhotoAsset *> *photoList;
@property (nonatomic,strong) UICollectionView *collectionViewBrowse;
@end

@implementation CDBrowsePhotoViewController


#pragma mark
- (instancetype)initWithPhotoList:(NSArray <CDPhotoAsset *>*)photoList andDefaultStartPhoto:(CDPhotoAsset *)defaultPhoto
{
    self = [super init];
    if (self) {
        _photoList = photoList;
        _startIndex = [_photoList indexOfObject:defaultPhoto];
    }
    return self;
}


#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.autoresizesSubviews = NO;
    
    // 设置代理
    self.collectionViewBrowse.dataSource = self;
    self.collectionViewBrowse.delegate  = self;
    self.collectionViewBrowse.showsHorizontalScrollIndicator = NO;
    self.collectionViewBrowse.showsVerticalScrollIndicator = NO;
    //    _collectionViewExam.scrollEnabled = NO;  //  不允许滑动 跳题
    self.collectionViewBrowse.autoresizesSubviews = NO;
    
    // 初始化导航栏
    [self initTopNavigationView];
    
    // 初始化滚动到指定的位置
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionViewBrowse scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionViewBrowse reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark
- (void)initTopNavigationView
{
    _viewNavigation = [[UIView alloc] init];
    _viewNavigation.backgroundColor = DefineColorRGB(0, 0, 0, 0.5);
    [self.view addSubview:_viewNavigation];
    [_viewNavigation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@60.0);
    }];
    
    // 返回按钮
    UIButton *backButton = [[UIButton alloc] init];
    [backButton addTarget:self action:@selector(buttonBackClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_viewNavigation addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backButton.superview);
        make.top.equalTo(backButton.superview);
        make.bottom.equalTo(backButton.superview);
        make.width.equalTo(backButton.mas_height);
    }];
    backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backButton.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backButton);
        make.centerY.equalTo(backButton);
        make.height.equalTo(@20);
        make.width.equalTo(backButton.imageView.mas_height);
    }];
    
    // 选中按钮
    _buttonSelected = [[UIButton alloc] init];
    [_buttonSelected addTarget:self action:@selector(buttonSelectedCliked:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonSelected setImage:[UIImage imageNamed:@"photo_image_selected_off_status_icon"] forState:UIControlStateNormal];
    [_viewNavigation addSubview:_buttonSelected];
    [_buttonSelected mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backButton.superview);
        make.top.equalTo(backButton.superview);
        make.bottom.equalTo(backButton.superview);
        make.width.equalTo(backButton.mas_height);
    }];
    _buttonSelected.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_buttonSelected.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_buttonSelected);
        make.centerY.equalTo(_buttonSelected);
        make.height.equalTo(@30);
        make.width.equalTo(_buttonSelected.imageView.mas_height);
    }];
    
}

#pragma mark - IBAction
- (void)buttonBackClicked:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonSelectedCliked:(UIButton *)button
{
//    [self.collectionViewBrowse visibleCells]
    CDPhotoAsset *photo = [self.photoList objectAtIndex:_currentIndex];
    
    if ([_delegate respondsToSelector:@selector(browseController:buttonSelectedClickedOnItemPhoto:)]) {
        BOOL result = [_delegate browseController:self buttonSelectedClickedOnItemPhoto:photo];
        UIImage *image = result ? [UIImage imageNamed:@"photo_image_selected_on_status_icon"] : [UIImage imageNamed:@"photo_image_selected_off_status_icon"];
        [button setImage:image forState:UIControlStateNormal];
    } else {
        NSLog(@"browseController:buttonSelectedClickedOnItemPhoto:代理方法未实现！！！");
    }
    
}


#pragma mark - collection view delegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CDPageCollectionCell";
    [self.collectionViewBrowse registerClass:[CDPhotoCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    CDPhotoCollectionCell * cell = (CDPhotoCollectionCell *)[self.collectionViewBrowse dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setShowModel:1];
    
    CDPhotoAsset *photo = [self.photoList objectAtIndex:indexPath.row];
    [photo getImageType:FullImageType Complete:^(CretaeImageType type, UIImage *image) {
        [cell setCellPictureImage:image];
    }];

    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoList.count;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.collectionViewBrowse.bounds.size;
    return size;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat indexOffset = scrollView.contentOffset.x/SCREEN_WIDTH;
    if (indexOffset >=0 && (roundf(indexOffset) != _currentIndex)) {
        _currentIndex = roundf(indexOffset);
        NSLog(@"_currentIndex = %zi",_currentIndex);
        // 更新状态
        if ([_delegate respondsToSelector:@selector(browseController:shouldSelectedPhoto:)]) {
            BOOL shouldSelected = [_delegate browseController:self shouldSelectedPhoto:[self.photoList objectAtIndex:_currentIndex]];
            UIImage *image = shouldSelected ? [UIImage imageNamed:@"photo_image_selected_on_status_icon"] : [UIImage imageNamed:@"photo_image_selected_off_status_icon"];
            [_buttonSelected setImage:image forState:UIControlStateNormal];
        } else {
            NSLog(@"browseController:shouldSelectedPhoto:代理方法未实现！");
        }
    }
}


#pragma mark - Getter Method
- (UICollectionView *)collectionViewBrowse
{
    if (_collectionViewBrowse == nil) {
        // 创建UICollectionViewFlowLayout布局对象
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        // 设置UICollectionView中各单元格的大小
        //    flowLayout.itemSize = _collectionPageView.bounds.size;
        NSLog(@"self.view.frame : %@",NSStringFromCGRect(self.view.frame));
        NSLog(@"_collectionView.frame : %@",NSStringFromCGRect(_collectionViewBrowse.frame));
        // 设置该UICollectionView只支持水平滚动
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //  每个item在水平方向的最小间距
        flowLayout.minimumLineSpacing = 0.0;
        flowLayout.minimumInteritemSpacing = 0.0;
        // 设置各分区上、下、左、右空白的大小。
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionViewBrowse = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionViewBrowse.backgroundColor = [UIColor whiteColor];
        _collectionViewBrowse.alwaysBounceHorizontal = YES;
        _collectionViewBrowse.pagingEnabled = YES;
        
        [self.view addSubview:_collectionViewBrowse];
        [_collectionViewBrowse mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        
    }
    return _collectionViewBrowse;
}

@end
