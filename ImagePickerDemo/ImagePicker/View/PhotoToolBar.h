//
//  PhotoToolBar.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, PhotoToolbarStyle) {
    kPhotoToolbarStyle1,
    kPhotoToolbarStyle2
};


@interface PhotoToolbar : UIView

@property (nonatomic) NSInteger number;

- (instancetype)initWithStyle:(PhotoToolbarStyle)style;

- (void)addTarget:(id)target previewAction:(SEL)action1 finishAction:(SEL)action2;

@end
