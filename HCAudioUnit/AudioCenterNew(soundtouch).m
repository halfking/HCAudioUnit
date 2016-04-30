//
//  AudioCenterNew(soundtouch).m
//  maiba
//
//  Created by HUANGXUTAO on 16/2/24.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "AudioCenterNew(soundtouch).h"
#import <hccoren/base.h>
#import "AENewTimePitchFilter.h"
#import "AEDelayFilter.h"
#import "AEReverbFilter.h"
#import "AEDynamicsProcessorFilter.h"
//#import "AudioGenerater.h"

@implementation AudioCenterNew(soundtouch)
#pragma mark - 变调
//此函数未完成
- (NSArray *)createFileBySoundTouch:(NSString *)sourcePath
                    targetPath:(NSString *)targetPath
                         options:(NSArray *)options
                     completed:(ConvertCompleted) completed
{
    
    NSMutableArray * otherOptions = [NSMutableArray new];
    AudioConvertConfig dconfig;
    dconfig.outputFormat = AudioConvertOutputFormat_MP3;
    dconfig.outputChannelsPerFrame = 2;
    dconfig.outputSampleRate = 44100;
    dconfig.soundTouchPitch = 0;
    dconfig.soundTouchRate = 1;
    dconfig.soundTouchTempoChange = 0;
    
    for (AEAudioUnitFilter * filter in options) {
        if([filter isKindOfClass:[AENewTimePitchFilter class]])
        {
            AENewTimePitchFilter * pitchFilter = (AENewTimePitchFilter *)filter;
            dconfig.soundTouchPitch =  (float)pitchFilter.pitch /2400 * 12;
            dconfig.soundTouchTempoChange = powf(2,pitchFilter.rate);

        }
        else
        {
            [otherOptions addObject:filter];
        }
    }
    
    return otherOptions;
}
// int        tempo;   //速度 <变速不变调> 范围 -50 ~ 100
//int        pitch;         //音调  范围 -12 ~ 12
//int        rate;          //声音速率 范围 -50 ~ 100
- (void)createFileBySoundTouch:(NSString *)sourcePath
                    targetPath:(NSString *)targetPath
                         pitch:(int)pitch
                         tempo:(int)tempo
                          rate:(int)rate
                     completed:(ConvertCompleted) completed
{
    AudioConvertConfig dconfig;
    dconfig.outputFormat = AudioConvertOutputFormat_MP3;
    dconfig.outputChannelsPerFrame = 2;
    dconfig.outputSampleRate = 44100;
    dconfig.soundTouchPitch = pitch;
    dconfig.soundTouchRate = rate;
    dconfig.soundTouchTempoChange = tempo;
    [self createFileBySoundTouch:sourcePath targetPath:targetPath config:dconfig completed:completed];
}

- (void)createFileBySoundTouch:(NSString *)sourcePath
                    targetPath:(NSString *)targetPath
                        config:(AudioConvertConfig)dconfig
                     completed:(ConvertCompleted) completed

