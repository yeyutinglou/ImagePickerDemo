//
//  ImagePicker.h
//  ImagePickerDemo
//
//  Created by jyd on 2017/8/21.
//  Copyright © 2017年 jyd. All rights reserved.
//

#ifndef ImagePicker_h
#define ImagePicker_h
//1.自定义Log
#ifdef DEBUG
#define DYWLog(...) NSLog(__VA_ARGS__)
#else
#define DYWLog(...)
#endif

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

#define WEAK_SELF __weak typeof(self) weakSelf = self
#define STRONG_SELF if (!weakSelf) return; \
__strong typeof(weakSelf) strongSelf = weakSelf

#import "UIImage+Extension.h"


#endif /* ImagePicker_h */
