//
//  ImageScrollView.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetModel.h"


#define MinimumZoomScale 1
#define MaximumZoomScale 2


@interface ImageScrollView : UIScrollView

@property (nonatomic) NSInteger assetIndex;
@property (nonatomic) AssetModel *assetModel;

@property (nonatomic) CGSize imageSize;

@property (nonatomic, readonly) BOOL isImageExist;

@property (nonatomic) UIImageView *imageView;

- (void)setContentWithImage:(UIImage *)image;

@end
