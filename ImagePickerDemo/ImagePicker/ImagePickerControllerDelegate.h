//
//  Delegate.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetModel.h"
@class ImagePickerController;
@protocol ImagePickerControllerDelegate <NSObject>


/**
 *  选取结束，返回选择的照片数据
 *  由ImagePickerController的调用者负责dismissImagePickerController
 *
 */
- (void)imagePickerController:(nonnull ImagePickerController *)picker didFinishPickingImages:(nullable NSArray<AssetModel *> *)assets withError:(nullable NSError *)error;

/**
 *  取消选择
 *  由ImagePickerController的调用者负责dismissImagePickerController
 *
 */
- (void)imagePickerControllerDidCancel:(nonnull ImagePickerController *)picker;


- (void)imagePickerController:(nonnull ImagePickerController *)picker didFinishPickingVideo:(nonnull NSString *)videoPath;

@end
