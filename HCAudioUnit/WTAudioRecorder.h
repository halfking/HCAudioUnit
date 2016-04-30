//
//  WTAudioRecorder.h
//  maiba
//
//  Created by WangSiyu on 15/9/26.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class WTAudioRecorder;

@protocol WTAudioRecorderDelegate <NSObject>

@optional

- (void)WTAudioRecorderDidFinishRecording:(WTAudioRecorder *)recorder successfully:(BOOL)flag;

@end

@interface WTAudioRecorder : NSObject<AVAudioRecorderDelegate>

+(instancetype)shareObject;

- (void)    setRecordPath:(NSString *)path;
- (BOOL)    startRecord;
- (BOOL)    stopRecord;

- (NSString *)  getRecordFilePath;
- (NSString *)  getRecordUrl;
- (float)       getCurrentPower;

- (void)        updateMeters;

- (float)       getCurrentSeconds;

- (BOOL)        isRecording;

@property (nonatomic, strong) id<WTAudioRecorderDelegate>delegate;

@end
