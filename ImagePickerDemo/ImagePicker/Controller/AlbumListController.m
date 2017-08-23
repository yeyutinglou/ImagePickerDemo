//
//  AlbumListController.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "AlbumListController.h"
#import "AssetManager.h"
#import "ImagePickerController.h"
#import "AssetListController.h"

#define TABLE_CELL_HEIGHT 57

@interface ImagePickerTableViewCell : UITableViewCell

@end

@implementation ImagePickerTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect imgFrame = self.imageView.frame;
    imgFrame.origin.x = 0;
    self.imageView.frame = imgFrame;
    
    CGRect textFrame = self.textLabel.frame;
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(imgFrame)+7, CGRectGetMinY(textFrame), CGRectGetWidth(textFrame), CGRectGetHeight(textFrame));
}

@end


@interface AlbumListController ()

@end

@implementation AlbumListController {
    CGSize posterImageSize;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        posterImageSize = CGSizeMake(TABLE_CELL_HEIGHT, TABLE_CELL_HEIGHT);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    
    [self setupViews];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}


- (void)setupViews {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 5;
    
    self.navigationItem.rightBarButtonItems = @[spaceItem, item];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.rowHeight = TABLE_CELL_HEIGHT;
}

- (void)doCancel {
    [(ImagePickerController *)(self.navigationController) didCancelPickingImages];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)refresh {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [AssetManager sharedAssetManager].allAssetsGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"Cell";
    ImagePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[ImagePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    AssetsGroupModel *groupModel = [AssetManager sharedAssetManager].allAssetsGroups[indexPath.row];
    NSString *countStr = [NSString stringWithFormat:@"(%lu)", (unsigned long)groupModel.numberOfAssets];
    NSString *str = [NSString stringWithFormat:@"%@  %@", groupModel.assetsGroupName, countStr];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range = [str rangeOfString:countStr];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range: range];
    [attributeString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range: NSMakeRange(0, range.location-2)];
    
    cell.textLabel.attributedText = attributeString;
    
    cell.imageView.image = [groupModel syncFetchPosterImageWithPointSize:posterImageSize];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AssetsGroupModel *model = [AssetManager sharedAssetManager].allAssetsGroups[indexPath.row];
    
    AssetListController *assetListVC = [[AssetListController alloc] init];
    assetListVC.groupModel = model;
    assetListVC.allSelectdAssets = [[NSMutableArray alloc] init];
    assetListVC.selectedNum = self.selecedNum;
    
    [self.navigationController pushViewController:assetListVC animated:YES];
    
}

@end
