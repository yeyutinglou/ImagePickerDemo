//
//  AssetManager.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "AssetManager.h"



static AssetManager *_instance;

#define QUEUE_LABEL "FETCH_IMAGE_QUEUE"

//用户拒绝访问照片库错误码
#define USER_DENIED_ACCESS_ERROR_CODE -3311

//50 * 1024 * 1024
static long long  MAX_ACCEPT_BITMAP_SIZE = 52428800;
//最多有三个后台线程在获取照片
#define SEMAPHORE_NUM 3

//使用AssetLibrary框架时，缓存图片的最大数目
#define CACHE_COUNT_LIMIT 8

@interface AssetManager ()

@property (nonatomic) NSMutableArray<AssetsGroupModel *> *allAssetsGroups_m;
@property (nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) PHImageRequestOptions *fullResolutionRequestOptions;
@property (nonatomic) PHImageRequestOptions *requestOptions;

@property (nonatomic) NSCache *imagesCache;
@property (nonatomic) dispatch_semaphore_t semaphore;
@property (nonatomic) dispatch_queue_t fetchImageQueue;
@property (nonatomic) NSMutableArray<NSNumber *> *loadingAssetIndexes;

@property (nonatomic, copy) CheckAuthorizationCompletionBlock authorizationBlock;

@end

@implementation AssetManager {
    CGSize thumbmainSize;
}


+ (instancetype)sharedAssetManager {
    if (!_instance) {
        _instance = [[AssetManager alloc] init];
    }
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _allAssetsGroups_m = [[NSMutableArray alloc] init];
        _imageManager = [[PHCachingImageManager alloc] init];
        
        _fullResolutionRequestOptions = [[PHImageRequestOptions alloc] init];
        _fullResolutionRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        _fullResolutionRequestOptions.synchronous = YES;
        _fullResolutionRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        _requestOptions = [[PHImageRequestOptions alloc] init];
        _requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        _requestOptions.synchronous = NO;
        _requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        _loadingAssetIndexes = [[NSMutableArray alloc] init];
        _imagesCache = [[NSCache alloc] init];
        _imagesCache.countLimit = CACHE_COUNT_LIMIT;
        _semaphore = dispatch_semaphore_create(SEMAPHORE_NUM);
        _fetchImageQueue = dispatch_queue_create(QUEUE_LABEL, DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (ALAssetsLibrary *)assetsLibrary {
    static ALAssetsLibrary *_assetsLibrary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    
    return _assetsLibrary;
}

- (NSArray<AssetsGroupModel *> *)allAssetsGroups {
    return _allAssetsGroups_m;
}

+ (void)destroyAssetManager {
    _instance = nil;
}

#pragma mark - 检测相册权限

- (void)chechAuthorizationStatus:(CheckAuthorizationCompletionBlock)block {
    self.authorizationBlock = block;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [self checkAuthorizationStatus_PhotoKit];
    }else {
        [self checkAuthorizationStatus_AssetLibrary];
    }
}


- (void)checkAuthorizationStatus_AssetLibrary {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status)
    {
        case ALAuthorizationStatusAuthorized:
            self.authorizationBlock(kAuthorizationTypeAuthorized);
            break;
        case ALAuthorizationStatusDenied:
        case ALAuthorizationStatusRestricted:
            self.authorizationBlock(kAuthorizationTypeDenied);
            break;
        case ALAuthorizationStatusNotDetermined:
            self.authorizationBlock(kAuthorizationTypeNotDetermined);
            break;
    }
    
}

- (void)checkAuthorizationStatus_PhotoKit {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status)
    {
        case PHAuthorizationStatusNotDetermined:
            self.authorizationBlock(kAuthorizationTypeNotDetermined);
            [self requestAuthorizationStatus_PhotoKit];
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            self.authorizationBlock(kAuthorizationTypeDenied);
            break;
        case PHAuthorizationStatusAuthorized:
            self.authorizationBlock(kAuthorizationTypeAuthorized);
            break;
    }
    
}

