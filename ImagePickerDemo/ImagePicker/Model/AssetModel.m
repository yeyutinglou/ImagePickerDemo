//
//  AssetModel.m
//  student_iphone
//
//  Created by jyd on 2016/12/23.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "AssetModel.h"


static NSInteger assetIndex = 0;
static PHImageRequestOptions *requestOptions;

@implementation AssetModel

- (instancetype)init {
    if (self = [super init]) {
        _isAssetInLocalAlbum = YES;
        _assetIndex = assetIndex++;
    }
    return self;
}

+ (void)finalize {
    requestOptions = nil;
}

- (void)setAsset_PH:(PHAsset *)asset_PH {
    _asset_PH = asset_PH;
    
    if (!_asset_PH) {
        _assetMediaType = kAssetMediaTypeUnknown;
    } else {
        switch (_asset_PH.mediaType) {
            case PHAssetMediaTypeImage:
                _assetMediaType = kAssetMediaTypeImage;
                break;
            case PHAssetMediaTypeVideo:
                _assetMediaType =  kAssetMediaTypeVideo;
                break;
            default:
                _assetMediaType = kAssetMediaTypeOther;
                break;
        }
    }
}


- (void)setAsset_AL:(ALAsset *)asset_AL {
    _asset_AL = asset_AL;
    
    if (!asset_AL) {
        _asset_AL = kAssetMediaTypeUnknown;
    } else {
        NSString *assetType = [_asset_AL valueForProperty:ALAssetPropertyType];
        if ([assetType isEqualToString:ALAssetTypePhoto]) {
            _assetMediaType = kAssetMediaTypeImage;
        }else if ([assetType isEqualToString:ALAssetTypeVideo]) {
            _assetMediaType = kAssetMediaTypeVideo;
        }else if ([assetType isEqualToString:ALAssetTypeUnknown]) {
            _assetMediaType = kAssetMediaTypeUnknown;
        }else {
            _assetMediaType = kAssetMediaTypeOther;
        }
    }
    
}

+ (PHImageRequestOptions *)requestOptions {
    if (!requestOptions) {
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        requestOptions.synchronous = NO;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return requestOptions;
}

- (void)fetchThumbnailWithPointSize:(CGSize)size completion:(void (^)(UIImage * _Nullable, AssetModel * _Nonnull))completionCallback {
    if (!_isAssetInLocalAlbum) {
        completionCallback(nil, self);
        return;
    }
    
    if (_asset_PH) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize pixelSize = CGSizeMake(scale * size.width, scale * size.height);
        WEAK_SELF;
        [[PHImageManager defaultManager] requestImageForAsset:self.asset_PH targetSize:pixelSize contentMode: PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            STRONG_SELF;
            weakSelf.isAssetInLocalAlbum = (result != nil);
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downloadFinined) {
                completionCallback(result,strongSelf);
            }

        }];
    } else {
        CGImageRef thumbnail = [self.asset_AL thumbnail];
        self.isAssetInLocalAlbum = (thumbnail != NULL);
        completionCallback(thumbnail ? [UIImage imageWithCGImage:thumbnail] : nil, self);
    }
}




- (NSString *)duration {
    if (self.assetMediaType != kAssetMediaTypeVideo) {
        return @"";
    }
    
    if (!_duration) {
        CGFloat duration = 0;
        if (self.asset_PH) {
            duration = _asset_PH.duration;
        } else if (self.asset_AL) {
            duration = [[_asset_AL valueForProperty:ALAssetPropertyDuration] doubleValue];
        }
        _duration = [self.class getDurationString:round(duration)];
    }
    return _duration;
}

+ (NSString *)getDurationString:(NSInteger)duration {
    NSInteger minutes = duration / 60;
    NSInteger secounds = duration % 60;
    NSString *ret = [NSString stringWithFormat:@"%ld:%02ld",(long)minutes,(long)secounds];
    return ret;
}

- (CGSize)imageSize {
    if (self.asset_PH) {
        return CGSizeMake(self.asset_PH.pixelWidth, self.asset_PH.pixelHeight);
    } else {
        return self.asset_AL.defaultRepresentation.dimensions;
    }
}

@end
