//
//  ImageSelectIndicator.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSelectIndicator : UIView

@property (nonatomic, getter=isSelected) BOOL selected;

- (void)addTarget:(id)target action:(SEL)action;

@end
