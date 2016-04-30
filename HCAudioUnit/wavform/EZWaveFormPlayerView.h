//
//  EZWaveFormPlayerView.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/8/14.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "EZAudio.h"

@interface EZWaveFormPlayerView : UIView<EZAudioPlayerDelegate>
{
    NSTimer * timer_;
}
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, strong)  EZAudioPlot *audioPlot;

- (id)initWithFrame:(CGRect)frame  color:(UIColor *)normalColor progressColor:(UIColor *)progressColor;
- (void)playPauseTapped:(BOOL)isPlay;
- (void)readyToRelease;
- (void)seekTo:(CGFloat)x;
- (void)openFileWithFilePathURL:(NSURL *)url;
@end
