//
//  VideoPlaybackView.m
//  student_iphone
//
//  Created by jyd on 2016/12/29.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "VideoPlaybackView.h"
#import "UIImage+Extension.h"
#import <AVFoundation/AVFoundation.h>

#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface VideoPlaybackView ()

{
    BOOL isPlaying;
    BOOL isPlayOver;
    BOOL isHidden;
    
    CGFloat  totalMovieDuration;
    UIProgressView  *progressView;
    
    
    UIActivityIndicatorView * videoLoding;      //视频缓冲
    UIImageView * videoPlay;
    int recordCurrentTime;
    
    UILabel * showTheTime ;                     //显示快进快退的时间
    NSString * originalTime;                    //原始时间

    
    NSInteger index;
    NSTimer *timer;
}


@property (nonatomic) UIButton *playButton;

@property (nonatomic) UIView *toolBar;

@property (nonatomic) UISlider *movieProgressSlider;
@property (nonatomic) UILabel *showBeginTime;
@property (nonatomic) UILabel *showEndTime;



@end

@implementation VideoPlaybackView



+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (void)setMyPlayerWithUrl:(NSString *)url{
    
    
    NSURL *sourceMovieURL = [NSURL URLWithString:url];
    
    //使用playerItem获取视频的信息，当前播放时间，总时间等
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:sourceMovieURL];
    //player是视频播放的控制器，可以用来快进播放，暂停等
    [self setPlayerWithPlayItem:playerItem];
    
    
}
- (void)setPlayerWithPlayItem:(AVPlayerItem *)playerItem {
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [self setPlayer:player];
    [self setupViews];
}


- (void)setupViews {
    [self.player.currentItem addObserver:self forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    [self.player.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    
    UITapGestureRecognizer *oneTap=nil;
    oneTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneTap:)];
    oneTap.numberOfTapsRequired = 1;
    oneTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:oneTap];
    
    UIPanGestureRecognizer *panTheVideo=nil;
    panTheVideo=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTheVieoView:)];
    [self addGestureRecognizer:panTheVideo];
    
     _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"videoplayer_play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"videoplayer_pause"] forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    [_playButton sizeToFit];
    _playButton.center = CGPointMake(kWidth/2, kHeight/2);
    [self addSubview:_playButton];
    
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kHeight - 20, kWidth, 20)];
    _toolBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self addSubview:_toolBar];
    
    
    showTheTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    [showTheTime setCenter:CGPointMake(DEVICE_WIDTH/2, DEVICE_HEIGHT/2)];
    showTheTime.textAlignment = NSTextAlignmentCenter;
    [self addSubview:showTheTime];
    showTheTime.backgroundColor = [UIColor clearColor];
    [showTheTime setTextColor:[UIColor redColor]];
    
    _showBeginTime = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 40, 20)];
    _showBeginTime.font = [UIFont systemFontOfSize:10];
    _showBeginTime.textColor = [UIColor whiteColor];
    _showBeginTime.backgroundColor = [UIColor clearColor];
    [_toolBar addSubview:_showBeginTime];
    
    _showEndTime = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH - 45, 0, 40, 20)];
    _showEndTime.textAlignment = NSTextAlignmentRight;
    _showEndTime.font = [UIFont systemFontOfSize:10];
    _showEndTime.textColor = [UIColor whiteColor];
    _showEndTime.backgroundColor = [UIColor clearColor];
    [_toolBar addSubview:_showEndTime];

    [self monitorMovieProgress];
    isPlaying = NO;
    isPlayOver = NO;
   

}


#pragma mark - 销毁播放器
- (void)destroyTheAVPlayer {
    [self.player pause];
    [self.player setRate:0];
    
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    totalMovieDuration = 0;
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 状态监测
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            CMTime totalTime = playerItem.duration;
            totalMovieDuration = totalTime.value / totalTime.timescale;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:totalMovieDuration];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            if (totalMovieDuration / 3600 >= 1) {
                [formatter setDateFormat:@"HH:MM:SS"];
            } else {
                [formatter setDateFormat:@"mm:ss"];
            }
            NSString *showTimeNew = [formatter stringFromDate:date];
            _showBeginTime.text = showTimeNew;
            _showEndTime.text = showTimeNew;
            
            __weak typeof (self) weakSelf = self;
            CGFloat weakTotalMovieDuration = totalMovieDuration;
            [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
                CMTime currentTime = weakSelf.player.currentItem.currentTime;
                CGFloat currentPlayTime = currentTime.value / currentTime.timescale;
                [UIView animateWithDuration:0.6 animations:^{
                    weakSelf.movieProgressSlider.value = currentPlayTime / weakTotalMovieDuration;
                }];
                
                NSString *showTime = [weakSelf secondToTime:currentPlayTime];
                weakSelf.showBeginTime.text = showTime;
            }];
            
            [self playOrPause];
        } else {
            [self destroyTheAVPlayer];
        }
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        float bufferTime = [self availableDuration];
        float durationTime = CMTimeGetSeconds([[self.player currentItem] duration]);
        [UIView animateWithDuration:0.6 animations:^{
            [progressView setProgress:bufferTime / durationTime animated:YES];
        }];
        
    }
}

