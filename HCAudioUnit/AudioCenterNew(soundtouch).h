//
//  AudioCenterNew(soundtouch).h
//  maiba
//
//  Created by HUANGXUTAO on 16/2/24.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCenterNew.h"
#import "Audiodefine.h"
//#import "AudioConvert.h"
//#import "SeenVideoQueue.h"

@interface AudioCenterNew(soundtouch)
#pragma mark - 变调
// int        tempo;   //速度 <变速不变调> 范围 -50 ~ 100
//int        pitch;         //音调  范围 -12 ~ 12
//int        rate;          //声音速率 范围 -50 ~ 100
- (void)createFileBySoundTouch:(NSString *)sourcePath
                    targetPath:(NSString *)targetPath
                         pitch:(int)pitch
                         tempo:(int)tempo
                          rate:(int)rate
                     completed:(ConvertCompleted) completed;
- (void)createFileBySoundTouch:(NSString *)sourcePath
                    targetPath:(NSString *)targetPath
                        config:(AudioConvertConfig)dconfig
                     completed:(ConvertCompleted) completed;


#pragma mark - play audio
////音频播放器相关
//- (NSNumber *)initializeAudioPlayerWithURL:(NSURL *)URL;
//- (void)playItemID:(NSNumber *)itemID;
//- (void)pauseForItemID:(NSNumber *)itemID;
//- (void)removePlayerForItemID:(NSNumber *)itemID;
//- (void)seekToSeconds:(float)seconds forItemID:(NSNumber *)itemID;
//- (BOOL)isPlyerPlaying:(AEAudioFilePlayer *)player;


@end
