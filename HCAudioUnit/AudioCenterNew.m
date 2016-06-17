//
//  AudioCenterNew.m
//  maiba
//
//  Created by HUANGXUTAO on 16/2/18.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//
/*
 audioCenter的工作方式为先启动一个audioController，然后通过向audioContrller中添加filter，receiver等来实现，具体的audioContrller工作原理可以参考https://github.com/TheAmazingAudioEngine/TheAmazingAudioEngine
 */

#import "AudioCenterNew.h"
#import <hccoren/base.h>
#import <AVFoundation/AVFoundation.h>

#import "TheAmazingAudioEngine.h"
#import "AEPlaythroughChannel.h"
#import "AEExpanderFilter.h"
#import "AELimiterFilter.h"
#import "AEReverbFilter.h"
#import "AEDynamicsProcessorFilter.h"
#import "AERecorder.h"
#import "AEAudioFilePlayer.h"

#import "AEAudioUnitFilter.h"
#import "AENewTimePitchFilter.h"
#import "AEDelayFilter.h"


//#import "MTV.h"
//#import "Samples.h"
//#import "AudioConvert.h"


#define DEFAULT_GAIN 1

typedef enum {
    audioRouteBuiltInMicrophone                 = 1 << 0, //内置麦克风
    audioRouteBuiltInSpeaker                    = 1 << 1, //内置扬声器
    audioRouteBuiltInReceiver                   = 1 << 2, //内置听筒
} audioRoute;

@implementation AudioCenterNew
{
    AEAudioController *audioController_;
    AERecorder *recorder_;
    AEPlaythroughChannel *playThrough_;
    NSString *recordFilePath_;
    AEBlockFilter *gainFilter_;
    AEReverbFilter *reverbFilter_;
    AEDynamicsProcessorFilter *dynamicsProcessorFilter_;
    AEAudioFilePlayer *filePlayer_;
    float averagePower_;
    float waveSensitivity_;
    BOOL isAudioControllerStarted_;
    NSMutableDictionary *playingItemDictionary_;
    float playThrouVolume_;
    BOOL isGoing_;
    
    NSString * lastCategory_;
    BOOL lastControllerIsRun_;
    
    NSMutableArray * orginalFilters_;
    
    //    NSMutableDictionary * convertBlocks_;
    BOOL isRecordingType_;//当前的设置是否是录音模式，用于在录音过程中暂停，则不需要切换模式及通道。
    
}
//注意，这里主要用于处理停止audioController之后再次启动的时候原来的audioController还没有被dealloc以及多次重复启动audioController的问题
static bool continueTryStart; //1秒内不得重复启动关闭

#pragma mark - init

+ (instancetype)shareAudioCenter
{
    static dispatch_once_t t = 0;
    static AudioCenterNew *audioCenter = nil;
    dispatch_once(&t, ^{
        audioCenter = [[AudioCenterNew alloc] init];
    });
    return audioCenter;
}

dispatch_queue_t getAudioQueueNew()
{
    static dispatch_once_t t = 0;
    static dispatch_queue_t audioQueue = nil;
    dispatch_once(&t, ^{
        //        audioQueue = dispatch_queue_create("audioqueue", DISPATCH_QUEUE_SERIAL);
        audioQueue = dispatch_get_main_queue();
    });
    return audioQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        orginalFilters_ = [NSMutableArray new];
        //        convertBlocks_ = [NSMutableDictionary new];
        //        [self initController];
        //        [self stopAudioController];
        isRecordingType_ = NO;
        return self;
    }
    return nil;
}

- (void)initController
{
    if ([self isAudioQueueThread]) {
        [self initControllerInThread];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self initControllerInThread];
        });
    }
    //    if (![NSThread isMainThread]) {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            [self initControllerInThread];
    //        });
    //    }
    //    else{
    //        [self initControllerInThread];
    //    }
}

- (void)initControllerInThread
{
    if(audioController_ && isAudioControllerStarted_) return;
    if ([AEAudioController isAudioControllerAlloc] ){
        if(!audioController_)
        {
            NSLog(@"last audioController cannot be dealloc!!!!!!!!!!!!!!!!!");
            isGoing_ = NO;
            return;
        }
        else
        {
            return;
        }
    }
    AEAudioControllerOptions option = AEAudioControllerOptionEnableInput | AEAudioControllerOptionEnableOutput;
    audioController_ = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionNonInterleavedFloatStereo options:option];
}