//如果用户已经获取过权限了，则同步执行block，否则弹出获取权限对话框
//待用户做出选择后，异步执行block，在block中通过参数status获取用户授权结果
- (void)requestAuthorizationStatus_PhotoKit
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    self.authorizationBlock(kAuthorizationTypeAuthorized);
                    break;
                default:
                    self.authorizationBlock(kAuthorizationTypeDenied);
                    break;
            }
        });
    }];
}


#pragma mark - 获取全部相册

- (void)fetchAllAssetsGroups:(FetchAssetsGroupsSuccessBlock)sucessCallback failureBlock:(FetchAssetsGroupsFailureBlock)failureCallback {
    
    //IOS8及其上系统，采用Photos框架, 框架是同步获取全部相册
    //这里采用异步调用
    if ([self canUsePhotoKit]) {
        WEAK_SELF;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf fetchAllAssetsGroups_PhotoKit];
            if (sucessCallback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sucessCallback();
                });
            }
            
        });
    }else {
        //小于IOS8系统，采用AssetsLibrary框架, 框架是异步获取全部相册
        //这里直接同步调用即可
        [self fetchAllAssetsGroups_AssetLibrary:sucessCallback failureBlock:failureCallback];
    }
}

- (void)fetchAllAssetsGroups_AssetLibrary:(FetchAssetsGroupsSuccessBlock)sucessCallback failureBlock:(FetchAssetsGroupsFailureBlock)failureCallback {
    
    WEAK_SELF;
    void (^enummerateBlock)(ALAssetsGroup*, BOOL*) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter: [ALAssetsFilter allAssets]];
            
            if (group.numberOfAssets > 0) {
                AssetsGroupModel *groupModel = [[AssetsGroupModel alloc] init];
                groupModel.assetsGroup_AL = group;
                groupModel.numberOfAssets = group.numberOfAssets;
                groupModel.assetsGroupName = [group valueForProperty:ALAssetsGroupPropertyName];
                
                //把相册交卷放到第一个位置
                if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                    [weakSelf.allAssetsGroups_m insertObject:groupModel atIndex:0];
                }else {
                    [weakSelf.allAssetsGroups_m addObject:groupModel];
                }
            }
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                sucessCallback();
            });
        }
        
    };
    
    void (^failureBlock)(NSError *) = ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureCallback)failureCallback(error);
            if (error.code == USER_DENIED_ACCESS_ERROR_CODE) {
                weakSelf.authorizationBlock(kAuthorizationTypeDenied);
            }
            
        });
    };
    
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupLibrary
                                      usingBlock:enummerateBlock failureBlock:failureBlock];
    
}

- (void)fetchAllAssetsGroups_PhotoKit {
    void (^enumerateBlock)(PHAssetCollection *, NSUInteger idx, BOOL *) = ^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (collection.estimatedAssetCount == 0) {
            return ;
        }
        
        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        NSUInteger numberOfAssets = [assetsResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        
        numberOfAssets += [assetsResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        
        if (numberOfAssets == 0) {
            return;
        }
        
        AssetsGroupModel *groupModel = [[AssetsGroupModel alloc] init];
        groupModel.assetsGroup_PH = collection;
        groupModel.numberOfAssets = numberOfAssets;
        groupModel.assetsGroupName = collection.localizedTitle;
        
        [self.allAssetsGroups_m addObject:groupModel];
    };
    
    PHAssetCollectionSubtype smartSubtypes[] = {
        PHAssetCollectionSubtypeSmartAlbumUserLibrary,
        PHAssetCollectionSubtypeSmartAlbumScreenshots,
        PHAssetCollectionSubtypeSmartAlbumRecentlyAdded,
        PHAssetCollectionSubtypeSmartAlbumFavorites,
        PHAssetCollectionSubtypeSmartAlbumVideos
    };
    
    for (int i = 0; i < 5; i++) {
        PHFetchResult *userSmartAlbumsResult = [PHAssetCollection
                                                fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                subtype:smartSubtypes[i]
                                                options:nil];
        [userSmartAlbumsResult enumerateObjectsUsingBlock:enumerateBlock];
    }
    
    //获取用户自己建立的相册
    PHAssetCollectionSubtype albumSubtypes[] = {
        PHAssetCollectionSubtypeAlbumRegular,
        PHAssetCollectionSubtypeAlbumImported,
        PHAssetCollectionSubtypeAlbumSyncedAlbum
    };
    
    for (int i = 0; i < 3; i++) {
        PHFetchResult *userAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                                   subtype:albumSubtypes[i]
                                                                                   options:nil];
        [userAlbumsResult enumerateObjectsUsingBlock:enumerateBlock];
    }
    
}

