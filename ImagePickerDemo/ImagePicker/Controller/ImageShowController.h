//
//  ImageShowController.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetModel.h"
#import "AssetsGroupModel.h"
@interface ImageShowController : UIViewController

@property (nonatomic) AssetsGroupModel *assetGroupModel;
@property (nonatomic) NSArray<AssetModel *> *allAssets;
@property (nonatomic) NSMutableArray<AssetModel *> *allSelectdAssets;
@property (nonatomic) AssetModel *curShowAsset;

@property (nonatomic, assign) NSInteger selectedNum;

@end
