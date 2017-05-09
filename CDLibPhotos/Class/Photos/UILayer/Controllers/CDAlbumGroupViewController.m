//
//  CDAlbumGroupViewController.m
//  CDLibPhotos
//
//  Created by Cindy on 2017/1/23.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "CDAlbumGroupViewController.h"
#import "CDPhotoManager.h"
#import "CDPhotoAssetViewController.h"


@interface CDAlbumGroupViewController()<UITableViewDelegate ,UITableViewDataSource,CDPhotoManagerLoadingAseetDelegate>
@property (nonatomic,strong) UITableView *tableViewShow;
@end

@implementation CDAlbumGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的相册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 请求系统相册
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [CDPhotoManager requestAuthorizationOnComplete:^(PHAuthorizationStatus status) {
            if (PHAuthorizationStatusAuthorized == status) {
                [[CDPhotoManager sharePhotos] loadedAssetsCallbackDelegate:self];
            } else {
                NSLog(@"授权状态错误！");
            }
        }];
    });
    
    
    self.tableViewShow.delegate = self;
    self.tableViewShow.dataSource = self;

    
    UIButton *leftButton = [[UIButton alloc] init];
    leftButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    leftButton.cd_size = CGSizeMake(50, 50.0);
//    leftButton.tag = 3;
    // 监听按钮点击
    [leftButton addTarget:self action:@selector(navigationButtonPressEvent:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
}

#pragma mark - IBAction Method
- (void)navigationButtonPressEvent:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        _tableViewShow.delegate = nil;
        _tableViewShow.dataSource = nil;
        _tableViewShow = nil;
    }];
}

#pragma mark - TableView Delegate Method
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *headerImageView = [self retrunImageViewOnCell:cell];
    UILabel *labelTitle = [self retrunLabelTitleOnCell:cell];
    
    CDGroupAsset *group = [[[CDPhotoManager sharePhotos] groupAssets] objectAtIndex:indexPath.row];
    labelTitle.text = [NSString stringWithFormat:@"%@ (%zi)",group.collectionName,group.photoCounts];
    [group getCoverImageComplete:^(UIImage *image) {
        headerImageView.image = image;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%zi  -  %zi",[indexPath section] , [indexPath row]);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CDGroupAsset *group = [[[CDPhotoManager sharePhotos] groupAssets] objectAtIndex:indexPath.row];
    NSArray *photoList = [NSArray arrayWithArray:[[[CDPhotoManager sharePhotos] assets] objectForKey:group.localIdentifier]];
    CDPhotoAssetViewController *photoController = [[CDPhotoAssetViewController alloc] initWithPhotoList:photoList];
    photoController.title = [NSString stringWithFormat:@"%@ (%zi)",group.collectionName,group.photoCounts];
    [self.navigationController pushViewController:photoController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[CDPhotoManager sharePhotos] assets] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark  create table view cell subview method
- (UIImageView *)retrunImageViewOnCell:(UITableViewCell *)cell
{
    UIImageView *imageView = [cell.contentView viewWithTag:1];
    if (imageView == nil) {
        imageView = [[UIImageView alloc] init];
        imageView.tag = 1;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 2.0f;
        imageView.layer.borderWidth = 0.4;
        imageView.layer.borderColor = DefineColorHEX(0xdddddd).CGColor;
        [cell.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.superview).offset(10.0);
            make.top.equalTo(imageView.superview).offset(5.0);
            make.bottom.equalTo(imageView.superview).offset(-5.0);
            make.width.equalTo(imageView.mas_height);
        }];
    }
    return imageView;
}

- (UILabel *)retrunLabelTitleOnCell:(UITableViewCell *)cell
{
    UILabel *labelTitle = [cell.contentView viewWithTag:2];
    if (labelTitle == nil) {
        labelTitle = [[UILabel alloc] init];
        labelTitle.tag = 2;
        labelTitle.textColor = [UIColor darkTextColor];
        labelTitle.font = [UIFont systemFontOfSize:16.0];
        [cell.contentView addSubview:labelTitle];
        [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self retrunImageViewOnCell:cell].mas_right).offset(10.0);
            make.top.equalTo(labelTitle.superview);
            make.bottom.equalTo(labelTitle.superview);
            make.right.equalTo(labelTitle.superview);
        }];
    }
    return labelTitle;
}

#pragma mark - CDPhotoManager Delegate Method
- (void)didAddedGroup:(CDGroupAsset *)group fromPhotoManager:(CDPhotoManager *)manager
{
    static NSDate *lastDate;
    if ([lastDate isKindOfClass:[NSDate class]] && ([lastDate timeIntervalSinceNow] < 1.0)) {
        return;
    }
    
    [self.tableViewShow reloadData];
}

- (void)photoManagerDidRefreshedAlbumAssets
{
    [self.tableViewShow reloadData];
}


#pragma mark - Getter Method
- (UITableView *)tableViewShow
{
    if (_tableViewShow == nil) {
        
        _tableViewShow = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
        _tableViewShow.sectionFooterHeight = 0;
        _tableViewShow.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 0.1f)];
        _tableViewShow.tableFooterView = [UIView new];
        
        _tableViewShow.backgroundColor = [UIColor groupTableViewBackgroundColor];
        //        [_tableViewShow setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [self.view addSubview:_tableViewShow];
        [_tableViewShow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    return _tableViewShow;
}


- (void)dealloc
{
    _tableViewShow.delegate = nil;
    _tableViewShow.dataSource = nil;
    _tableViewShow = nil;
}

@end