- (void)setIsEcoCancellationEnable:(float)isEcoCancellationEnable
{
    audioController_.voiceProcessingEnabled = isEcoCancellationEnable;
}

#pragma mark - main funs
- (void)resetAll
{
    if ([self isAudioQueueThread]) {
        [self resetAllInThread];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self resetAllInThread];
        });
    }
}
- (void)resetAllInThread
{
    [self stopAudioController];
    [self resetAudioController:audioController_];
    audioController_ = nil;
    [self setAudioSessionCategory:AVAudioSessionCategoryPlayback];
}
- (void)startAudioController
{
    if (isGoing_ == YES) {
        return;
    }
    isGoing_ = YES;
    if (audioController_ && isAudioControllerStarted_) {
        isGoing_ = NO;
        return;
    }
    if(audioController_)
    {
        continueTryStart = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            continueTryStart = NO;
        });
        
        if ([self isAudioQueueThread]) {
            [self startAudioControllerInThread];
        }
        else{
            dispatch_async(getAudioQueueNew(), ^{
                [self startAudioControllerInThread];
            });
        }
    }
    else
    {
        isGoing_ = NO;
        [self initController];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), getAudioQueueNew(), ^{
            [self startAudioController];
        });
    }
}
- (void)startAudioControllerInThread
{
    while(!audioController_ && [AEAudioController isAudioControllerAlloc] && continueTryStart) {
        [NSThread sleepForTimeInterval:0.1];
    }
    if ([AEAudioController isAudioControllerAlloc] && !audioController_){
        NSLog(@"audioController cannot be dealloc!!!!!!!!!!!!!!!!!");
        isGoing_ = NO;
        return;
    }
    if (!audioController_) {
        [self initControllerInThread];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), getAudioQueueNew(), ^{
            if (audioController_ && !isAudioControllerStarted_) {
                [audioController_ start:NULL];
                isAudioControllerStarted_ = YES;
                if ([self isBuiltInOutput]) {
                    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
                }
            }
            isGoing_ = NO;
        });
    }
    else
    {
        if (audioController_ && !isAudioControllerStarted_) {
            [audioController_ start:NULL];
            isAudioControllerStarted_ = YES;
            if ([self isBuiltInOutput]) {
                [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            }
        }
        isGoing_ = NO;
    }
}

- (void)stopAudioController
{
    if ([self isAudioQueueThread]) {
        [self stopAudioControllerInThread];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self stopAudioControllerInThread];
        });
    }
}

//在移除之前记得要清理掉所有已经添加的设备
- (void)stopAudioControllerInThread
{
    if (audioController_ && isAudioControllerStarted_) {
        [audioController_ stop];
        isAudioControllerStarted_ = NO;
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        //            [self resetAudioController:audioController_];
        //            audioController_ = nil;
        //            isAudioControllerStarted_ = NO;
        //            NSLog(@"audioController stopped");
        //        });
    }
}
- (void)willEnterbackground
{
    lastCategory_ = [AVAudioSession sharedInstance].category;
    lastControllerIsRun_ = isAudioControllerStarted_;
    
    [self stopAudioController];
    if(!isRecordingType_)//录音状态，是不能够在后台播放的
    {
        if([lastCategory_ isEqualToString:AVAudioSessionCategoryPlayAndRecord])
        {
            [self setAudioSessionForPlayBack];
        }
    }
    
}
- (void)willBecomeActive
{
    if(lastCategory_ && ![lastCategory_ isEqualToString:[AVAudioSession sharedInstance].category])
    {
        if(isRecordingType_)
        {
            [self setAudioSessionForRecord];
        }
        else
        {
            [self setAudioSessionCategory:lastCategory_];
        }
    }
    if(lastControllerIsRun_)
    {
        [self startAudioController];
    }
}
#pragma mark - record
- (BOOL)startRecord
{
    __block BOOL ret;
    if ([self isAudioQueueThread]) {
        ret = [self startRecordInThread];
    }
    else{
        dispatch_sync(getAudioQueueNew(), ^{
            ret = [self startRecordInThread];
        });
    }
    return ret;
}

