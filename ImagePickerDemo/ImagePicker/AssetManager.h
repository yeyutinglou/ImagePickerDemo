//
//  AssetManager.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetModel.h"
#import "AssetsGroupModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AuthorizationType) {
    kAuthorizationTypeNotDetermined = 0,
    kAuthorizationTypeRestricted,
    kAuthorizationTypeDenied,
    kAuthorizationTypeAuthorized
};


typedef void(^FetchAssetsGroupsSuccessBlock)();

typedef void(^FetchAssetsGroupsFailureBlock)(NSError * _Nullable error);


typedef void(^FetchAllAssetsSuccessBlock)(AssetsGroupModel * _Nonnull);


typedef void(^FetchAllAssetsFailureBlock)(NSError *_Nullable);


typedef void(^FetchImageAsyncCallBackBlock)(UIImage * _Nullable image, AssetModel * _Nullable assetModel);

typedef void (^FetchImageSyncCallBackBlock)(UIImage *_Nullable image, BOOL needBackgroundLoading);

typedef void (^CheckAuthorizationCompletionBlock)(AuthorizationType type);


@interface AssetManager : NSObject


@property (nonnull, nonatomic, readonly) NSArray<AssetsGroupModel *> *allAssetsGroups;


+ (nonnull instancetype)sharedAssetManager;
+ (void) destroyAssetManager;

- (AssetsGroupModel *)assetsGroupModelForLocalIdentifier:(NSString *)localIdentifier;


//异步获取所有相册
- (void)fetchAllAssetsGroups:(nonnull FetchAssetsGroupsSuccessBlock)sucessCallback failureBlock:(nullable FetchAssetsGroupsFailureBlock)failureCallback;

//异步获取相册下所有照片
- (void)fetchAllAssetsInGroup:(nonnull AssetsGroupModel *)groupModel successBlock:(nullable FetchAllAssetsSuccessBlock)successCallback failureBlock:(nullable FetchAllAssetsFailureBlock)failureCallback;

- (void)fetchImageFromAssetModel:(nonnull AssetModel *)assetModel asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback syncBlock:(nullable FetchImageSyncCallBackBlock)syncCallback;

- (void)chechAuthorizationStatus:(nonnull CheckAuthorizationCompletionBlock)completion;

- (NSData *)fetchImageDataFromAssetModel:(AssetModel *)model;

- (AssetModel *)fetchAssetModelWithURL:(NSURL *)url;

-(void)fetchFullScreenImageWithURL:(NSURL *)url asyncBlock:(nullable FetchImageAsyncCallBackBlock)asyncCallback syncBlock:(nullable FetchImageSyncCallBackBlock)syncCallback;

- (void)fetchThumbmailImageWithURL:(NSURL *)url pointSize:(CGSize)size completion:(nonnull void (^)(UIImage * _Nullable, AssetModel *))completionCallback;


#pragma mark - 获取视频 -
//获取视频PlayerItem，如果视频文件不存在，返回的AVPlayerItem为nil
- (void)getVideoPlayerItemForAssetModel:(AssetModel *)assetModel completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion;

- (void)getVideoAssetForAssetModel:(AssetModel *)assetModel completion:(void (^)(AVURLAsset *videoAsset))completion;

NS_ASSUME_NONNULL_END


@end
