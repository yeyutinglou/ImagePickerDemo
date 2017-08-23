//
//  ImageDeleteController.m
//  student_iphone
//
//  Created by jyd on 2016/12/27.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "ImageDeleteController.h"
#import "ImageScrollView.h"
#import "ImageSelectIndicator.h"
#import "PhotoToolBar.h"
#import "ImagePickerController.h"
#import "ImagePickerConfig.h"
#import "AssetManager.h"

@interface ImageDeleteController () <UIScrollViewDelegate>

@property (nonatomic) ImageScrollView *curShowScrollView;

@property (nonatomic) ImageSelectIndicator *bigSelectView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray<ImageScrollView *> *innerScrollViews;
@property (nonatomic) PhotoToolbar *toolbar;

@end

@implementation ImageDeleteController {
    NSInteger length;
    CGFloat scroll_width;
    CGPoint screenCenter;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    scroll_width = kWidth + 25;
    screenCenter = CGPointMake(kWidth/2, kHeight/2);
    length = _allImages.count >= 3 ? 3: _allImages.count;
    
    [self setupNavigationBar];
    [self setupViews];
    
    //添加Gesture
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:tapGesture];
    
    [tapGR requireGestureRecognizerToFail:tapGesture];
    
    [self showAllImage];
    
}
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)setupNavigationBar {
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.navigationController.navigationBar.subviews[0].frame;
    frame.size.height = 64;
    self.navigationController.navigationBar.frame = frame;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -8;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FriendsSendsPicturesQuitBigIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack)];
//    [leftItem setTitlePositionAdjustment:UIOffsetMake(20, 0) forBarMetrics:UIBarMetricsDefault];
//    [leftItem setBackgroundVerticalPositionAdjustment:-8 forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItems = @[spaceItem, leftItem];
    
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(doDelete)];
//    [rightItem setTitlePositionAdjustment:UIOffsetMake(20, 0) forBarMetrics:UIBarMetricsDefault];
//    [rightItem setBackgroundVerticalPositionAdjustment:-8 forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItems = @[spaceItem, rightItem];
    
}

- (void)setupViews {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, kWidth, kHeight)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scroll_width, kHeight)];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_allImages.count * scroll_width, kHeight);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.delaysContentTouches = YES;
    _scrollView.canCancelContentTouches = YES;
    [bgView addSubview:_scrollView];
    
    self.innerScrollViews = [[NSMutableArray alloc] initWithCapacity:length];
    
    for (int i=0; i < length; i++) {
        ImageScrollView * _innerScrollView = [[ImageScrollView alloc] init];
        _innerScrollView.delegate = self;
        [self.innerScrollViews addObject:_innerScrollView];
        
        [self.scrollView addSubview:_innerScrollView];
    }
    
   
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.subviews[0].alpha = 0.6;
    
}


#pragma mark - 加载照片

- (void)fillScrollView:(ImageScrollView *)scrollView withAssetIndex:(NSInteger)assetIndex {
    scrollView.assetIndex = assetIndex;
    [scrollView setContentWithImage:_allImages[assetIndex]];
    
    scrollView.frame = CGRectMake(scroll_width * assetIndex, 0, kWidth, kHeight);
}

- (void)showAllImage {
    
    NSInteger showIndex = [_allImages indexOfObject:self.curShowImage];
    NSInteger from = showIndex -1;
    if (showIndex == 0) {
        from = showIndex;
    }else if (showIndex == _allImages.count - 1) {
        from = showIndex -(length-1);
    }
    
    NSInteger assetIndex = from;
    for (ImageScrollView *scrollView in self.innerScrollViews) {
        [self fillScrollView:scrollView withAssetIndex:assetIndex];
        
        assetIndex ++;
    }
    
    self.scrollView.contentOffset = CGPointMake(scroll_width * showIndex, 0);
    self.curShowScrollView = self.innerScrollViews[showIndex - from];
    _currentIndex = showIndex + 1;
    
    self.title = [NSString stringWithFormat:@"%ld/%lu",_currentIndex,(unsigned long)self.allImages.count];
}