- (BOOL)startRecordInThread
{
    if ( recorder_) {
        return NO;
    }
    else {
        //防止有些时候切换耳机过程中默认的输出装置会变成听筒的问题
        if ([self isBuiltInOutput])
        {
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
        if(!isRecordingType_)
        {
            [self resetAudioController:audioController_];
            [self setAudioControllerForRecord:audioController_];
            isRecordingType_ = YES;
        }
        [self startAudioController];
        
        [self autoSetSensitivity];
        recorder_ = [[AERecorder alloc] initWithAudioController:audioController_];
        [self generateRecordFilePath];
        NSError *error = nil;
        if ( ![recorder_ beginRecordingToFileAtPath:recordFilePath_ fileType:kAudioFileM4AType error:&error] ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            
            recorder_ = nil;
            return NO;
        }
        else{
            NSLog(@"start recording!!!!!!!!!!!!!!!!!!!");
            [audioController_ addInputReceiver:recorder_];
            return YES;
        }
    }
}

- (BOOL)stopRecord
{
    __block BOOL ret;
    if ([self isAudioQueueThread]) {
        ret = [self stopRecordInThread];
    }
    else{
        dispatch_sync(getAudioQueueNew(), ^{
            ret = [self stopRecordInThread];
        });
    }
    return ret;
}

- (BOOL)stopRecordInThread
{
    if(recorder_){
        [recorder_ finishRecording];
        [audioController_ removeInputReceiver:recorder_];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            recorder_ = nil;
        });
        
        return YES;
    }
    return NO;
}

- (NSString *)getRecordFilePath
{
    return recordFilePath_;
}

//注意，这个地方获取到的当前时间不对，必须乘以2，有可能是因为双声道他计算公式有误
- (float)getCurrentSeconds
{
    //return recorder_.currentTime * 2;
    return recorder_.currentTime;
}

- (BOOL)isRecording
{
    return recorder_.recording;
}
#pragma - mark record ulti
- (void)generateRecordFilePath
{
    NSString * fileName = [NSString stringWithFormat:@"%ld.m4a",(long)[[NSDate date] timeIntervalSince1970]];
    recordFilePath_ = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    recordFilePath_ = [recordFilePath_ stringByAppendingPathComponent:@"recordfiles"]
    ;
    
    if(![HCFileManager createFileDirectories:recordFilePath_])
    {
        NSLog(@"cannot create directory:%@",recordFilePath_);
    }
    
    recordFilePath_ = [recordFilePath_ stringByAppendingPathComponent:fileName];
    NSLog(@"current recording file path is : %@", recordFilePath_);
}

- (audioRoute) getCurrentRoute
{
    audioRoute route = 0;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    
    if ( [currentRoute.outputs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"portType = %@", AVAudioSessionPortBuiltInSpeaker]].count > 0 ) {
        route = route | audioRouteBuiltInSpeaker;
        
    }
    
    NSLog(@"Current Output Route is %@", route & audioRouteBuiltInSpeaker ? @"built-in speaker" : @"not built-in speaker");
    
    if ( [currentRoute.outputs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"portType = %@", AVAudioSessionPortBuiltInReceiver]].count > 0 ) {
        route = route | audioRouteBuiltInReceiver;
        
    }
    
    NSLog(@"Current Output Route is %@", route & audioRouteBuiltInReceiver ? @"built-in receiver" : @"not built-in receiver");
    
    if ( [currentRoute.inputs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"portType = %@", AVAudioSessionPortBuiltInMic]].count > 0 ) {
        route = route | audioRouteBuiltInMicrophone;
    }
    NSLog(@"Current Input Route is %@", route & audioRouteBuiltInMicrophone ? @"built-in microphone" : @"not built-in microphone");
    return route;
}
- (BOOL)hasInputNotBuildIn
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSArray *inputs  = audioSession.availableInputs;
#ifndef __OPTIMIZE__
    for (AVAudioSessionPortDescription * port in inputs) {
        NSLog(@"porttype:%@ portname:%@",port.portType,port.portName);
    }
