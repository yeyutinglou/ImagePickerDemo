//
//  AssetListController.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "AssetListController.h"
#import "AssetManager.h"
#import "PhotoToolBar.h"
#import "AssetImageCell.h"
#import "AssetVideoCell.h"
#import "UICollectionView+Category.h"
#import "ImagePickerConfig.h"
#import "ImagePickerController.h"
#import "ImageShowController.h"
#import "VideoDisplayController.h"

#define NUM_PER_ROW 4
#define CELL_INTEVEL 4.0

#define COLLECTION_IMAGE_CELL_ID @"Asset_Image_Cell_Id"

#define COLLECTION_VIDEO_CELL_ID @"Asset_Video_Cell_Id"

@interface AssetListController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) PhotoToolbar *toolBar;

//@property (nonatomic) MBProgressHUD *HUD;

@end

@implementation AssetListController {
    CGFloat cellWidth;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    
    return self;
}





- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.groupModel.assetsGroupName;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(doBack)];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 5;
    self.navigationItem.rightBarButtonItems = @[ spaceItem, cancelItem];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self setupSubView];
    
    [self fetchData];
    
}


- (void)setupSubView {
    cellWidth = floor((kWidth - (NUM_PER_ROW + 1) * CELL_INTEVEL) / NUM_PER_ROW);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
    flowLayout.minimumLineSpacing = CELL_INTEVEL;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(CELL_INTEVEL, CELL_INTEVEL, 0, CELL_INTEVEL);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[AssetImageCell class] forCellWithReuseIdentifier:COLLECTION_IMAGE_CELL_ID];
    [self.collectionView registerClass:[AssetVideoCell class] forCellWithReuseIdentifier:COLLECTION_VIDEO_CELL_ID];
    
    self.toolBar = [[PhotoToolbar alloc] initWithStyle:kPhotoToolbarStyle1];
    [self.toolBar addTarget:self previewAction:@selector(doPreview) finishAction:@selector(doFinish)];
    [self.view addSubview:self.toolBar];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, CGRectGetHeight(self.toolBar.frame), 0);
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)showLoadingIndicator {

}


- (void)hideLoadingIndicator {

}


#pragma mark - 获取数据

- (void)fetchData {
    //没有数据时，显示一个ActivityIndicator
    if (!self.groupModel) {
        [self showLoadingIndicator];
        return;
    }
    self.title = self.groupModel.assetsGroupName;
//     self.toolBar.number = self.allSelectdAssets.count;
    
    
    WEAK_SELF;
    [[AssetManager sharedAssetManager] fetchAllAssetsInGroup:self.groupModel successBlock:^(AssetsGroupModel * _Nonnull groupModel) {
//        if (self.allSelectdAssets.count > 0) {
//            for (int i = 0 ; i < self.allSelectdAssets.count; i++) {
//                AssetModel *model = self.allSelectdAssets[i];
//                for (int j = 0; j < self.groupModel.allAssets.count; j++) {
//                    AssetModel *newModel = self.groupModel.allAssets[j];
//                    if ([model.asset_PH isEqual:newModel.asset_PH]) {
//                        [self.allSelectdAssets replaceObjectAtIndex:i withObject:newModel];
//                    }
//                }
//            }
//        }
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView layoutIfNeeded];
        
        [weakSelf.collectionView scrollsToBottomAnimated:NO];
        [weakSelf hideLoadingIndicator];
    } failureBlock:^(NSError * _Nullable error) {
        ;
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.subviews[0].alpha = DEFAULT_NAVIGATION_BAR_ALPHA;
    
//    self.toolBar.number = self.allSelectdAssets.count;
    [self.collectionView reloadData];
    
}




- (void)doFinish {
    [(ImagePickerController *)self.navigationController didFinishPickingImages:self.allSelectdAssets WithError:nil assetGroupModel:self.groupModel];
}

- (void)doCancel {
    [(ImagePickerController *)self.navigationController didCancelPickingImages];
}

- (void)doBack {
   
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.groupModel.allAssets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AssetModel *assetModel = self.groupModel.allAssets[indexPath.item];
    UICollectionViewCell *_cell;
    if (assetModel.assetMediaType == kAssetMediaTypeVideo) {
        AssetVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VIDEO_CELL_ID forIndexPath:indexPath];
        cell.assetModel = assetModel;
        
        _cell = cell;
    }else if (assetModel.assetMediaType == kAssetMediaTypeImage) {
        AssetImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_IMAGE_CELL_ID forIndexPath:indexPath];
        cell.assetModel = assetModel;
        NSLog(@"%@",self.allSelectdAssets);
        NSLog(@"%@",assetModel);
        cell.cellSelected = [self.allSelectdAssets containsObject:cell.assetModel];
        [cell addTarget:self selectAction:@selector(handleAssetCellSelect:) showAction:@selector(handleAssetCellShow:)];
        _cell = cell;
    }
    
    return _cell;
}


- (BOOL)handleAssetCellSelect:(AssetImageCell *)cell {
    if (!cell.assetModel.isAssetInLocalAlbum) {
        if (cell.isCellSelected) {
            [self.allSelectdAssets removeObject:cell.assetModel];
            self.toolBar.number = self.allSelectdAssets.count;
            return YES;
        }else {
            //TODO:下一步支持iCloud照片流，当前版本暂不支持
//            [LLUtils showMessageAlertWithTitle:nil message:@"正在从iCloud同步照片"];
            return NO;
        }
    }
    
    if (!cell.isCellSelected) {
        if (self.allSelectdAssets.count == MAX_PHOTOS_CAN_SELECT- self.selectedNum) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%ld张照片", MAX_PHOTOS_CAN_SELECT - self.selectedNum]delegate:self cancelButtonTitle:@"好，我知道了" otherButtonTitles:nil];
            [alert show];
            return NO;
        }else if (![self.allSelectdAssets containsObject:cell.assetModel]) {
            NSLog(@"%@",cell.assetModel);
            [self.allSelectdAssets addObject:cell.assetModel];
        }
    }else if (cell.isCellSelected && [self.allSelectdAssets containsObject:cell.assetModel]) {
        [self.allSelectdAssets removeObject:cell.assetModel];
    }
    
    self.toolBar.number = self.allSelectdAssets.count;
    
    return YES;
}

- (void)doPreview {
    ImageShowController *previewController = [[ImageShowController alloc] init];
    
    previewController.assetGroupModel = self.groupModel;
    previewController.allSelectdAssets = self.allSelectdAssets;
    previewController.curShowAsset = self.allSelectdAssets[0];
    previewController.allAssets = [self.allSelectdAssets copy];
    
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)handleAssetCellShow:(AssetImageCell *)cell {
    ImageShowController *previewController = [[ImageShowController alloc] init];
    
    previewController.assetGroupModel = self.groupModel;
    previewController.curShowAsset = cell.assetModel;
    previewController.allSelectdAssets = self.allSelectdAssets;
    previewController.allAssets = self.groupModel.allAssets;
    previewController.selectedNum = self.selectedNum;
    
    [self.navigationController pushViewController:previewController animated:YES];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    AssetModel *assetModel = self.groupModel.allAssets[indexPath.item];
    
    if (assetModel.assetMediaType == kAssetMediaTypeVideo) {
        VideoDisplayController *vc = [[VideoDisplayController alloc] init];
        vc.assetModel = assetModel;
        vc.assetGroupModel = self.groupModel;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
