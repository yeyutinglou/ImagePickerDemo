//
//  ImagePickerController.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetModel.h"
#import "AssetsGroupModel.h"
#import "ImagePickerControllerDelegate.h"

@interface ImagePickerController : UINavigationController

@property (nonatomic, assign) NSInteger selectedNum;

@property (nullable, nonatomic, weak) id <ImagePickerControllerDelegate> pickerDelegate;

/**
 *  选取照片完成回调
 *
 *  @param assets 具体返回什么比如UIImage、AssetURL等根据项目需要决定，此处简单返回assetModels
 *  @param error
 */
- (void)didFinishPickingImages:(nonnull NSArray<AssetModel *> *)assets WithError:(nullable NSError *)error assetGroupModel:(nonnull AssetsGroupModel *)assetGroupModel;

- (void)didCancelPickingImages;

- (void)didFinishPickingVideo:(nonnull NSString *)videoPath assetGroupModel:(nonnull AssetsGroupModel *)assetGroupModel;



@end
