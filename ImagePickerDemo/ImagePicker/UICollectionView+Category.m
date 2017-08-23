//
//  UICollectionView+Category.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "UICollectionView+Category.h"

@implementation UICollectionView (Category)

- (void)scrollsToBottomAnimated:(BOOL)animated {
    NSInteger sectionCount = [self.dataSource numberOfSectionsInCollectionView:self];
    if (sectionCount < 1)
        return;
    
    NSInteger count = [self.dataSource collectionView:self numberOfItemsInSection:sectionCount - 1];
    if (count < 1)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count - 1 inSection:sectionCount - 1];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
    if (cell) {
        CGFloat offsetY = self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.frame);
        if (offsetY < -self.contentInset.top)
            offsetY = -self.contentInset.top;
        
        [self setContentOffset:CGPointMake(0, offsetY) animated:animated];
    }else {
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
    }
}


@end
