//
//  ImageNumberView.m
//  student_iphone
//
//  Created by jyd on 2016/12/26.
//  Copyright © 2016年 he chao. All rights reserved.
//

#import "ImageNumberView.h"

@interface ImageNumberView ()

@property (nonatomic) UIImageView *backgroundImage;
@property (nonatomic) UILabel *numberLabel;

@end


@implementation ImageNumberView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    self.backgroundImage.image = [UIImage imageNamed:@"FriendsSendsPicturesNumberIcon"];
    [self addSubview:self.backgroundImage];
    
    self.numberLabel = [[UILabel alloc] initWithFrame:self.backgroundImage.frame];
    self.numberLabel.textColor = [UIColor whiteColor];
    self.numberLabel.font = [UIFont boldSystemFontOfSize:15];
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.numberLabel];
    
    return self;
}

- (void)setNumber:(NSInteger)number {
    if (_number != number) {
        _number = number;
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)_number];
        [self animateView];
    }
}

- (void)animateView {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundImage.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.backgroundImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backgroundImage.transform = CGAffineTransformMakeScale(1, 1);
            } completion:nil];
            
        }];
    }];
    
}
@end