#pragma mark - 处理左右拖动

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollWillBeginDragging");
    
    if (scrollView != self.scrollView) {
        for (ImageScrollView *scrollView in self.innerScrollViews) {
            scrollView.hidden = YES;
        }
        scrollView.hidden = NO;
    }else {
        for (ImageScrollView *scrollView in self.innerScrollViews) {
            scrollView.hidden = NO;
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView)return;
    
    if (_allImages.count == 1)return;
    
    //以照片是否越过屏幕中间分割线为依据，滑动距离越过了中间分割线，就表示显示的照片更换了
    //不等到照片完全划出屏幕
    CGPoint point = [self.view convertPoint:screenCenter toView:self.scrollView];
    
    for (int i=0; i<length; i++) {
        ImageScrollView *innerScrollView = self.innerScrollViews[i];
        
        if (CGRectContainsPoint(innerScrollView.frame, point)) {
            if (_curShowScrollView == innerScrollView)return;
            
            //如果照片处于放大状态，此时将他还原
            if (_curShowScrollView.zoomScale >= 1 + FLT_EPSILON) {
                _curShowScrollView.scrollEnabled = NO;
                [_curShowScrollView setZoomScale:1.0 animated:NO];
                _curShowScrollView.scrollEnabled = YES;
            }
            
            _curShowScrollView = innerScrollView;
            
            //判断当前显示照片是否已被选择
            NSInteger assetIndex = innerScrollView.assetIndex;
            self.curShowImage = self.allImages[assetIndex];

            _currentIndex = assetIndex + 1;
            self.title = [NSString stringWithFormat:@"%ld/%lu",_currentIndex,(unsigned long)self.allImages.count];
            //移动前后照片
            if (assetIndex + 1 < _allImages.count && [self scrollViewWithAssetIndex:assetIndex + 1] == nil) {
                [self fillScrollView:[self scrollViewWithAssetIndex:assetIndex - 2] withAssetIndex:assetIndex + 1];
            }else if (assetIndex - 1 >=0 && [self scrollViewWithAssetIndex:assetIndex - 1] == nil) {
                [self fillScrollView: [self scrollViewWithAssetIndex:assetIndex + 2] withAssetIndex:assetIndex - 1];
            }
            
            break;
        }
    }
    
}



#pragma mark - 处理缩放

- (UIView *)viewForZoomingInScrollView:(ImageScrollView *)scrollView {
    return scrollView.imageView;
}

//处理双击放大、缩小
- (void)handleZoom:(UITapGestureRecognizer *)tap {
    if (_curShowScrollView.isZooming)return;
    if (_curShowScrollView.imageView.hidden)return;
    CGFloat zoomScale = _curShowScrollView.zoomScale;
    
    if(zoomScale < 1.0 + FLT_EPSILON){
        CGPoint loc = [tap locationInView: _curShowScrollView];
        CGRect rect = CGRectMake(loc.x - 0.5, loc.y - 0.5, 1, 1);
        
        [_curShowScrollView zoomToRect:rect animated:YES];
    }else {
        [_curShowScrollView setZoomScale:1 animated:YES];
         [_curShowScrollView.imageView setCenter:screenCenter];
    }
    
}


- (void)scrollViewDidZoom:(ImageScrollView *)scrollView {
    UIImageView *zoomImageView = (UIImageView *)[self viewForZoomingInScrollView: scrollView];
    
    CGRect frame = zoomImageView.frame;
    
    //当视图不能填满整个屏幕时，让其居中显示
    frame.origin.x = (kWidth > CGRectGetWidth(frame)) ? (kWidth - CGRectGetWidth(frame))/2 : 0;
    frame.origin.y = (kWidth > CGRectGetHeight(frame)) ? (kHeight - CGRectGetHeight(frame))/2 : 0;
    if (fabs(scrollView.zoomScale - 1.0) < FLT_EPSILON) {
        frame.size = scrollView.imageSize;
        scrollView.contentSize = frame.size;
    }
    
    zoomImageView.frame = frame;
    
}


#pragma mark - 其他

- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    NSLog(@"TapTp");
    
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)doFinish {
//    [(ImagePickerController *)self.navigationController didFinishPickingImages:self.allSelectdAssets WithError:nil assetGroupModel:self.assetGroupModel];
//}

- (ImageScrollView *)scrollViewWithAssetIndex:(NSInteger)assetIndex {
    for (ImageScrollView *scrollView in self.innerScrollViews) {
        if (scrollView.assetIndex == assetIndex)
            return scrollView;
    }
    
    return nil;
}


#pragma mark - 删除照片
- (void)doDelete {
    [self.view removeAllSubviews];
    NSInteger index = _currentIndex - 1;
     [self.allImages removeObjectAtIndex:index];
    length = _allImages.count >= 3 ? 3: _allImages.count;
    DYWLog(@"%@",self.allImages);
    if (self.allImages.count > 0) {
        if ( index >= 0   && index <= self.allImages.count -1) {
            _curShowImage = self.allImages[index];
        } else {
            _curShowImage = self.allImages[self.allImages.count -1];
        }
        
        [self setupViews];
        [self showAllImage];

    } else {
        [self doBack];
    }

   
    if (_deleteDelegate && [_deleteDelegate respondsToSelector:@selector(deleteImage:)]) {
        [_deleteDelegate deleteImage:self.allImages];
    }
    
    
    
    
    

}





@end



@implementation UIView (Manipulation)

- (void)removeAllSubviews
{
    NSArray *array = self.subviews;
    for (UIView *view in array) {
        [view removeFromSuperview];
    }
}

@end