#endif
    if ( [inputs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"portType != %@", AVAudioSessionPortBuiltInMic]].count > 0 ) {
        return YES;
    }
    return NO;
}
- (BOOL)isBuiltInOutput
{
    audioRoute route = [self getCurrentRoute];
    if ((route & audioRouteBuiltInReceiver) || (route & audioRouteBuiltInSpeaker)) {
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark - play through
- (BOOL)startPlayThrough
{
    __block BOOL ret;
    if ([self isAudioQueueThread]) {
        ret = [self startPlayThroughInThread];
    }
    else{
        dispatch_sync(getAudioQueueNew(), ^{
            ret = [self startPlayThroughInThread];
        });
    }
    return ret;
}

- (BOOL)startPlayThroughInThread
{
    if (playThrough_) {
        return NO;
    }
    [self startAudioController];
    
    playThrough_ = [[AEPlaythroughChannel alloc] init];
    [playThrough_ setupWithAudioController:audioController_];
    
    playThrough_.volume = playThrouVolume_;
    [audioController_ addInputReceiver:playThrough_];
    [audioController_ addChannels:@[playThrough_]];
    return YES;
}

- (BOOL)stopPlayThrough
{
    __block BOOL ret;
    if ([self isAudioQueueThread]) {
        ret = [self stopPlayThroughInThread];
    }
    else{
        dispatch_sync(getAudioQueueNew(), ^{
            ret = [self stopPlayThroughInThread];
        });
    }
    return ret;
}

- (BOOL)stopPlayThroughInThread
{
    if (playThrough_) {
        [audioController_ removeChannels:@[playThrough_]];
        [audioController_ removeInputReceiver:playThrough_];
        playThrough_ = nil;
        return YES;
    }
    return NO;
}


- (void)setInputSensitivity:(float) sensitivity;
{
    if ([self isAudioQueueThread]) {
        [self setInputSensitivityInThread:sensitivity];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self setInputSensitivityInThread:sensitivity];
        });
    }
}
#pragma mark - setup
- (void)setInputSensitivityInThread:(float) sensitivity;
{
    if (audioController_.inputGainAvailable) {
        audioController_.inputGain = sensitivity;
        NSLog(@"input sensitivity has been set to %f", sensitivity);
    }
}

- (void)autoSetSensitivity
{
    if ([self getCurrentRoute] & audioRouteBuiltInMicrophone) {
        [self setInputSensitivity:1];
        waveSensitivity_ = 100;
        NSLog(@"wave sensitivity has been set to %.2f, Input sensitivity has been set 1", waveSensitivity_);
    }
    else{
        [self setInputSensitivity:1];
        waveSensitivity_ = 100;
        NSLog(@"wave sensitivity has been set to %.2f, Input sensitivity has been set to 1",waveSensitivity_);
    }
}
- (void)setPlayThroughVolume:(float)volume
{
    if ([self isAudioQueueThread]) {
        [self setPlayThroughVolumeInThread:volume];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self setPlayThroughVolumeInThread:volume];
        });
    }
}

- (void)setPlayThroughVolumeInThread:(float)volume
{
    playThrouVolume_ = volume;
    playThrough_.volume = volume;
}

- (void)setReverbLevel:(int)reverbLevel
{
    if ([self isAudioQueueThread]) {
        [self setReverbLevelInThread:reverbLevel];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self setReverbLevelInThread:reverbLevel];
        });
    }
}

//这个地方可以用于调节具体的reverb和dynamicProcessing的参数
- (void)setReverbLevelInThread:(int)reverbLevel
{
    if (reverbFilter_) {
        switch (reverbLevel) {
            case 0:
                reverbFilter_.dryWetMix = 0;
                dynamicsProcessorFilter_.masterGain = 0;
                break;
            case 1:
                reverbFilter_.dryWetMix = 10;
                reverbFilter_.gain = 0;
                reverbFilter_.minDelayTime = 0.02;
                reverbFilter_.maxDelayTime = 0.05;
                reverbFilter_.decayTimeAt0Hz = 5.04;
                reverbFilter_.decayTimeAtNyquist = 1.52;
                reverbFilter_.randomizeReflections = 1;
                reverbFilter_.filterFrequency = 800;
                reverbFilter_.filterBandwidth = 3;
                reverbFilter_.filterGain = 0;
                dynamicsProcessorFilter_.threshold = -15.2;
                dynamicsProcessorFilter_.headRoom = 3.16;
                dynamicsProcessorFilter_.expansionRatio = 15.21;
                dynamicsProcessorFilter_.attackTime = 0.16;
                dynamicsProcessorFilter_.releaseTime = 1.5;
                dynamicsProcessorFilter_.masterGain = 3.47;
                break;
            case 2:
                reverbFilter_.dryWetMix = 15.4;
                reverbFilter_.gain = 0;
                reverbFilter_.minDelayTime = 0.02;
                reverbFilter_.maxDelayTime = 0.05;
                reverbFilter_.decayTimeAt0Hz = 5.04;
                reverbFilter_.decayTimeAtNyquist = 1.52;
                reverbFilter_.randomizeReflections = 1;
                reverbFilter_.filterFrequency = 800;
                reverbFilter_.filterBandwidth = 3;
                reverbFilter_.filterGain = 0;
                dynamicsProcessorFilter_.threshold = -15.2;
                dynamicsProcessorFilter_.headRoom = 3.16;
                dynamicsProcessorFilter_.expansionRatio = 15.21;
                dynamicsProcessorFilter_.attackTime = 0.16;
                dynamicsProcessorFilter_.releaseTime = 1.5;
                dynamicsProcessorFilter_.masterGain = 3.47;
                break;
            default:
                break;
        }
    }
    else
    {
        NSLog(@"error : AudioController not Started, can't set property");
    }
}

