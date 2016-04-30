//
//  LCVoice.m
//  LCVoiceHud
//
//  Created by 郭历成 on 13-6-21.
//  Contact titm@tom.com
//  Copyright (c) 2013年 Wuxiantai Developer Team.(http://www.wuxiantai.com) All rights reserved.
//

#import "LCVoice.h"
//#import "LCVoiceHud.h"
#import <hccoren/base.h>

#import <AVFoundation/AVFoundation.h>

#pragma mark - <DEFINES>

#define WAVE_UPDATE_FREQUENCY   0.05

#pragma mark - <CLASS> LCVoice

@interface LCVoice () <AVAudioRecorderDelegate>
{
    NSTimer * timer_;
    
    //    LCVoiceHud * voiceHud_;
}

@property(nonatomic,retain) AVAudioRecorder * recorder;

@end

@implementation LCVoice

-(void) dealloc{
    
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    PP_RELEASE(_recorder);
    PP_RELEASE(_recordPath);
    //    self.recorder = nil;
    //    self.recordPath = nil;
    
    PP_SUPERDEALLOC;
    //    [super dealloc];
    
}

#pragma mark - Publick Function

-(void)startRecordWithPath:(NSString *)path
{
    NSError * err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if(![audioSession.category isEqualToString:AVAudioSessionCategoryPlayAndRecord])
    {
        orgCategory_ = audioSession.category;
        
        [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
        
        if(err){
            NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
        
        [audioSession setActive:YES error:&err];
        
        err = nil;
        if(err){
            NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
    }
    else
    {
        orgCategory_ = nil;
    }
    
    NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
    
    //    MPEG4AAC
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt: AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
    
    /*
     [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
     [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
     [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
     */
    if(!path || path.length<5)
    {
        NSString * recordName = [NSString stringWithFormat:@"%@-%ld.m4a",@"01",[CommonUtil getDateTicks:[NSDate date]]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * rootPath = [documentsDirectory stringByAppendingPathComponent:@"tempfiles"];
        path = [rootPath stringByAppendingPathComponent:recordName];
    }
    self.recordPath = path;
    NSURL * url = [NSURL fileURLWithPath:self.recordPath];
    
    err = nil;
    
    //    NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    //
    //    if(audioData)
    //    {
    //        NSFileManager *fm = [NSFileManager defaultManager];
    //        [fm removeItemAtPath:[url path] error:&err];
    //    }
    //
    //    err = nil;
    
    if(self.recorder){[self.recorder stop];self.recorder = nil;}
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    
    if(!_recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        if(self.delegate && [self.delegate respondsToSelector:@selector(LCVoice:error:)])
        {
            [self.delegate LCVoice:self error:err];
        }
        return;
    }
    
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        if(self.delegate && [self.delegate respondsToSelector:@selector(LCVoice:error:)])
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"没有可用的输入设备."
                                                                 forKey:NSLocalizedDescriptionKey];
            NSError *aError = [NSError errorWithDomain:@"com.seenvoice.maiba" code:-1000 userInfo:userInfo];
            [self.delegate LCVoice:self error:aError];
        }
        return;
    }
    
    //    [_recorder recordForDuration:(NSTimeInterval) 60 * 2];
    if([_recorder record])
    {
        self.recordTime = 0;
        [self resetTimer];
        
        timer_ = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
        
        [self showVoiceHudOrHide:YES];
    }
    else
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(LCVoice:error:)])
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"启动录音失败."
                                                                 forKey:NSLocalizedDescriptionKey];
            NSError *aError = [NSError errorWithDomain:@"com.seenvoice.maiba" code:-1000 userInfo:userInfo];
            [self.delegate LCVoice:self error:aError];
        }
    }
    
    
}

-(void) stopRecordWithCompletionBlock:(void (^)())completion
{
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    int flags = AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation;
    //    [audioSession setActive:NO withFlags:flags error:nil];
    [_recorder stop];
    
    [self restoreCategory];
    
    dispatch_async(dispatch_get_main_queue(),completion);
    
    [self resetTimer];
    [self showVoiceHudOrHide:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self restoreCategory];
    });
}
- (void)readyToRelease
{
    [self resetTimer];
    [self cancelled];
    self.delegate = nil;
    
    [self restoreCategory];
}
- (void)restoreCategory
{
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if(orgCategory_)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError * err = nil;
        if(![audioSession.category isEqualToString:orgCategory_])
        {
            [audioSession setCategory:orgCategory_ error:&err];
            
            if(err){
                NSLog(@"audioSession: %@ %d %@", [err domain], (int)[err code], [[err userInfo] description]);
                return;
            }
            
            [audioSession setActive:YES error:&err];
            
            err = nil;
            if(err){
                NSLog(@"audioSession: %@ %d %@", [err domain], (int)[err code], [[err userInfo] description]);
                return;
            }
        }
        orgCategory_ = nil;
    }
}
#pragma mark - Timer Update

- (void)updateMeters {
    
    self.recordTime += WAVE_UPDATE_FREQUENCY;
    if(self.delegate && [self.delegate respondsToSelector:@selector(LCVoice:updateMeters:)])
    {
        if (_recorder) {
            [_recorder updateMeters];
        }
        
        float peakPower = [_recorder averagePowerForChannel:0];
        double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
        
        [self.delegate LCVoice:self updateMeters:peakPowerForChannel*2];
    }
    //    if (voiceHud_)
    //    {
    //        /*  发送updateMeters消息来刷新平均和峰值功率。
    //         *  此计数是以对数刻度计量的，-160表示完全安静，
    //         *  0表示最大输入值
    //         */
    //
    //        if (_recorder) {
    //            [_recorder updateMeters];
    //        }
    //
    //        float peakPower = [_recorder averagePowerForChannel:0];
    //        double ALPHA = 0.05;
    //        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
    //
    //        [voiceHud_ setProgress:peakPowerForChannel];
    //    }
}

#pragma mark - Helper Function

-(void) showVoiceHudOrHide:(BOOL)yesOrNo{
    if(self.delegate && [self.delegate respondsToSelector:@selector(LCVoice:showHideMeters:)])
    {
        [self.delegate LCVoice:self showHideMeters:yesOrNo];
    }
    //    if (voiceHud_) {
    //        [voiceHud_ hide];
    //        voiceHud_ = nil;
    //    }
    //
    //    if (yesOrNo) {
    //
    //        voiceHud_ = [[LCVoiceHud alloc] init];
    //        [voiceHud_ show];
    //        [voiceHud_ release];
    //
    //    }else{
    //
    //    }
}

-(void) resetTimer
{
    if (timer_) {
        [timer_ invalidate];
        timer_ = nil;
    }
}

-(void) cancelRecording
{
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    self.recorder = nil;
    if(self.recordPath && [[NSFileManager defaultManager]fileExistsAtPath:self.recordPath])
    {
        [[NSFileManager defaultManager]removeItemAtPath:self.recordPath error:nil];
    }
}

- (void)cancelled {
    
    [self showVoiceHudOrHide:NO];
    [self resetTimer];
    [self cancelRecording];
}
#pragma mark -处理音频录制过程中的中断
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    NSLog(@"Recording process is interrupted");
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
                           withFlags:(NSUInteger)flags{
    if (flags == AVAudioSessionInterruptionOptionShouldResume){
        NSLog(@"Resuming the recording...");
        [_recorder record];
    }
}


#pragma mark - LCVoiceHud Delegate

-(void) LCVoiceHudCancelAction
{
    [self cancelled];
}

@end
