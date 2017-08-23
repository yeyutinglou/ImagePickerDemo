//
//  AssetImageCell.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetModel.h"

@interface AssetImageCell : UICollectionViewCell

@property (nonatomic) AssetModel *assetModel;

@property (nonatomic, getter=isCellSelected) BOOL cellSelected;

- (void) addTarget:(id)target selectAction:(SEL)action showAction:(SEL)showAction;
@end
