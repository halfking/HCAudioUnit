//
//  WTAudioRecorder.m
//  maiba
//
//  Created by WangSiyu on 15/9/26.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "WTAudioRecorder.h"
#import <hccoren/base.h>

@implementation WTAudioRecorder
{
    AVAudioRecorder *recorder_;
    NSString *recordFilePath_;
    NSURL *recordUrl_;
    NSString * recordPath_;
}
+(id)Instance
{
    static dispatch_once_t pred = 0;
    static WTAudioRecorder *intance_ = nil;
    dispatch_once(&pred,^
                  {
                      intance_ = [[WTAudioRecorder alloc] init];
                  });
    return intance_;
}

+(instancetype)shareObject
{
    return (WTAudioRecorder *)[self Instance];
}
- (void) setRecordPath:(NSString *)path
{
    PP_RELEASE(recordPath_);
    recordPath_ = PP_RETAIN(path);
}
- (void)generateRecordFilePath
{
    NSAssert(recordPath_ && recordPath_.length>0, @"请先设置录制的文件存放目录setRecordPath:");
    NSString * fileName = [NSString stringWithFormat:@"%ld.m4a",(long)[[NSDate date] timeIntervalSince1970]];
    
    recordFilePath_ = [recordPath_ stringByAppendingPathComponent:fileName];
}

- (NSURL *)getRecordUrl
{
    return recordUrl_;
}

- (BOOL)startRecord
{
    if(recorder_)
        return NO;
    [self generateRecordFilePath];
    NSLog(@"The record File Path is %@ --------------------------",recordFilePath_);
    if ([[NSFileManager defaultManager]fileExistsAtPath:recordFilePath_])
    {
        [[NSFileManager defaultManager]removeItemAtPath:recordPath_ error:nil];
    }
    recordUrl_ = [NSURL URLWithString:recordFilePath_];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                              nil];
    
    // Unique recording URL
    
    NSError *error = nil;
    recorder_ = [[AVAudioRecorder alloc] initWithURL:recordUrl_
                                            settings:settings
                                               error:&error];
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
    }
    recorder_.meteringEnabled = YES;
    recorder_.delegate = self;
    [recorder_ prepareToRecord];
    return [recorder_ record];;
}

- (BOOL)stopRecord
{
    if (!recorder_) {
        return NO;
    }
    [recorder_ stop];
    PP_RELEASE(recorder_);
    return YES;
}

- (NSString *)getRecordFilePath
{
    return recordFilePath_;
}

- (float)getCurrentSeconds
{
    if (!recorder_) {
        return 0;
    }
    return recorder_.currentTime;
}

- (BOOL)isRecording
{
    if (recorder_ && recorder_.recording) {
        return YES;
    }
    else{
        return NO;
    }
}

- (float)getCurrentPower
{
    [recorder_ updateMeters];
    
    CGFloat normalizedValue = pow (10, [recorder_ averagePowerForChannel:0] / 30);
    CGFloat level = normalizedValue + 0.05f;
    if (level > 1) {
        level = 1;
    }
    return level;
}

- (void)updateMeters
{
    [recorder_ updateMeters];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self.delegate WTAudioRecorderDidFinishRecording:self successfully:flag];
}

@end