#pragma mark - 播放进度
- (void)monitorMovieProgress {
    UIImage *stetchLeftTrack = [[UIImage imageWithColor:[UIColor redColor] frame:CGRectMake(0, 0, 1, 2)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *stetchRightTrack = [[UIImage imageWithColor:[UIColor clearColor] frame:CGRectMake(0, 0, 1, 2)] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *thumbImage = [UIImage imageWithColor:[UIColor clearColor] frame:CGRectMake(0, 0, 1, 2)];
    
    self.movieProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(45, _showBeginTime.center.y -1, DEVICE_WIDTH - 90, 2)];
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(46, _showBeginTime.center.y-1, DEVICE_WIDTH - 92, 1)];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    progressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.2];
    progressView.trackTintColor = [UIColor clearColor];
    [progressView setProgress:0 animated:YES];
    [_toolBar addSubview:progressView];
    [_toolBar addSubview:self.movieProgressSlider];
    
    [self.movieProgressSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [self.movieProgressSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    self.movieProgressSlider.backgroundColor = [UIColor clearColor];
    [self.movieProgressSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.movieProgressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
    [self.movieProgressSlider addTarget:self action:@selector(scrubberIsScrolling) forControlEvents:UIControlEventValueChanged];
    [self.movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
}

#pragma mark - 页面滑动
- (void)panTheVieoView:(UIPanGestureRecognizer *)recognizer {
    CGPoint translatedPoint = [recognizer translationInView:self];
    CGFloat firstX = 0.0;
    
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
        {
            [self.player pause];
            recordCurrentTime= totalMovieDuration * self.movieProgressSlider.value;
            originalTime = [self secondToTime:totalMovieDuration];
            showTheTime.hidden = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat x = firstX + translatedPoint.x;
            CGFloat precent =  x /DEVICE_WIDTH;         //获取移动的百分比
            CGFloat panToTime = recordCurrentTime + totalMovieDuration * precent;       //移动到第几秒
            int intpanToTime = floorf(panToTime);
            if (intpanToTime<0) {
                intpanToTime = 0;
            }else if (intpanToTime>totalMovieDuration){
                intpanToTime = totalMovieDuration;
            }
            
            //秒数转换为时间
            NSString * showtimeNew = [self secondToTime:intpanToTime];
            NSLog(@"totalMovieDuration:%@",showtimeNew);
            
            //转换成CMTime才能给player来控制播放进度
            CMTime dragedCMTime = CMTimeMake(intpanToTime, 1);
            [self.player seekToTime:dragedCMTime completionHandler:
             ^(BOOL finish)
             {
                 if (isPlaying) {
                     [self.player play];
                 }
             }];
            
            showTheTime.text = [NSString stringWithFormat:@"%@ / %@",showtimeNew,originalTime];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            showTheTime.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 加载进度
- (float) availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if (loadedTimeRanges.count > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSecoonds = CMTimeGetSeconds(timeRange.duration);
        return startSeconds + durationSecoonds;
    } else {
        return 0.0f;
    }
}

#pragma mark - 秒转化成时间
- (NSString *)secondToTime:(int)second {
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    else
    {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

#pragma mark - 播放结束通知
- (void)moviePlayDidEnd:(NSNotification*)notification {
    //视频播放完成
    double currentTime = floor(totalMovieDuration *0);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [self.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish)
     {

         _playButton.selected = isPlaying = isHidden = NO;
         [self updatePlayerUI];
     }];

}

#pragma mark - 点击屏幕
- (void)oneTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self updatePlayerUI];
    if (isPlaying) {
        
        if (!timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(didAction) userInfo:nil repeats:YES];
             index = 0;
        }
        
       
    }

}
#pragma mark - 计时消失控件
- (void)didAction {
    index ++;
    if (index >= 5 || !isHidden) {
        [timer invalidate];
        timer = nil;
         index = 0;
        if (isHidden && isPlaying) {
            [self updatePlayerUI];
        }
        
    }
    
}
#pragma mark - 暂停或者播放
- (void)playOrPause {
    if (isPlaying) {
        [self.player pause];
    } else {
        [self.player play];
        isHidden = YES;
        [self updatePlayerUI];
    }
    isPlaying = !isPlaying;
    _playButton.selected = isPlaying;

}



#pragma mark - 快进或者快退
- (void)scrubberIsScrolling {
    double currentTime = floor(totalMovieDuration *self.movieProgressSlider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [self.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish)
     {
         if (isPlaying) {
             [self.player play];
         }
     }];

}

- (void)scrubbingDidBegin {
    [self.player pause];
}

- (void)scrubbingDidEnd {
    
}

#pragma mark - 更新UI
- (void)updatePlayerUI {
   
    
    _toolBar.hidden = isHidden;
    _playButton.hidden = isHidden;
    
    [self.navigationController setNavigationBarHidden:isHidden animated:NO];
     isHidden = !isHidden;
//    shouldShowStatusBar = isHidden;
//    [self setNeedsStatusBarAppearanceUpdate];
}

@end


@implementation UIView(UINavigationController)

- (UINavigationController *)navigationController
{
    UIViewController * controller = self.viewController;
    if ( controller )
    {
        return controller.navigationController;
    }
    
    return nil;

}

@end


@implementation UIView(UIViewController)

- (UIViewController *)viewController
{
    UIView *view = self;
    UIResponder *nextResponder = [view nextResponder];
    if (nextResponder && [nextResponder isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)nextResponder;
    }
    return nil;
}

@end

