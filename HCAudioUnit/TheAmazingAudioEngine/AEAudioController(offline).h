//
//  AEAudioController(offline).h
//  maiba
//
//  Created by HUANGXUTAO on 16/3/1.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioController.h"

//#include "CAStreamBasicDescription.h"

//#define MAXBUFS  2
////#define NUMFILES 1
//
//typedef struct {
//    AudioStreamBasicDescription asbd;
//    AudioSampleType *data;
//    UInt32 numFrames;
//} SoundBuffer, *SoundBufferPtr;
//
//typedef struct {
//    UInt32 frameNum;
//    UInt32 maxNumFrames;
//    SoundBuffer soundBuffer[MAXBUFS];
//} SourceAudioBufferData, *SourceAudioBufferDataPtr;


@interface AEAudioController(offline)
//- (BOOL)startWithFiles:(NSArray *)filePaths targetFile:(NSString *)targetPath options:(NSArray *)filters;
//- (void)initAuGraphForOffline:(SourceAudioBufferData)mUserData;
- (BOOL)renderOffline:(NSString *)filePath targetFile:(NSString *)targetPath;
- (BOOL)renderOffline:(NSArray *)channels duration:(NSTimeInterval)duration targetFile:(NSString *)targetPath;
@end
