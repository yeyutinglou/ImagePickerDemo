//
//  AssetVideoCell.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "AssetVideoCell.h"

#define BOTTOM_BAR_HEIGHT 17

@interface AssetVideoCell ()

@property (nonatomic) UIImageView *imageView;

@property (nonatomic) UIView *bottomView;

@property (nonatomic) UILabel *durationLabel;

@end

@implementation AssetVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        self.clipsToBounds = YES;
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - BOTTOM_BAR_HEIGHT, CGRectGetWidth(frame), BOTTOM_BAR_HEIGHT)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [self.contentView addSubview:_bottomView];
        
        UIImageView *videoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VideoSendIcon"]];
        [videoImage sizeToFit];
        CGRect _frame = videoImage.frame;
        _frame.origin.x = 5;
        _frame.origin.y = (CGRectGetHeight(_bottomView.frame) - CGRectGetHeight(_frame))/2;
        videoImage.frame = _frame;
        [self.bottomView addSubview:videoImage];
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_bottomView.frame), CGRectGetWidth(_bottomView.frame) - 3, CGRectGetHeight(_bottomView.frame))];
        _durationLabel.font = [UIFont boldSystemFontOfSize:11];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_durationLabel];
    }
    return self;
}

- (void)setAssetModel:(AssetModel *)assetModel {
    _assetModel = assetModel;
    
    __weak typeof(self) weakSelf = self;
    [assetModel fetchThumbnailWithPointSize:self.frame.size completion:^(UIImage * _Nullable image, AssetModel *assetModel) {
        if (assetModel == weakSelf.assetModel) {
            weakSelf.imageView.image = image;
        }
    }];
    
    _durationLabel.text = _assetModel.duration;
    
}



@end
