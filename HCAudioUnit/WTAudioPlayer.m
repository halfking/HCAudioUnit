//
//  WTAudioPlayer.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/6/18.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "WTAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
//#import "SCWaveformView.h"

#define WT_AUDIO_FADE_STEPS   30

#define VIDEO_CTTIMESCALE 600 //30 * 1000ms

@implementation WTAudioPlayer
@synthesize audioPlayer = player_;
@synthesize audioUrl = audioUrl_;
@synthesize timer = timer_;
- (id)initWithUrl:(NSURL *)url
{
    if(self = [super init])
    {
        [self createPlayer:url];
        autoFadeOutInterval_ = 0;
    }
    return self;
}
-(NSTimer *)timer{
    if (!timer_) {
        timer_=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return timer_;
}
- (void)setUrl:(NSURL *)url
{
    [player_ stop];
    PP_RELEASE(player_);
    [self createPlayer:url];
}
/**
 *  创建播放器
 *
 *  @return 音频播放器
 */
-(AVAudioPlayer *)createPlayer:(NSURL *) url{
    if (!player_) {
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        player_=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        player_.numberOfLoops=0;//设置为0不循环
        player_.delegate=self;
        [player_ prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return player_;
}

/**
 *  播放音频
 */
-(void)play{
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        self.timer.fireDate=[NSDate distantPast];//恢复定时器
    }
}
- (void)playfadeIn:(NSTimeInterval)fadeInInterval
{
    if (fadeInInterval > 0.0) {
        player_.volume = 0.0;
        NSTimeInterval interval = fadeInInterval / WT_AUDIO_FADE_STEPS;
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fadeIn:)
                                       userInfo:player_
                                        repeats:YES];
    }
    [self play];
    
}
- (void)playfadeInOut:(NSTimeInterval)fadeInInterval
{
    [self playfadeIn:fadeInInterval];
    autoFadeOutInterval_ = fadeInInterval;
    
    //添加监控，在合适的时候fadeout
}
- (void)fadeIn:(NSTimer *)timer
{
    AVAudioPlayer *player = timer.userInfo;
    float volume = player.volume;
    volume = volume + 1.0 / WT_AUDIO_FADE_STEPS;
    volume = volume > 1.0 ? 1.0 : volume;
    player.volume = volume;
    
    if (volume >= 1.0) {
        [timer invalidate];
    }
}
/**
 *  暂停播放
 */
-(void)pause{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        
    }
}
- (void)pausefadeOut:(NSTimeInterval)fadeOutInterval
{
    if(fadeOutInterval>0)
    {
        NSTimeInterval interval = fadeOutInterval / WT_AUDIO_FADE_STEPS;
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fadeOutAndPause:)
                                       userInfo:player_
                                        repeats:YES];
    }
    else
        [self pause];
}
- (void)fadeOutAndPause:(NSTimer *)timer
{
    AVAudioPlayer *player = timer.userInfo;
    float volume = player.volume;
    volume = volume - 1.0 / WT_AUDIO_FADE_STEPS;
    volume = volume < 0.0 ? 0.0 : volume;
    player.volume = volume;
    
    if (volume <= 0.0) {
        [timer invalidate];
        [self pause];
    }
}
-(void)stop{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        
    }
}
- (void)stopfadeOut:(NSTimeInterval)fadeOutInterval
{
    if (fadeOutInterval > 0) {
        NSTimeInterval interval = fadeOutInterval / WT_AUDIO_FADE_STEPS;
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fadeOutAndStop:)
                                       userInfo:player_
                                        repeats:YES];
    }
    else
    {
        [self stop];
    }
    autoFadeOutInterval_ = 0;
}

- (void)fadeOutAndStop:(NSTimer *)timer
{
    AVAudioPlayer *player = timer.userInfo;
    float volume = player.volume;
    volume = volume - 1.0 / WT_AUDIO_FADE_STEPS;
    volume = volume < 0.0 ? 0.0 : volume;
    player.volume = volume;
    
    if (volume == 0.0) {
        [timer invalidate];
        [self stop];
    }
}


/**
 *  更新播放进度
 */
-(void)updateProgress{

    if(autoFadeOutInterval_>0)
    {
        NSTimeInterval cIndex = self.audioPlayer.duration - self.audioPlayer.currentTime;
        if(cIndex <= autoFadeOutInterval_)
        {
            [self stopfadeOut:autoFadeOutInterval_];
            autoFadeOutInterval_ = 0;
        }
    }
#ifndef __OPTIMIZE__
    float progress= self.audioPlayer.duration>0 ? (self.audioPlayer.currentTime /self.audioPlayer.duration):0;
    NSLog(@"progress:%.2f",progress);
#endif
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
    self.timer.fireDate=[NSDate distantFuture];
}

#pragma mark - wave
+ (SCWaveformView *)createWaveView:(NSURL *)audioUrl normalColor:(UIColor *)normalColor progressColor:(UIColor *)progressColor
{
    return nil;
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
//    SCWaveformView * waveformView = [[SCWaveformView alloc] init];
//    waveformView.normalColor = normalColor;
//    waveformView.progressColor = progressColor;
//    waveformView.alpha = 0.8;
//    waveformView.backgroundColor = [UIColor clearColor];
//
//    waveformView.asset = asset;
////    waveformView.audioFileUrl = audioUrl;
//    
//    PP_RELEASE(asset);
//    
//    return PP_AUTORELEASE(waveformView);
}
- (CMTime)durance
{
    if (audioUrl_) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:audioUrl_ options:nil];
        return asset.duration;
    }
    else
    {
        return CMTimeMake(0, VIDEO_CTTIMESCALE);
    }
}
- (void)seek:(double)second
{
    if(player_)
    {
        [player_ setCurrentTime:second];
    }
}
#pragma mark - dealloc
- (void)readyToRelease
{
    if(player_)
    {
        [self stop];
        PP_RELEASE(player_);
    }
    if(self.timer)
    {
        [self.timer invalidate];
    }
}
- (void)dealloc
{
    [self readyToRelease];
    
    PP_SUPERDEALLOC;
}
@end
