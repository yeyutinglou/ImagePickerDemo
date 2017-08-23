//
//  AssetModel.h
//  student_iphone
//
//  Created by jyd on 2016/12/23.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;
@import AssetsLibrary;

typedef NS_ENUM(NSUInteger, AssetMediaType) {
    kAssetMediaTypeUnknown, //未知
    kAssetMediaTypeImage,   //照片
    kAssetMediaTypeVideo,   //视频
    kAssetMediaTypeOther,   //其他暂不支持的格式
};

@interface AssetModel : NSObject

@property (nonatomic, readonly) NSInteger assetIndex;

@property (nullable, nonatomic) PHAsset *asset_PH;

@property (nullable, nonatomic) ALAsset *asset_AL;


@property (nonatomic, readonly) AssetMediaType assetMediaType;

@property (nonatomic) BOOL isAssetInLocalAlbum;

@property (nullable, nonatomic, copy) NSString *duration;

- (void)fetchThumbnailWithPointSize:(CGSize)size completion:(nonnull void(^)(UIImage * _Nullable image, AssetModel * _Nonnull assetModel))completionCallback;

- (CGSize)imageSize;

+ (void)finalize;

@end
