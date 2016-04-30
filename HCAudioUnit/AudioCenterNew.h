//
//  AudioCenterNew.h
//  maiba
//
//  Created by HUANGXUTAO on 16/2/18.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ConvertCompleted) (NSString * audioPath,NSError * error);

@class AEAudioFilePlayer;
@class AEAudioController;
@class AEReverbFilter;
@class AEDynamicsProcessorFilter;

//typedef enum {
//    audioRouteBuiltInMicrophone                 = 1 << 0, //内置麦克风
//    audioRouteBuiltInSpeaker                    = 1 << 1, //内置扬声器
//    audioRouteBuiltInReceiver                   = 1 << 2, //内置听筒
//} audioRoute;
/*
 此类用于音频相关的处理
 1、录音及在录音过程中加入混音等操作
 2、播放，在播放过程中加入音调调整
 3、创建Mp3，并在其中加入单调调整
 特别对于录音，涉及到输入与输出的控制，比较复杂。
 
 */
@interface AudioCenterNew : NSObject
{
    ConvertCompleted convertCompleted_;
    NSMutableArray * effectFiltersForType0_;
    NSMutableArray * effectFiltersForType1_;
}
@property(nonatomic, assign) float audioGain; //音量增益（1为不增益）
@property(nonatomic, assign) float isEcoCancellationEnable; //是否开启回音消除


+(instancetype)shareAudioCenter;

- (void)resetAll;
//启动audioController，已经启动不会重复启动
- (void)initController;
- (void)startAudioController;

//关闭audioController
- (void)stopAudioController;

- (void)willEnterbackground;
- (void)willBecomeActive;
#pragma mark - record

- (BOOL)startRecord;
- (BOOL)stopRecord;
- (NSString *)getRecordFilePath;
- (float)getCurrentSeconds;
- (BOOL)isRecording;

#pragma mark - play through
//开始返听
- (BOOL)startPlayThrough;
- (BOOL)stopPlayThrough;

#pragma mark - setup
- (void)setInputSensitivity:(float)sensitivity; //输入敏感度，最高为1
- (void)autoSetSensitivity;//根据当前使用的输入设备自动设置输入敏感度
- (void)setReverbLevel:(int)reverbLevel; //设置混响强度：0,1,2，最强为2
- (void)setPlayThroughVolume:(float)volume; //设置返听音量



//设置为录音时的audioSession
- (void)setAudioSessionForRecord;

//设置为播放时的audioSession
- (void)setAudioSessionForPlayBack;
- (void)setAudioSessionCategory:(NSString *)category;

////获取当前输入输出设备
//- (audioRoute) getCurrentRoute;
//
////当前是否是内置输入输出设备
//- (bool) isBuiltInOutput;

#pragma mark - New Functions
- (BOOL)playWithOptions:(NSURL *)url options:(NSArray *)options completionBlock:(void(^)(void))completionBlock;

- (BOOL)playItemsWithOptions:(NSArray *)urlsWithSettings
                     options:(NSArray *)options completionBlock:(void(^)(void))completionBlock;
/*
 NSArray * urls = @[
 @{@"url":[NSURL fileURLWithPath:self.recordFilePath.text],
 @"start":@(0), //从文件中的什么位置开始
 @"vol":@(1),    //音量
 @"duration":@(-1)   //播放多长一段，-1表示不设置
 },
 @{@"url":[NSURL fileURLWithPath:path2],
 @"start":@(0),
 @"vol":@(0.1),
 @"duration":@(-1)
 }
 ];
 */
- (NSArray *)getChannelsForUrls:(NSArray *)urlsWithSettings longestPlayer:(AEAudioFilePlayer **)longestPlayer duration:(NSTimeInterval *)durationTotal;

- (BOOL)pauseWithOptions:(NSArray *)options;
- (BOOL)stopWithOptions:(NSArray *)options;

- (void)setAudioControllerForRecord:(AEAudioController *)controller;
- (void)resetAudioController:(AEAudioController *)controller;

// 标识AudioController Started Stoped
#pragma mark - get set
- (BOOL)didAudioControllerStarted;
- (BOOL)didAudioControllerStopped;
- (BOOL) isRecordMode;
- (float)getCurrentInputPower; //获取当前麦克风输入的电平
- (BOOL) isAudioQueueThread; //是否在Audio处理线程中
- (NSArray *) getMicrophones;

- (BOOL) isUseBuildinSpeaker;
- (BOOL) hasInputNotBuildIn;
- (BOOL) isBuiltInOutput;
- (BOOL) isForceOutputSpeaker; //是否需要强制将输出置为外放
- (AEAudioController *)getCurrentAudioController;
- (AEReverbFilter *)getReverbFilter;
- (AEDynamicsProcessorFilter *)getDynamicsProcessorFilter;
@end