{
    //    NSString *p =  [[NSBundle mainBundle] pathForResource:@"一生无悔高安" ofType:@"mp3"];
    //    AudioConvertConfig dconfig;
    //    dconfig.sourceAuioPath = [p UTF8String];
    //    dconfig.outputFormat = outputFormat;
    //    dconfig.outputChannelsPerFrame = 2;
    //    dconfig.outputSampleRate = 44100;
    //    dconfig.soundTouchPitch = pitchSemiTonesNum;
    //    dconfig.soundTouchRate = rateChangeNum;
    //    dconfig.soundTouchTempoChange = tempoChangeNum;
    
    __block AudioConvertConfig configNew = dconfig;
    //如果是视频，则需要将声音导出
    if(targetPath && targetPath.length>0)
    {
        configNew.targetAudioPath = [targetPath UTF8String];
    }
    convertCompleted_ = completed;
    
    if([HCFileManager isVideoFile:sourcePath])
    {
        NSAssert(NO,@"此函数未实现");
//        NSLog(@"begin abstract audio from video:%@",[sourcePath lastPathComponent]);
////        SeenVideoQueue * queue = [[SeenVideoQueue alloc]init];
//        AudioGenerater * gen = [AudioGenerater new];
//        if(![gen createAudioFromVideo:[NSURL fileURLWithPath:sourcePath] completed:^(NSURL *audioUrl, NSError *error) {
//            if(error)
//            {
//                NSLog(@"abstract failure:%@",[error localizedDescription]);
//                if(convertCompleted_)
//                    convertCompleted_(nil,error);
//            }
//            else
//            {
//                NSString * path = [CommonUtil checkPath:[audioUrl absoluteString]];
//                if(path && path.length>0)
//                {
//                    configNew.sourceAuioPath = [path UTF8String];
//                }
//                NSLog(@"abstract completed:%@",path);
//                
//                [[AudioConvert shareAudioConvert] audioConvertBegin:configNew withCallBackDelegate:self];
//            }
//        }])
//        {
//            if(convertCompleted_)
//            {
//                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"从视频中抽取音频失败"
//                                                                     forKey:NSLocalizedDescriptionKey];
//                NSError *aError = [NSError errorWithDomain:@"com.seenvoice.maiba" code:-1000 userInfo:userInfo];
//                convertCompleted_(nil,aError);
//                convertCompleted_ = nil;
//            }
//        }
////        queue = nil;
//        return;
    }
    if(sourcePath && sourcePath.length>0)
    {
        configNew.sourceAuioPath = [sourcePath UTF8String];
    }
    NSAssert(NO,@"此函数未实现");
//    [[AudioConvert shareAudioConvert] audioConvertBegin:configNew withCallBackDelegate:self];
}

#pragma mark - AudioConvertDelegate
- (BOOL)audioConvertOnlyDecode
{
    return  NO;
}
- (BOOL)audioConvertHasEnecode
{
    return YES;
}


/**
 * 对音频解码动作的回调
 **/
- (void)audioConvertDecodeSuccess:(NSString *)audioPath {
    //解码成功
}
- (void)audioConvertDecodeFaild
{
    //解码失败
    NSLog(@"解码失败");
}

/**
 * 对音频变声动作的回调
 **/
- (void)audioConvertSoundTouchSuccess:(NSString *)audioPath
{
    //变声成功
}


- (void)audioConvertSoundTouchFail
{
    //变声失败
}

/**
 * 对音频编码动作的回调,对文件处理
 **/

- (void)audioConvertEncodeSuccess:(NSString *)audioPath
{
    //编码完成
    //    [self playAudio:audioPath];
    NSLog(@"convert completed:%@",audioPath?audioPath:@"null");
    if(convertCompleted_)
    {
        convertCompleted_(audioPath,nil);
        convertCompleted_ = nil;
    }
    //    ConvertCompleted block = [convertBlocks_ objectForKey:audioPath];
    //    if(block)
    //    {
    //        block(audioPath,nil);
    //        [convertBlocks_ removeObjectForKey:audioPath];
    //        block = nil;
    //    }
}

