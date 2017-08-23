//
//  UIImage+Extension.h
//  student_iphone
//
//  Created by jyd on 2017/1/4.
//  Copyright © 2017年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color frame:(CGRect)frame;


///缩略图
+ (UIImage *)thumbImage:(UIImage *)image toRect:(CGSize)size;

@end
