//
//  AssetsGroupModel.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetModel.h"
@import AssetsLibrary;
@import Photos;

@interface AssetsGroupModel : NSObject

@property (nonatomic) NSUInteger numberOfAssets;

@property (nonatomic) NSMutableArray<AssetModel *> *allAssets;

@property (nonatomic, copy) NSString *assetsGroupName;

@property (nonatomic) PHAssetCollection *assetsGroup_PH;

@property (nonatomic) ALAssetsGroup *assetsGroup_AL;


- (UIImage *)syncFetchPosterImageWithPointSize:(CGSize)
size;

- (NSString *)localIdentifier;

@end
