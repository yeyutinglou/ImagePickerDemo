//
//  AlbumListController.h
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface AlbumListController : UITableViewController

///已选个数
@property (nonatomic, assign) NSInteger selecedNum;

///刷新数据
- (void)refresh;

@end
