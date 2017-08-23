//
//  AssetsGroupModel.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "AssetsGroupModel.h"

@interface AssetsGroupModel ()

@property (nonatomic) UIImage *posterImage;

@end

@implementation AssetsGroupModel


- (UIImage *)syncFetchPosterImageWithPointSize:(CGSize)size {
    if (_posterImage == nil) {
        if (self.assetsGroup_PH) {
            PHFetchResult *groupResult = [PHAsset fetchAssetsInAssetCollection:self.assetsGroup_PH options:nil];
            
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            requestOptions.synchronous = YES;
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize pixSize = CGSizeMake(size.width * scale, size.height * scale);
            
            __block UIImage *resultImage = nil;
            [[PHImageManager defaultManager] requestImageForAsset:groupResult.lastObject targetSize:pixSize contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                resultImage = result;
            }];
            _posterImage = resultImage;
        } else if (self.assetsGroup_AL) {
            _posterImage = [UIImage imageWithCGImage:self.assetsGroup_AL.posterImage];
        }
    }
    
    return _posterImage;
}

- (NSString *)localIdentifier {
    if (self.assetsGroup_PH) {
        return self.assetsGroup_PH.localIdentifier;
    } else {
        return [self.assetsGroup_AL valueForProperty:ALAssetsGroupPropertyPersistentID];
    }
}

@end