- (AssetsGroupModel *)assetsGroupModelForLocalIdentifier:(NSString *)localIdentifier {
    if ([self canUsePhotoKit]) {
        if (!localIdentifier) {
            for (AssetsGroupModel *groupModel in self.allAssetsGroups_m) {
                if ((groupModel.assetsGroup_PH.assetCollectionType == PHAssetCollectionTypeSmartAlbum) && (groupModel.assetsGroup_PH.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)) {
                    return groupModel;
                }
            }
        }else {
            for (AssetsGroupModel *groupModel in self.allAssetsGroups_m) {
                if ([groupModel.assetsGroup_PH.localIdentifier isEqualToString:localIdentifier]) {
                    return groupModel;
                }
            }
        }
    }else {
        if (!localIdentifier) {
            for (AssetsGroupModel *groupModel in self.allAssetsGroups_m) {
                if ([[groupModel.assetsGroup_AL valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                    return groupModel;
                }
            }
        }else {
            for (AssetsGroupModel *groupModel in self.allAssetsGroups_m) {
                if ([[groupModel.assetsGroup_AL valueForProperty:ALAssetsGroupPropertyPersistentID] isEqualToString:localIdentifier]) {
                    return groupModel;
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - 获取相册下所有照片

- (void)fetchAllAssetsInGroup:(AssetsGroupModel *)groupModel successBlock:(nullable FetchAllAssetsSuccessBlock)successCallback failureBlock:(nullable FetchAllAssetsFailureBlock)failureCallback {
    
    //该相册已经获取过了
    if (groupModel.allAssets.count > 0) {
        if (successCallback)successCallback(groupModel);
        return;
    }
    
    //以下两个方法均为同步获取相册里所有照片,获取到Model放在groupModel下
    //在后台线程里调用
    WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self canUsePhotoKit]) {
            [weakSelf fetchAllAssetsInGroup_PhotoKit:groupModel];
        }else {
            [weakSelf fetchAllAssetsInGroup_AssetLibrary:groupModel];
        }
        
        if (successCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successCallback(groupModel);
            });
        }
    });
}

- (void)fetchAllAssetsInGroup_AssetLibrary:(AssetsGroupModel *)groupModel {
    ALAssetsGroup *group = groupModel.assetsGroup_AL;
    if (group == nil)return;
    
    if (!groupModel.allAssets) {
        groupModel.allAssets = [[NSMutableArray alloc] init];
    }
    
    __block NSInteger numberOfAssets = 0;
    //该方法为同步执行，不是异步
    [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset){
            AssetModel *assetModel = [[AssetModel alloc] init];
            assetModel.asset_AL = asset;
            
            [groupModel.allAssets addObject:assetModel];
            numberOfAssets ++;
        }
    }];
    
}

- (void)fetchAllAssetsInGroup_PhotoKit:(AssetsGroupModel *)groupModel {
    if (groupModel.assetsGroup_PH == nil)return;
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType == %d", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
    
    PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:groupModel.assetsGroup_PH options:fetchOptions];
    
    if (!groupModel.allAssets) {
        groupModel.allAssets = [[NSMutableArray alloc] init];
    }
    
    __block NSInteger numberOfAssets = 0;
    //该方法为同步执行, This method executes synchronously.
    [assetsResult enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger index, BOOL * _Nonnull stop) {
        if (asset) {
            AssetModel *assetModel = [[AssetModel alloc] init];
            assetModel.asset_PH = asset;
            
            [groupModel.allAssets addObject:assetModel];
            numberOfAssets ++;
        }
        
    }];
    
}



#pragma mark - 加载单张图片

