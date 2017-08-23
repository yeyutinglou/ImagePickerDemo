//
//  VideoDisplayController.m
//  student_iphone
//
//  Created by jyd on 2016/12/29.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "VideoDisplayController.h"
#import "VideoPlaybackView.h"
#import "ImagePickerConfig.h"
#import "AssetManager.h"
@interface VideoDisplayController ()
@property (nonatomic) VideoPlaybackView *playbackView;

@property (nonatomic) AVPlayer *player;
@property (nonatomic) UIButton *playButton;

@property (nonatomic) UIView *toolBar;
@property (nonatomic) UIButton *okButton;

@property (nonatomic) BOOL isVideoPlayable;
@end

@implementation VideoDisplayController {
    BOOL shouldShowStatusBar;
    BOOL isPlayOver;
}



- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        shouldShowStatusBar = YES;
        isPlayOver = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"视频预览";
    self.view.backgroundColor = [UIColor blackColor];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&err];
    [self setupViews];
    [self prepareToPlay];
}

- (void)setupViews {
    _playbackView = [[VideoPlaybackView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _playbackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playbackView];
    
}

- (void)prepareToPlay {
    self.isVideoPlayable = NO;
    WEAK_SELF;
    [[AssetManager sharedAssetManager] getVideoPlayerItemForAssetModel:_assetModel completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        if (playerItem) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONG_SELF;
                [weakSelf.playbackView setPlayerWithPlayItem:playerItem];
                
                [[NSNotificationCenter defaultCenter] addObserver:strongSelf selector:@selector(playComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
            });
        }
    }];
}


- (BOOL)prefersStatusBarHidden {
    return !shouldShowStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [_playbackView destroyTheAVPlayer];
}

#pragma mark - 视频 播放 -

- (void)tapHandler:(id)sender {
    [self toggleMediaPlayer];
}

- (void)swipeHandler:(UISwipeGestureRecognizer *)swipe {
    [self toggleMediaPlayer];
}

- (void)toggleMediaPlayer {
    if (self.isVideoPlayable) {
        if ([self isPlaying]) {
            [self pause];
        }else {
            if (isPlayOver) {
                isPlayOver = NO;
                [self.playbackView.player seekToTime:kCMTimeZero];
            }
            [self play];
        }
    }
    
    [self updatePlayerUI];
}


- (void)play {
    [self.playbackView.player play];
}

- (void)pause {
    [self.playbackView.player pause];
}

- (BOOL)isPlaying {
    return _isVideoPlayable && ([self.playbackView.player rate] != 0.f);
}


- (void)updatePlayerUI {
    BOOL isHidden = _playButton.hidden;
    
    _toolBar.hidden = !isHidden;
    _playButton.hidden = !isHidden;
    
    [self.navigationController setNavigationBarHidden:!isHidden animated:NO];
    shouldShowStatusBar = isHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)playComplete {
    isPlayOver = YES;
    [self updatePlayerUI];
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
