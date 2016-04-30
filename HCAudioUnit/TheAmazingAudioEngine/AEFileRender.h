//
//  AEFileRender.h
//  maiba
//
//  Created by HUANGXUTAO on 16/3/2.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
extern "C" {
#endif
#import "CAStreamBasicDescription.h"
//#import "CAComponentDescription.h"
//#import "AUGraphController.h"
#import "AEAudioUnitChannel.h"
    
#define MAXBUFS  2
#define NUMFILES 1
    typedef struct {
        AudioStreamBasicDescription asbd;
        AudioSampleType *data;
        UInt32 numFrames;
    } SoundBuffer, *SoundBufferPtr;
    
    typedef struct {
        UInt32 frameNum;
        UInt32 maxNumFrames;
        SoundBuffer soundBuffer[MAXBUFS];
    } SourceAudioBufferData, *SourceAudioBufferDataPtr;
    
@interface AEFileRender : AEAudioUnitChannel
{
    CAStreamBasicDescription mClientFormat;
    
    SourceAudioBufferData mUserData;
}

/*!
 * Create a new player instance
 *
 * @param url               URL to the file to load
 * @param error             If not NULL, the error on output
 * @return The audio player, ready to be @link AEAudioController::addChannels: added @endlink to the audio controller.
 */
+ (instancetype)audioFilePlayerWithURL:(NSURL *)url error:(NSError **)error;
- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error ;

@property (nonatomic, readwrite) BOOL removeUponFinish;        //!< Whether the track automatically removes itself from the audio controller after playback completes
@property (nonatomic, readonly) NSTimeInterval duration;       //!< Length of audio file, in seconds
@property (nonatomic, readonly) UInt32  lengthInFrames;
@property (nonatomic, copy) void(^completionBlock)();          //!< A block to be called when playback finishes
@end
#ifdef __cplusplus
}
#endif