- (void)audioConvertEncodeFaild
{
    //编码失败
    //    [SVProgressHUD showErrorWithStatus:@"编码失败"];
    //    [self stopAudio];
    NSLog(@"convert failure");
    if(convertCompleted_)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"编码失败"
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"com.seenvoice.maiba" code:-1000 userInfo:userInfo];
        convertCompleted_(nil,aError);
        convertCompleted_ = nil;
        aError = nil;
    }
}
#pragma mark -
//利用AEAudioController来完成音效的写入文件工作，现在暂时有BUG
//- (BOOL)writeFiles:(NSString *)sourcePath targetFile:(NSString *)filePath
//        controller:(AEAudioController *)audioController
//           options:(NSArray *)options
////写音频文件
//{
//    //    [self play];
//    
//    //    [audioController stop];
//    if(!audioController)
//    {
//        audioController = [self getCurrentAudioController];
//        if(!audioController)
//        {
//            NSLog(@"audiocontroller is null.");
//            return NO;
//        }
//        [self resetAudioController:audioController];
//        if(options)
//        {
//            for (AEAudioUnitFilter * filter in options) {
//                if([filter isKindOfClass:[AEAudioUnitFilter class]] )
//                {
//                    [audioController addFilter:filter];
//                }
//            }
//        }
//    }
//    [audioController  setInputEnabled:NO error:nil];
//    
//    const int kBufferLength = 4096;
//    NSURL * sourceUrl = [NSURL fileURLWithPath:sourcePath];
//    
//    NSError * error = nil;
//    AEAudioFilePlayer *aePlayer = [[AEAudioFilePlayer alloc] initWithURL:sourceUrl error:&error];
//    if(error)
//    {
//        NSLog(@"load player failure:%@",[error localizedDescription]);
//    }
//    
//    [audioController addChannels:@[aePlayer]];
//    [audioController start:nil];
//    [audioController stop];
//    
//    //    [aePlayer playAtTime:0];
//    
//    //    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:sourceUrl
//    //                                                                         targetAudioDescription:audioController_.audioDescription];
//    //    [operation start];
//    //    if ( operation.error ) {
//    //        // Load failed! Clean up, report error, etc.
//    //        NSLog(@"load audio file failure:%@",[operation.error localizedDescription]);
//    //        return NO;
//    //    }
//    //    AudioBufferList * audioBuffers = operation.bufferList;
//    //    UInt32 lengthInFrames = operation.lengthInFrames;
//    
//    
//    NSTimeInterval renderDuration = aePlayer.duration;
//    Float64 sampleRate = audioController.audioDescription.mSampleRate;
//    UInt32 lengthInFrames = (UInt32) (renderDuration * sampleRate);
//    
//    
//    Boolean outIsOpen = NO;
//    
//    AUGraphClose(audioController.audioGraph);
//    
//    AUGraphIsOpen(audioController.audioGraph, &outIsOpen);
//    
//    NSLog(@"AUGraph is open:%d",outIsOpen);
//    
//    AudioTimeStamp timeStamp;
//    memset (&timeStamp, 0, sizeof(timeStamp));
//    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
//    AEAudioFileWriter *audioFileWriter =
//    [[AEAudioFileWriter alloc] initWithAudioDescription:audioController.audioDescription];
//    AudioBufferList *buf =
//    AEAllocateAndInitAudioBufferList(audioController.audioDescription, kBufferLength);
//    [audioFileWriter beginWritingToFileAtPath:filePath fileType:kAudioFileM4AType error:nil];
//    
//    for (UInt64 i = 0; i < lengthInFrames; i += kBufferLength) {
//        
//        AEAudioControllerRenderMainOutput(audioController, timeStamp, kBufferLength, buf);
//        
//        timeStamp.mSampleTime += kBufferLength;
//        OSStatus status = AEAudioFileWriterAddAudioSynchronously(audioFileWriter, buf, kBufferLength);
//        if (status != noErr) {
//            NSLog(@"ERROR: %d", (int) status);
//        }
//    }
//    [audioFileWriter finishWriting];
//    AEFreeAudioBufferList(buf);
//    
//    AUGraphOpen(audioController.audioGraph);
//    [audioController start:nil];
//    [audioController stop];
//    
//    NSLog(@"Finished");
//    return YES;
//}
//

