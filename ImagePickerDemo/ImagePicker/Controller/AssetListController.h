//
//  AssetListController.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetModel.h"
#import "AssetsGroupModel.h"


@interface AssetListController : UIViewController

@property (nonatomic, strong) NSMutableArray<AssetModel *> *allSelectdAssets;
@property (nonatomic, assign) NSInteger selectedNum;
@property (nonatomic) AssetsGroupModel *groupModel;



- (void)fetchData;




@end