- (void)fetchImageFromAssetModel:(AssetModel *)assetModel asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback syncBlock:(nullable FetchImageSyncCallBackBlock)syncCallback {
    
    if ([self canUsePhotoKit]) {
        [self fetchImageFromAssetModel_PhotoKit:assetModel asyncBlock:asyncCallback syncBlock:syncCallback];
        
    }else {
        [self fetchImageFromAssetModel_AssetLibrary:assetModel asyncBlock:asyncCallback syncBlock:syncCallback];
    }
}


- (void)fetchImageFromAssetModel_PhotoKit:(AssetModel *)assetModel asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback syncBlock:(nullable FetchImageSyncCallBackBlock)syncCallback {
    
    PHAsset *asset = assetModel.asset_PH;
    
    if ([self needFetchFullResolutionImage:CGSizeMake(asset.pixelWidth, asset.pixelHeight)]) {
        syncCallback(nil, YES);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [_imageManager requestImageForAsset:assetModel.asset_PH
                                     targetSize:PHImageManagerMaximumSize
                                    contentMode:PHImageContentModeDefault
                                        options:_fullResolutionRequestOptions
                                  resultHandler:^(UIImage *image, NSDictionary *info) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          assetModel.isAssetInLocalAlbum = (image != nil);
                                          asyncCallback(image, assetModel);
                                      });
                                  }];
            
        });
    }else {
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageHeight = floor((kWidth/asset.pixelWidth) * asset.pixelHeight);
        CGSize pixSize = CGSizeMake(kHeight * scale, imageHeight * scale);
        
        [_imageManager requestImageForAsset:assetModel.asset_PH targetSize:pixSize contentMode:PHImageContentModeAspectFill options:_requestOptions resultHandler:^(UIImage *image, NSDictionary *info) {
            assetModel.isAssetInLocalAlbum = (image != nil);
            dispatch_async(dispatch_get_main_queue(), ^{
                asyncCallback(image, assetModel);
            });
        }];
        
    }
    
}


- (void)fetchImageFromAssetModel_AssetLibrary:(AssetModel *)assetModel asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback syncBlock:(nullable FetchImageSyncCallBackBlock)syncCallback {
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)assetModel.assetIndex];
    UIImage *image = [_imagesCache objectForKey:key];
    
    if (image) {
        syncCallback(image, NO);
    }else {
        ALAssetRepresentation *representation = [assetModel.asset_AL defaultRepresentation];
        
        if ([self needFetchFullResolutionImage:representation.dimensions]) {
            syncCallback(nil, YES);
            [self fetchImageInBackground:assetModel isFullResolution:YES asyncBlock:asyncCallback];
        }else {
            image = [[UIImage alloc] initWithCGImage:assetModel.asset_AL.aspectRatioThumbnail];
            
            syncCallback(image, YES);
            [self fetchImageInBackground:assetModel isFullResolution:NO asyncBlock:asyncCallback];
        }
        
    }
    
}



- (BOOL)needFetchFullResolutionImage:(CGSize)dimensions {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat maxSize = kHeight * scale;
    CGSize imageSize = dimensions;
    if (imageSize.width > maxSize) {
        imageSize.height *= maxSize / imageSize.width;
        imageSize.width = maxSize;
    }
    if (imageSize.height > maxSize) {
        imageSize.width *= maxSize / imageSize.height;
        imageSize.height = maxSize;
    }
    
    if (fabs(dimensions.width - imageSize.width) <= 3)
        return NO;
    
    if (dimensions.width * dimensions.height * 4 >= MAX_ACCEPT_BITMAP_SIZE)
        return NO;
    
    if (imageSize.height * 4 < maxSize || imageSize.width * 4 < scale * kWidth)
        return YES;
    
    return NO;
}


