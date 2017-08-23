//
//  ViewController.m
//  ImagePickerDemo
//
//  Created by jyd on 2017/8/21.
//  Copyright © 2017年 jyd. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerController.h"
#import "ImageDeleteController.h"
#import "AssetManager.h"

#define kImageSpace 5
#define kImageWidth (kWidth - 3 * kImageSpace - 20) / 4

@interface ViewController () <ImagePickerControllerDelegate, ImageDeleteDelegate>
{
    
    NSMutableArray *arrayImages;
    UIView *imagesView;
    
    NSMutableArray *assetArray;
    NSMutableArray *tapArray;
}
@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
   
    [self setupViews];
    
}



- (void)setupViews
{
    assetArray = [[NSMutableArray alloc] init];
    arrayImages = [[NSMutableArray alloc] init];
    tapArray = [[NSMutableArray alloc] init];
    imagesView = [[UIView alloc] init];
    [imagesView setFrame:CGRectMake(10, 100, kWidth - 20, kImageWidth * 3 + 2 *kImageSpace)];
    [self.view addSubview:imagesView];
    for (int i = 0; i < 10; i ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(i % 4 * (kImageSpace + kImageWidth), i / 4 * (kImageSpace + kImageWidth), kImageWidth, kImageWidth);
        imageView.userInteractionEnabled = YES;
        [imageView setBackgroundColor:[UIColor redColor]];
        [imageView setImage:[UIImage imageNamed:@"btn_add"]];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(creatUI:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:tap];
        imageView.hidden = YES;
        if (i == 0) {
            imageView.hidden = NO;
        }
        [imagesView addSubview:imageView];
        [tapArray addObject:tap];
    }

}


- (void)creatUI:(UITapGestureRecognizer *)tapGesture



{
    
    for (int i = 0; i < tapArray.count; i++) {
        UIImageView *imageView = imagesView.subviews[i];
        UITapGestureRecognizer *tap = tapArray[i];
        if ([tap isEqual:tapGesture] && ![imageView.image isEqual:[UIImage imageNamed:@"btn_add"]]) {
            ImageDeleteController *imageDelete = [[ImageDeleteController alloc] init];
            imageDelete.deleteDelegate = self;
            imageDelete.curShowImage = arrayImages[i];
            imageDelete.allImages = arrayImages;
            imageDelete.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:imageDelete animated:YES];
            return;
        }
        
    }
    
    
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"请选择操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [self presentViewController:alertVc animated:YES completion:nil];
    
    
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //处理拍照的代码
        [self takePhoto];
    }];
    
    UIAlertAction *actionLibrary = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //处理相册的代码
        
        WEAK_SELF;
        
        CheckAuthorizationCompletionBlock block = ^(AuthorizationType type) {
            if (!weakSelf)return;
            
            switch (type) {
                case kAuthorizationTypeDenied:
                case kAuthorizationTypeRestricted:
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-相册”选项中，允许本应用程序访问你的相机。" delegate:self cancelButtonTitle:@"好，我知道了" otherButtonTitles:nil];
                    [alert show];
                }
                    break;
                default:
                {
                    ImagePickerController *vc = [[ImagePickerController alloc] init];
                    vc.pickerDelegate = self;
                    vc.selectedNum =  arrayImages.count ;
                    [self.navigationController presentViewController:vc animated:YES completion:nil];
                }
                    break;
            }
        };
        
        [[AssetManager sharedAssetManager] chechAuthorizationStatus:block];
        
        
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:actionCamera];
    [alertVc addAction:actionLibrary];
    [alertVc addAction:actionCancel];
}


#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        NSString *key = nil;
        
        if (imagePickerController.allowsEditing)
        {
            key = UIImagePickerControllerEditedImage;
        }
        else
        {
            key = UIImagePickerControllerOriginalImage;
        }
        //获取图片
        UIImage *image = [info objectForKey:key];
        [arrayImages addObject:image];
        [self showImage];
        
        [imagePickerController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    
    
}



- (void)imagePickerController:(ImagePickerController *)picker
       didFinishPickingImages:(NSArray<AssetModel *> *)assets
                    withError:(NSError *)error {
    if (error || assets.count == 0) return;
    
    assetArray = (NSMutableArray*)assets;
    [self getPhotoImage];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];

  
    
    
}

-(void)showImage
{

    for (int i = 0; i < arrayImages.count; i++) {
        UIImageView *imageView = imagesView.subviews[i];
        imageView.hidden = NO;
        UIImage *newImage = [UIImage thumbImage:arrayImages[i] toRect:CGSizeMake(kImageWidth, kImageWidth)];
        imageView.image = newImage;
    }
    
        if (arrayImages.count < 9) {
            UIImageView *imageView = imagesView.subviews[arrayImages.count];
            imageView.hidden = NO;
            imageView.image = [UIImage imageNamed:@"btn_add"];
        }
    
    
}

- (void)getPhotoImage {
    
    
    for (int i = 0; i < assetArray.count; i++) {
         AssetModel *model = assetArray[i];
        //获取原型
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageHeight = floor((kWidth/model.asset_PH.pixelWidth) * model.asset_PH.pixelHeight);
        CGSize pixSize = CGSizeMake(kHeight * scale, imageHeight * scale);
        [model fetchThumbnailWithPointSize:pixSize completion:^(UIImage * _Nullable image, AssetModel * _Nonnull assetModel) {
            if (assetModel == model) {
                [arrayImages addObject:image];
                [self showImage];
            }
        }];
    }
    
    
    
}

#pragma mark - DelegeDetegate
-(void)deleteImage:(NSArray *)allImages {
    
    for (UIImageView *imageView in imagesView.subviews) {
        imageView.image = nil;
        imageView.hidden = YES;
        if (assetArray.count == 0) {
            imageView.image = [UIImage imageNamed:@"btn_add"];
        }
    }
    arrayImages = (NSMutableArray*)allImages;
    if (arrayImages.count == 0) {
        UIImageView *imageView = imagesView.subviews[0];
        imageView.hidden = NO;
        imageView.image = [UIImage imageNamed:@"btn_add"];
        return;
    }
    
    [self showImage];
    
    
}





- (void)imagePickerControllerDidCancel:(ImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 开始拍照
-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //先检查相机可用是否
        BOOL cameraIsAvailable = [self checkCamera];
        if (YES == cameraIsAvailable) {
            [self presentViewController:picker animated:YES completion:nil];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-相机”选项中，允许本应用程序访问你的相机。" delegate:self cancelButtonTitle:@"好，我知道了" otherButtonTitles:nil];
            [alert show];
        }
        
    }
}


//检查相机是否可用
- (BOOL)checkCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(AVAuthorizationStatusRestricted == authStatus ||
       AVAuthorizationStatusDenied == authStatus)
    {
        //相机不可用
        return NO;
    }
    //相机可用
    return YES;
}












- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