- (void)setAudioSessionCategory:(NSString *)category
{
    if(!category) return;
    if ([self isAudioQueueThread]) {
        [self setAudioSessionCategoryInThread:category];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self setAudioSessionCategoryInThread:category];
        });
    }
}

- (void)setAudioSessionCategoryInThread:(NSString *)category
{
    if([AVAudioSession sharedInstance].category!=category && !audioController_)
    {
        NSError * error = nil;
        [[AVAudioSession sharedInstance]setCategory:category error:&error];
        if(error)
        {
            NSLog(@"setcategory failure:%@",[error localizedDescription]);
        }
    }
    else if (audioController_.audioSessionCategory != category) {
        audioController_.audioSessionCategory = category;
    }
}
- (void)setAudioSessionForRecord
{
    if ([self isAudioQueueThread]) {
        [self setAudioSessionForRecordInThread];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self setAudioSessionForRecordInThread];
        });
    }
}

- (void)setAudioSessionForRecordInThread
{
    if([AVAudioSession sharedInstance].category!=AVAudioSessionCategoryPlayAndRecord)
    {
        audioController_.audioSessionCategory = AVAudioSessionCategoryPlayAndRecord;
    }
    else if (audioController_.audioSessionCategory != AVAudioSessionCategoryPlayAndRecord) {
        audioController_.audioSessionCategory = AVAudioSessionCategoryPlayAndRecord;
    }
}

- (void)setAudioSessionForPlayBack
{
    if ([self isAudioQueueThread]) {
        [self setAudioSessionForPlayBackInThread];
    }
    else{
        dispatch_async(getAudioQueueNew(), ^{
            [self setAudioSessionForPlayBackInThread];
        });
    }
}

- (void)setAudioSessionForPlayBackInThread
{
    if([AVAudioSession sharedInstance].category!=AVAudioSessionCategoryPlayback)
    {
        audioController_.audioSessionCategory = AVAudioSessionCategoryPlayback;
    }
    else if (audioController_.audioSessionCategory != AVAudioSessionCategoryPlayback) {
        audioController_.audioSessionCategory = AVAudioSessionCategoryPlayback;
    }
}


