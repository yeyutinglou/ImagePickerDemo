//
//  ImagePickerConfig.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#ifndef ImagePickerConfig_h
#define ImagePickerConfig_h


//大图方式展示照片时，每张图片之间的间隔
#define INTERVAL 25

//最多可以选取的照片
#define MAX_PHOTOS_CAN_SELECT 9

#define DEFAULT_NAVIGATION_BAR_ALPHA 0.9

#define DEFAULT_BUTTON_NORMAL_COLOR [UIColor colorWithRed:19/255.0 green:175/255.0 blue:36/255.0 alpha:1]

#define DEFAULT_BUTTON_DISABLED_COLOR [UIColor colorWithRed:33/255.0 green:83/255.0 blue:47/255.0 alpha:1]
#define IMAGE_NAME(name) [NSString stringWithFormat:@"ImagePicker.bundle/%@", name]
#endif /* ImagePickerConfig_h */
