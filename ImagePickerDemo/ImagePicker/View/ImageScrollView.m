//
//  ImageScrollView.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "ImageScrollView.h"

@interface ImageScrollView ()

@property (nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation ImageScrollView

- (instancetype)init {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundColor = [UIColor clearColor];
    self.pagingEnabled = NO;
    self.delaysContentTouches = YES;
    self.canCancelContentTouches = YES;
    self.bounces = YES;
    self.bouncesZoom = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    _assetIndex = -1;
    
    return self;
}


- (void)setAssetIndex:(NSInteger)assetIndex
{
    _assetIndex = assetIndex;
}

- (void)setAssetModel:(AssetModel *)assetModel {
    _assetModel = assetModel;
}

- (void)setContentWithImage:(UIImage *)image {
    if (!image) {
        _isImageExist = NO;
        [self showLoadingIndicator];
        self.minimumZoomScale = 1;
        self.maximumZoomScale = 1;
        return;
    }
    
    _isImageExist = YES;
    
    _imageSize = CGSizeMake(kWidth, kWidth/image.size.width * image.size.height);
    CGFloat _y = (kHeight > _imageSize.height) ? (kHeight - _imageSize.height)/2 : 0;
    _imageView.frame = CGRectMake(0, _y, kWidth, _imageSize.height);
    
    _imageView.image = image;
    
    self.contentSize = _imageSize;
    
    //设置缩放范围
    self.minimumZoomScale = MinimumZoomScale;
    CGFloat vScale = kHeight / _imageSize.height;
    self.maximumZoomScale = MAX(vScale, MaximumZoomScale);
    
    [self hideLoadingIndicator];
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.center = CGPointMake(kWidth/2, kHeight/2);
    }
    
    return _indicatorView;
}

- (void)showLoadingIndicator {
    self.imageView.hidden = YES;
    
    [self addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}


- (void)hideLoadingIndicator {
    self.imageView.hidden = NO;
    
    [_indicatorView stopAnimating];
    [_indicatorView removeFromSuperview];
}


@end