#pragma mark - ae
- (NSArray *)getChannelsForUrls:(NSArray *)urlsWithSettings longestPlayer:(AEAudioFilePlayer **)longestPlayer duration:(NSTimeInterval *)durationTotal
{
    NSMutableArray * channels = [NSMutableArray new];
    NSTimeInterval longestTime = 0;
    if(!urlsWithSettings) return channels;
    
    for (NSDictionary * item in urlsWithSettings) {
        NSError * error = nil;
        NSURL * url = [item objectForKey:@"url"];
        CGFloat startSeconds = 0;
        CGFloat duration = 0;
        if([item objectForKey:@"start"])
            startSeconds = [[item objectForKey:@"start"]floatValue];
        if(startSeconds <0) startSeconds = 0;
        
        CGFloat vol = 1;
        if([item objectForKey:@"vol"])
            vol = [[item objectForKey:@"vol"]floatValue];
        
        if([item objectForKey:@"duration"])
        {
            duration = [[item objectForKey:@"duration"]floatValue];
        }
        
        AEAudioFilePlayer *aePlayer = [[AEAudioFilePlayer alloc] initWithURL:url error:&error];
        if(error)
        {
            NSLog(@"load player failure:%@",[error localizedDescription]);
            continue;
        }
        aePlayer.volume = vol;
        //        aePlayer.loop = YES;
        if(startSeconds>0)
        {
            [aePlayer setRegionStartTime:startSeconds];
        }
        else
            startSeconds = 0;
        
        //计算播放时长
        if(duration>0)
        {
            if(duration < aePlayer.duration - startSeconds)
            {
                [aePlayer setRegionDuration:duration];
            }
            else
            {
                duration = aePlayer.duration - startSeconds;
            }
        }
        else
            duration = aePlayer.duration - startSeconds;
        
        
        if(longestTime < duration)
        {
            longestTime = duration;
            if(longestPlayer)
            {
                *longestPlayer = aePlayer;
            }
        }
        [channels addObject:aePlayer];
    }
    if(durationTotal)
    {
        *durationTotal = longestTime;
    }
    return channels;
}
- (BOOL)playItemsWithOptions:(NSArray *)urlsWithSettings
                     options:(NSArray *)options completionBlock:(void(^)(void))completionBlock
{
    [self initControllerInThread];
    [self resetAudioController:audioController_];
    [audioController_  setInputEnabled:YES error:nil];
    
    audioController_.useMeasurementMode = YES;
    
    if(options)
    {
        for (AEAudioUnitFilter * filter in options) {
            if([filter isKindOfClass:[AEAudioUnitFilter class]] )
            {
                [audioController_ addFilter:filter];
            }
        }
    }
    [self startAudioControllerInThread];
    
    AEAudioFilePlayer * longestPlayer = nil;
    
    NSArray * channels = [self getChannelsForUrls:urlsWithSettings longestPlayer:&longestPlayer duration:nil];
    
    [audioController_ addChannels:channels];
    
    if(longestPlayer)
    {
        longestPlayer.completionBlock = ^(void)
        {
            [self stopWithOptions:nil];
            if(completionBlock)
            {
                completionBlock();
            }
            for (AEAudioUnitChannel * item in channels) {
                [item teardown];
            }
        };
    }
    else
    {
        if(completionBlock)
        {
            completionBlock();
        }
        for (AEAudioUnitChannel * item in channels) {
            [item teardown];
        }
        channels = nil;
    }
    
    
    
    return YES;
}
- (BOOL)playWithOptions:(NSURL *)url options:(NSArray *)options completionBlock:(void(^)(void))completionBlock
{
    [self initControllerInThread];
    [self resetAudioController:audioController_];
    [audioController_  setInputEnabled:YES error:nil];
    
    audioController_.useMeasurementMode = YES;
    
    if(options)
    {
        for (AEAudioUnitFilter * filter in options) {
            if([filter isKindOfClass:[AEAudioUnitFilter class]] )
            {
                [audioController_ addFilter:filter];
            }
        }
    }
    
    
    [self startAudioControllerInThread];
    
    NSError * error = nil;
    AEAudioFilePlayer *aePlayer = [[AEAudioFilePlayer alloc] initWithURL:url error:&error];
    if(error)
    {
        NSLog(@"load player failure:%@",[error localizedDescription]);
    }
    
    [audioController_ addChannels:@[aePlayer]];
    
    aePlayer.completionBlock = ^(void)
    {
        [self stopWithOptions:nil];
        if(completionBlock)
        {
            completionBlock();
        }
    };
    
    
    return YES;
}

- (BOOL)pauseWithOptions:(NSArray *)options
{
    return NO;
}
- (BOOL)stopWithOptions:(NSArray *)options
{
    [audioController_ stop];
    isAudioControllerStarted_ = NO;
    return YES;
}

