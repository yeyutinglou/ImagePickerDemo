//
//  ImagePickerController.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "ImagePickerController.h"

#import "AlbumListController.h"
#import "AssetListController.h"
#import "AssetManager.h"


static NSString *lastAssertGroupIdentifier;

@interface ImagePickerController ()

@property (nonatomic) AlbumListController *albumVC;


@end

@implementation ImagePickerController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.navigationBar.translucent = YES;
        self.navigationBar.alpha = 0.9;
    }
    
    return self;
}

- (void)chechAuthorizationStatus {
    WEAK_SELF;
    CheckAuthorizationCompletionBlock block = ^(AuthorizationType type) {
        if (!weakSelf)return;
        
        switch (type) {
            case kAuthorizationTypeAuthorized:
            {
                //ImagePicker打开时尚未获取照片库权限，请求权限后用户允许访问照片库
                if (weakSelf.albumVC) {
                        [weakSelf fetchAlbumData];
                }else {
                    //ImagePicker打开时就获取了访问照片库的权限
                    weakSelf.albumVC = [[AlbumListController alloc] initWithStyle:UITableViewStylePlain];
                    weakSelf.albumVC.navigationItem.title = @"返回";
                    weakSelf.albumVC.selecedNum = _selectedNum;
                    
                    AssetListController *assetListVC = [[AssetListController alloc] init];
                    assetListVC.groupModel = nil;
                    assetListVC.selectedNum = self.selectedNum;
                    [weakSelf setViewControllers:@[weakSelf.albumVC, assetListVC] animated:NO];
                    
                    [weakSelf fetchAlbumData];
                }
                
            }
                break;
            case kAuthorizationTypeDenied:
            case kAuthorizationTypeRestricted:
            {

                //相册不可用

            }
                break;
            case kAuthorizationTypeNotDetermined:
            {
                weakSelf.albumVC = [[AlbumListController alloc] initWithStyle:UITableViewStylePlain];
                weakSelf.albumVC.selecedNum = _selectedNum;
                [weakSelf setViewControllers:@[weakSelf.albumVC] animated:NO];

                    [weakSelf fetchAlbumData];
            }
                break;
            default:
                break;
        }
    };
    
    [[AssetManager sharedAssetManager] chechAuthorizationStatus:block];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self chechAuthorizationStatus];
}

//该方法异步获取全部相册
- (void)fetchAlbumData {
    WEAK_SELF;
    FetchAssetsGroupsSuccessBlock successBlock = ^() {
        if ([[weakSelf.childViewControllers lastObject] isKindOfClass:[AssetListController class]]) {
            AssetsGroupModel *model = [[AssetManager sharedAssetManager] assetsGroupModelForLocalIdentifier:lastAssertGroupIdentifier];
            
            AssetListController *assetListVC = (AssetListController *)[weakSelf.childViewControllers lastObject];
            assetListVC.groupModel = model;
            assetListVC.allSelectdAssets = [[NSMutableArray alloc] init];
            assetListVC.selectedNum = self.selectedNum;
            [assetListVC fetchData];
        }else {
            [weakSelf.albumVC refresh];
        }
        
    };
    
    FetchAssetsGroupsFailureBlock failureBlock = ^(NSError * _Nullable error) {
    };
    
    [[AssetManager sharedAssetManager] fetchAllAssetsGroups:successBlock failureBlock:failureBlock];
}

- (void)didFinishPickingImages:(NSArray<AssetModel *> *)assets WithError:(NSError *)error assetGroupModel:(AssetsGroupModel *)assetGroupModel {
    lastAssertGroupIdentifier = assetGroupModel.localIdentifier;
    
    [self.pickerDelegate imagePickerController:self didFinishPickingImages:assets withError:error];
    [self cleanAfterDismiss];
}

- (void)didCancelPickingImages {
    [self.pickerDelegate imagePickerControllerDidCancel:self];
    
    [self cleanAfterDismiss];
}

- (void)didFinishPickingVideo:(NSString *)videoPath assetGroupModel:(AssetsGroupModel *)assetGroupModel {
    lastAssertGroupIdentifier = assetGroupModel.localIdentifier;
    [self.pickerDelegate imagePickerController:self didFinishPickingVideo:videoPath];
    
    [self cleanAfterDismiss];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)cleanAfterDismiss {
   [AssetManager destroyAssetManager];
   [AssetModel finalize];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