#pragma mark - player 作废
//- (NSNumber *)initializeAudioPlayerWithURL:(NSURL *)URL
//{
//    __block NSNumber* ret;
//    if ([self isAudioQueueThread]) {
//        ret = [self initializeAudioPlayerWithURLInThread:URL];
//    }
//    else{
//        dispatch_sync(getAudioQueueNew(), ^{
//            ret = [self initializeAudioPlayerWithURLInThread:URL];
//        });
//    }
//    return ret;
//}
//
//- (NSNumber *)initializeAudioPlayerWithURLInThread:(NSURL *)URL
//{
//    NSNumber *itemID = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]];
//    AEAudioFilePlayer *player = [[AEAudioFilePlayer alloc] initWithURL:URL error:nil];
//    [playingItemDictionary_ setObject:player forKey:itemID];
//    player.removeUponFinish = YES;
//    return itemID;
//}
//
//- (void)playItemID:(NSNumber *)itemID
//{
//    if ([self isAudioQueueThread]) {
//        [self playItemIDInThread:itemID];
//    }
//    else{
//        dispatch_async(getAudioQueueNew(), ^{
//            [self playItemIDInThread:itemID];
//        });
//    }
//}
//
//- (void)playItemIDInThread:(NSNumber *)itemID
//{
//    AEAudioFilePlayer *player = [playingItemDictionary_ objectForKey:itemID];
//    if (![self isPlyerPlaying:player]) {
//        [audioController_ addChannels:@[player]];
//    }
//}
//
//- (void)pauseForItemID:(NSNumber *)itemID
//{
//    if ([self isAudioQueueThread]) {
//        [self pauseForItemIDInThread:itemID];
//    }
//    else{
//        dispatch_async(getAudioQueueNew(), ^{
//            [self pauseForItemIDInThread:itemID];
//        });
//    }
//}
//
//- (void)pauseForItemIDInThread:(NSNumber *)itemID
//{
//    AEAudioFilePlayer *player = [playingItemDictionary_ objectForKey:itemID];
//    if ([self isPlyerPlaying:player]) {
//        [audioController_ removeChannels:@[player]];
//    }
//}
//
//- (void)removePlayerForItemID:(NSNumber *)itemID
//{
//    if ([self isAudioQueueThread]) {
//        [self removePlayerForItemIDInThread:itemID];
//    }
//    else{
//        dispatch_async(getAudioQueueNew(), ^{
//            [self removePlayerForItemIDInThread:itemID];
//        });
//    }
//}
//
//- (void)removePlayerForItemIDInThread:(NSNumber *)itemID
//{
//    AEAudioFilePlayer *player = [playingItemDictionary_ objectForKey:itemID];
//    if (player) {
//        if ([self isPlyerPlaying:player]) {
//            [audioController_ removeChannels:@[player]];
//        }
//        [playingItemDictionary_ removeObjectForKey:itemID];
//        player = nil;
//    }
//}
//
//- (void)seekToSeconds:(float)seconds forItemID:(NSNumber *)itemID
//{
//    if ([self isAudioQueueThread]) {
//        [self seekToSeconds:seconds forItemIDInThread:itemID];
//    }
//    else{
//        dispatch_async(getAudioQueueNew(), ^{
//            [self seekToSeconds:seconds forItemIDInThread:itemID];
//        });
//    }
//}
//
//- (void)seekToSeconds:(float)seconds forItemIDInThread:(NSNumber *)itemID
//{
//    AEAudioFilePlayer *player = [playingItemDictionary_ objectForKey:itemID];
//    if (player) {
//        if (![self isPlyerPlaying:player]) {
//            [audioController_ addChannels:@[player]];
//        }
//        player.currentTime = seconds;
//    }
//}
//
//- (BOOL)isPlyerPlaying:(AEAudioFilePlayer *)player
//{
//    __block BOOL ret;
//    if ([self isAudioQueueThread]) {
//        ret = [self isPlyerPlayingInThread:player];
//    }
//    else{
//        dispatch_sync(getAudioQueueNew(), ^{
//            ret = [self isPlyerPlayingInThread:player];
//        });
//    }
//    return ret;
//}
//
//- (BOOL)isPlyerPlayingInThread:(AEAudioFilePlayer *)player
//{
//    for (id<AEAudioPlayable> channel in audioController_.channels) {
//        if (channel == player) {
//            return YES;
//        }
//    }
//    return NO;
//}
@end
