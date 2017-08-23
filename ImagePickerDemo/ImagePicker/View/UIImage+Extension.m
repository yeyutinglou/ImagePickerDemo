//
//  UIImage+Extension.m
//  student_iphone
//
//  Created by jyd on 2017/1/4.
//  Copyright © 2017年 he chao. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)


+ (UIImage *)imageWithColor:(UIColor *)color frame:(CGRect)frame {
    UIGraphicsBeginImageContext(frame.size);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, color.CGColor);
    CGContextFillRect(contextRef, frame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (UIImage *)thumbImage:(UIImage *)image toRect:(CGSize)size
{
    //被切图片宽比例比高比例小 或者相等，以图片宽进行放大
    if (image.size.width*size.height <= image.size.height*size.width) {
        
        //以被剪裁图片的宽度为基准，得到剪切范围的大小
        CGFloat width  = image.size.width;
        CGFloat height = image.size.width * size.height / size.width;
        
        // 调用剪切方法
        // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
        UIImage *clipImage =  [self imageFromImage:image inRect:CGRectMake(0, (image.size.height -height)/2, width, height)];
        return [self scaleToImage:clipImage Width:size];
        
    }else{ //被切图片宽比例比高比例大，以图片高进行剪裁
        
        // 以被剪切图片的高度为基准，得到剪切范围的大小
        CGFloat width  = image.size.height * size.width / size.height;
        CGFloat height = image.size.height;
        
        // 调用剪切方法
        // 这里是以中心位置剪切，也可以通过改变rect的x、y值调整剪切位置
        UIImage *clipImage =  [self imageFromImage:image inRect:CGRectMake((image.size.width -width)/2, 0, width, height)];
        return  [self scaleToImage:clipImage Width:size];
    }
    return nil;

}

+ (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //将UIImage转换成CGImageRef
    CGImageRef sourceImageRef = [image CGImage];
    
    //按照给定的矩形区域进行剪裁
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    
    //将CGImageRef转换成UIImage
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    //返回剪裁后的图片
    return newImage;
}

+ (UIImage *)scaleToImage:(UIImage *)image Width:(CGSize)size{
    
    // 如果传入的宽度比当前宽度还要大,就直接返回
    
    
    if (size.width > image.size.width) {
        return  image;
    }
    
//    // 计算缩放之后的高度
//    CGFloat height = (size.width / image.size.width) * image.size.height;
    
    // 初始化要画的大小
    CGRect  rect = CGRectMake(0, 0, size.width, size.height);
    
    //清晰图提升
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, [UIScreen mainScreen].scale);
    
    // 1. 开启图形上下文
    //    UIGraphicsBeginImageContext(rect.size);
    
    // 2. 画到上下文中 (会把当前image里面的所有内容都画到上下文)
    [image drawInRect:rect];
    
    // 3. 取到图片
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 4. 关闭上下文
    UIGraphicsEndImageContext();
    // 5. 返回
    return newImage;
}




@end