#pragma mark - setAudioController
- (void)setAudioControllerForRecord:(AEAudioController *)controller
{
    [audioController_  setInputEnabled:YES error:nil];
    [audioController_  setOutputEnabled:YES error:nil];
    
    controller.useMeasurementMode = YES;
    
    reverbFilter_ = [[AEReverbFilter alloc] init];
    [controller addInputFilter:reverbFilter_];
    dynamicsProcessorFilter_ = [[AEDynamicsProcessorFilter alloc] init];
    [controller addInputFilter:dynamicsProcessorFilter_];
    playingItemDictionary_ = [NSMutableDictionary new];
    //audioController_.allowMixingWithOtherApps = NO;
    
    playThrouVolume_ = 1;
    
    self.audioGain = DEFAULT_GAIN;
    if (self.audioGain != 1) {
        gainFilter_ = [AEBlockFilter filterWithBlock:^(AEAudioFilterProducer producer, void *producerToken, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            producer(producerToken, audio, &frames);
            float *outputBuffer0 = audio->mBuffers[0].mData;
            float *outputBuffer1 = audio->mBuffers[1].mData;
            for (int i = 0; i < frames; i ++) {
                outputBuffer0[i] = outputBuffer0[i] * _audioGain;
                outputBuffer1[i] = outputBuffer1[i] * _audioGain;
            }
            audio->mBuffers[0].mData = outputBuffer0;
            audio->mBuffers[1].mData = outputBuffer1;
        }];
        [controller addInputFilter:gainFilter_];
    }
    isRecordingType_ = YES;
}
- (void)resetAudioController:(AEAudioController *)controller
{
    if(controller && isAudioControllerStarted_)
    {
        [controller stop];
        isAudioControllerStarted_ = NO;
    }
    [self stopPlayThrough];
    [self stopRecord];
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
    [controller removeChannels:[controller channels]];
    for (id<AEAudioFilter> item in [controller inputFilters]){
        [controller removeInputFilter:item];
    }
    for (id<AEAudioFilter> item in [controller filters]){
        [controller removeFilter:item];
    }
    for (id<AEAudioReceiver> item in [controller inputReceivers]) {
        [controller removeInputReceiver:item];
    }
    for (id<AEAudioReceiver> item in [controller outputReceivers]) {
        [controller removeOutputReceiver:item];
    }
    for (id<AEAudioTimingReceiver> item in [controller timingReceivers]) {
        [controller removeTimingReceiver:item];
    }
    isRecordingType_ = NO;
    //        });
}
#pragma mark - get set
- (BOOL)didAudioControllerStarted
{
    if (!audioController_ && [AEAudioController isAudioControllerAlloc] && continueTryStart) {
        return NO;
    } else {
        if ([AEAudioController isAudioControllerAlloc]) {
            return isAudioControllerStarted_;
        } else {
            return NO;
        }
    }
}
- (BOOL)didAudioControllerStopped
{
    if (audioController_ && isAudioControllerStarted_) {
        return ![AEAudioController isAudioControllerAlloc];
    }
    return YES;
}
- (BOOL) isRecordMode
{
    return isRecordingType_;
}
- (BOOL)isAudioQueueThread
{
    return [NSThread isMainThread];
    //    return dispatch_get_current_queue() == getAudioQueueNew();
}

- (BOOL)isUseBuildinSpeaker
{
    return [self getCurrentRoute] & audioRouteBuiltInSpeaker;
}

- (BOOL)isForceOutputSpeaker
{
    audioRoute route = [self getCurrentRoute];
    //    return route & audioRouteBuiltInSpeaker &&
    return route & audioRouteBuiltInReceiver;
}
- (NSArray *)getMicrophones
{
    NSMutableArray * mps = [NSMutableArray new];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSArray *inputs  = audioSession.availableInputs;
    for (AVAudioSessionPortDescription * port in inputs) {
        //        NSLog(@"porttype:%@ portname:%@",port.portType,port.portName);
        //        NSString * item = [NSString stringWithFormat:@"%@-%@",port.portType,port.portName];
        //        if(item && item.length>0)
        //        {
        [mps addObject:port];
        //        }
    }
    return PP_AUTORELEASE(mps);
}
- (AEAudioController *)getCurrentAudioController
{
    return audioController_;
}
- (AEReverbFilter *)getReverbFilter
{
    return reverbFilter_;
}

- (AEDynamicsProcessorFilter *)getDynamicsProcessorFilter
{
    return dynamicsProcessorFilter_;
}
- (float)getCurrentInputPower
{
    __block float ret;
    if ([self isAudioQueueThread]) {
        ret = [self getCurrentInputPowerInThread];
    }
    else{
        dispatch_sync(getAudioQueueNew(), ^{
            ret = [self getCurrentInputPowerInThread];
        });
    }
    return ret;
}

- (float)getCurrentInputPowerInThread;
{
    float power;
    [audioController_ inputAveragePowerLevel:&power peakHoldLevel:NULL];
    //    NSLog(@"wave power is %f", power);
    power = pow (10, power/waveSensitivity_);
    if (power > 1) {
        power = 1;
    }
    //这里是为了让波形显得更加平滑
    averagePower_ = 0.5 * averagePower_ + 0.5 * power;
    return averagePower_;
}

@end
