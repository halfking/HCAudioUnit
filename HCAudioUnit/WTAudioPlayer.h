//
//  WTAudioPlayer.h
//  Wutong
//
//  Created by HUANGXUTAO on 15/6/18.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <hccoren/base.h>

@class SCWaveformView;

@interface WTAudioPlayer : NSObject<AVAudioPlayerDelegate>
{
    AVAudioPlayer * player_;
    NSURL * audioUrl_;
    
    NSTimeInterval autoFadeOutInterval_;
}
@property (nonatomic,PP_STRONG,readonly) AVAudioPlayer *audioPlayer;//播放器
@property (nonatomic,PP_STRONG,readonly) NSURL * audioUrl;
@property (PP_WEAK ,nonatomic,readonly) NSTimer *timer;//进度更新定时器

- (id)initWithUrl:(NSURL *)url;
//-(AVAudioPlayer *)createPlayer:(NSURL *) url;
-(void)play;
- (void)setUrl:(NSURL *)url;
-(void)playfadeIn:(NSTimeInterval)fadeInInterval;
-(void)playfadeInOut:(NSTimeInterval)fadeInInterval;

-(void)pause;
-(void)pausefadeOut:(NSTimeInterval)fadeOutInterval;
-(void)stop;
-(void)stopfadeOut:(NSTimeInterval)fadeOutInterval;
- (void)seek:(double)second;

-(CMTime)durance;

+(SCWaveformView *)createWaveView:(NSURL *)audioUrl normalColor:(UIColor *)normalColor progressColor:(UIColor *)progressColor;

-(void)readyToRelease;
@end
