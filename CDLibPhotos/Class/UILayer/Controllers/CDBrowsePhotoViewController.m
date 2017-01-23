//
//  CDBrowsePhotoViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDBrowsePhotoViewController.h"
#import "SDCycleScrollView.h"
#import "CDPhotoAsset.h"



@interface CDBrowsePhotoViewController ()
@property (nonatomic,strong) NSArray <CDPhotoAsset *> *photoList;
@property (nonatomic,strong) SDCycleScrollView *browseView;
@end

@implementation CDBrowsePhotoViewController


#pragma mark
- (instancetype)initWithPhotoList:(NSArray <CDPhotoAsset *>*)photoList
{
    self = [super init];
    if (self) {
        _photoList = photoList;
    }
    return self;
}


#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.browseView setBannerImageViewContentMode:UIViewContentModeScaleAspectFit];
    [self.browseView clearCache];
    [self.browseView setImageURLStringsGroup:self.photoList];
}

#pragma mark - Getter Method
- (SDCycleScrollView *)browseView
{
    if (_browseView == nil) {
        _browseView = [SDCycleScrollView cycleScrollViewWithFrame:self.view.bounds imageURLStringsGroup:self.photoList];
        _browseView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _browseView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _browseView.placeholderImage = [UIImage imageNamed:@"picture.png"];
        _browseView.hidesForSinglePage = YES;
        _browseView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
        _browseView.pageDotColor = [UIColor lightGrayColor];
        _browseView.pageControlDotSize = CGSizeMake(7.0, 7.0);
        _browseView.autoScrollTimeInterval = 5.0;
        if ([self.photoList count] <= 1) {
            _browseView.autoScroll = NO;
        } else {
            _browseView.autoScroll = YES;
        }
        [self.view addSubview:_browseView];
        [_browseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    return _browseView;
}

@end
