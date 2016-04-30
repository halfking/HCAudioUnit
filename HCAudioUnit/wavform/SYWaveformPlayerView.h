//
//  SYWaveformPlayerView.h
//  SCWaveformView
//
//  Created by Spencer Yen on 12/26/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCWaveformView.h"


@interface SYWaveformPlayerView : UIView  <AVAudioPlayerDelegate>
{
    NSTimer * timer_;
}
- (id)initWithFrame:(CGRect)frame asset:(AVURLAsset *)asset color:(UIColor *)normalColor progressColor:(UIColor *)progressColor;
- (void)playPauseTapped:(BOOL)isPlay;
- (void)readyToRelease;
- (void)seekTo:(CGFloat)x;
@end