- (void)fetchImageInBackground:(AssetModel *)assetModel isFullResolution:(BOOL)isFullResolution asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback {
    if ([_loadingAssetIndexes containsObject:@(assetModel.assetIndex)]) return;
    
    __weak typeof(self) weakSelf = self;
    
    void (^fetchImageBlock)() = ^() {
        if (weakSelf == nil)return;
        dispatch_semaphore_wait(weakSelf.semaphore, DISPATCH_TIME_FOREVER);
        
        ALAssetRepresentation *representation = [assetModel.asset_AL defaultRepresentation];
        
        UIImage *image;
        if (isFullResolution) {
            image = [[UIImage alloc] initWithCGImage:[representation fullResolutionImage] scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
        }else {
            image = [[UIImage alloc] initWithCGImage:[representation fullScreenImage]];
        }
        
        NSString *key = [NSString stringWithFormat:@"%ld", (long)assetModel.assetIndex];
        if (image)
            [weakSelf.imagesCache setObject:image forKey:key];
        [weakSelf.loadingAssetIndexes removeObject:@(assetModel.assetIndex)];
        
        dispatch_semaphore_signal(weakSelf.semaphore);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            asyncCallback(image, assetModel);
        });
        
    };
    
    
    [_loadingAssetIndexes addObject:@(assetModel.assetIndex)];
    
    dispatch_async(_fetchImageQueue, fetchImageBlock);
}

#pragma mark - 获取照片Data
- (NSData *)fetchImageDataFromAssetModel:(AssetModel *)model {
    __block NSData *data;
    if (model.asset_AL) {
        ALAssetRepresentation* assetRepresentation = [model.asset_AL defaultRepresentation];
        CGImageRef imageRef = assetRepresentation.fullResolutionImage;
        UIImage *image = [UIImage imageWithCGImage:imageRef
                                             scale:assetRepresentation.scale
                                       orientation:(UIImageOrientation)assetRepresentation.orientation];
        data = UIImageJPEGRepresentation(image, 1);
        
    }else if (model.asset_PH) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset_PH
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             data = imageData;
         }];
    }
    
    return data;
}


- (AssetModel *)fetchAssetModelWithURL:(NSURL *)url {
    PHFetchResult<PHAsset *> *result =  [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    if (!result || result.count == 0) return nil;
    
    PHAsset *asset = [result firstObject];
    AssetModel *model = [[AssetModel alloc] init];
    model.asset_PH = asset;
    
    return model;
}

-(void)fetchFullScreenImageWithURL:(NSURL *)url asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback syncBlock:(nullable FetchImageSyncCallBackBlock)syncCallback {
    AssetModel *model = [self fetchAssetModelWithURL:url];
    if (!model)return;
    
    [self fetchImageFromAssetModel_PhotoKit:model
                                 asyncBlock:asyncCallback
                                  syncBlock:syncCallback];
    
}

- (void)fetchThumbmailImageWithURL:(NSURL *)url pointSize:(CGSize)size completion:(nonnull void (^)(UIImage * _Nullable, AssetModel *assetModel))completionCallback {
    AssetModel *model = [self fetchAssetModelWithURL:url];
    if (!model)return;
    
    [model fetchThumbnailWithPointSize:size
                            completion:completionCallback];
}


#pragma mark - Video -

- (void)getVideoPlayerItemForAssetModel:(AssetModel *)assetModel completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion {
    if (assetModel.asset_PH) {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:assetModel.asset_PH options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion)
                completion(playerItem,info);
        }];
    }else if (assetModel.asset_AL) {
        NSURL *videoURL = [assetModel.asset_AL valueForProperty:ALAssetPropertyAssetURL];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        if (completion)
            completion(playerItem,nil);
    }
}


- (void)getVideoAssetForAssetModel:(AssetModel *)assetModel completion:(void (^)(AVURLAsset *videoAsset))completion {
    if (assetModel.asset_PH) {
        PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = NO;
        [[PHImageManager defaultManager] requestAVAssetForVideo:assetModel.asset_PH options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
            AVURLAsset *videoAsset = (AVURLAsset*)avasset;
            if (completion)
                completion(videoAsset);
        }];
    }else if (assetModel.asset_AL) {
        NSURL *videoURL = [assetModel.asset_AL valueForProperty:ALAssetPropertyAssetURL];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        if (completion)
            completion(videoAsset);
    }
}


- (BOOL)canUsePhotoKit {
    return [[UIDevice currentDevice].systemVersion floatValue] >= 8.0;
}

@end
