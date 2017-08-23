//
//  VideoPlaybackView.h
//  student_iphone
//
//  Created by jyd on 2016/12/29.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerItem;


@interface VideoPlaybackView : UIView


@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (void)setPlayerWithUrl:(NSString *)url;
- (void)setPlayerWithPlayItem:(AVPlayerItem *)playerItem;


- (void)destroyTheAVPlayer;
@end


@interface UIView(UINavigationController)

@property (nonatomic, readonly) UINavigationController *	navigationController;

@end


@interface UIView(UIViewController)

@property (nonatomic, readonly) UIViewController *	viewController;

@end
