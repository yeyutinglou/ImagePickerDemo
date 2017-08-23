//
//  ImageDeleteController.h
//  student_iphone
//
//  Created by jyd on 2016/12/27.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetModel.h"
#import "AssetsGroupModel.h"

@protocol ImageDeleteDelegate <NSObject>

- (void)deleteImage:(NSArray *)allImages;

@end

@interface ImageDeleteController : UIViewController

@property (nonatomic) NSMutableArray *allImages;
@property (nonatomic) UIImage *curShowImage;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, assign) id<ImageDeleteDelegate>deleteDelegate;






@end


@interface UIView(Manipulation)
- (void)removeAllSubviews;
@end
