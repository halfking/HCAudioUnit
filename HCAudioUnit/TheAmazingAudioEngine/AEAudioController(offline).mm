//
//  AEAudioController(offline).m
//  maiba
//
//  Created by HUANGXUTAO on 16/3/1.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "AEAudioController(offline).h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <hccoren/base.h>
#include "CAStreamBasicDescription.h"
#include "CAComponentDescription.h"
//#import "AUGraphController.h"

#import "AEAudioFileLoaderOperation.h"
#import "AEAudioFileWriter.h"
#import "AEUtilities.h"
#import "AEAudioFilePlayer.h"
#import "AEFileRender.h"
#import "AENewTimePitchFilter.h"
#import "AEDelayFilter.h"


//const Float64 kGraphSampleRate = 44100.0;

#pragma mark- Render
////为了将现有文件进行转换
//CAStreamBasicDescription mClientFormat;
//CAStreamBasicDescription mOutputFormat;
//
////    CFArrayRef mEQPresetsArray;
//
//SourceAudioBufferData mUserData;

// render some silence
//static void SilenceData(AudioBufferList *inData)
//{
//    for (UInt32 i=0; i < inData->mNumberBuffers; i++)
//        memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
//}
//
//// audio render procedure to render our client data format
//// 2 ch 'lpcm' 16-bit little-endian signed integer interleaved this is mClientFormat data, see CAStreamBasicDescription SetCanonical()
//static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
//{
//    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
//    
//    AudioSampleType *in = userData->soundBuffer[inBusNumber].data;
//    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[0].mData;
//    
//    UInt32 sample = userData->frameNum * userData->soundBuffer[inBusNumber].asbd.mChannelsPerFrame;
//    
//    //    // make sure we don't attempt to render more data than we have available in the source buffers
//    //    // if one buffer is larger than the other, just render silence for that bus until we loop around again
//    //    if ((userData->frameNum + inNumberFrames) > userData->soundBuffer[inBusNumber].numFrames) {
//    //        UInt32 offset = (userData->frameNum + inNumberFrames) - userData->soundBuffer[inBusNumber].numFrames;
//    //        if (offset < inNumberFrames) {
//    //            // copy the last bit of source
//    //            SilenceData(ioData);
//    //            memcpy(out, &in[sample], ((inNumberFrames - offset) * userData->soundBuffer[inBusNumber].asbd.mBytesPerFrame));
//    //            return noErr;
//    //        } else {
//    //            // we have no source data
//    //            SilenceData(ioData);
//    //            *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
//    //            return noErr;
//    //        }
//    //    }
//    
//    memcpy(out, &in[sample], ioData->mBuffers[0].mDataByteSize);
//    
//    //printf("render input bus %ld from sample %ld\n", inBusNumber, sample);
//    
//    return noErr;
//}
//
//// the render notification is used to keep track of the frame number position in the source audio
//static OSStatus renderNotification(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
//{
//    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
//    
//    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
//        
//        //printf("post render notification frameNum %ld inNumberFrames %ld\n", userData->frameNum, inNumberFrames);
//        
//        userData->frameNum += inNumberFrames;
//        if (userData->frameNum >= userData->maxNumFrames) {
//            userData->frameNum = 0;
//        }
//    }
//    
//    return noErr;
//}


@implementation AEAudioController(offline)
//- (BOOL)startWithFiles:(NSArray *)filePaths targetFile:(NSString *)targetPath options:(NSArray *)filters
//{
////    AUGraph mGraph;
////    AUGraphController * ac = [[AUGraphController alloc]init];
////    [ac loadFilesForAuGraph:filePaths AuGraph:mGraph];
//    
//    return YES;
//}
- (BOOL)renderOffline:(NSArray *)channels duration:(NSTimeInterval)duration targetFile:(NSString *)targetPath
{
    const int kBufferLength = 4096;
    
    Boolean outIsOpen = NO;
    NSError * error = nil;
    
    [self start:nil];
    
    AUGraphStop(self.audioGraph);
    
    AUGraphIsOpen(self.audioGraph, &outIsOpen);
    
    printf("AUGraph is open:%d\n",outIsOpen);
    
    [self addChannels:channels];
    
    NSTimeInterval renderDuration = duration;
    Float64 sampleRate = self.audioDescription.mSampleRate;
    UInt32 lengthInFrames = (UInt32) (renderDuration * sampleRate);

    AudioTimeStamp timeStamp;
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mSampleTime = 0;
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    
    AEAudioFileWriter *audioFileWriter = [[AEAudioFileWriter alloc] initWithAudioDescription:self.audioDescription];
    
    AudioBufferList *buf = AEAllocateAndInitAudioBufferList(self.audioDescription, kBufferLength);
    
    //printf("begin to write file:%s",targetPath);
    
    error = nil;
    [audioFileWriter beginWritingToFileAtPath:targetPath fileType:kAudioFileM4AType error:&error];
    if(error)
    {
//        char * test = [error localizedDescription].UTF8String;
        printf("file writer error:%s",[error localizedDescription].UTF8String);
//        NSLog(@"file writer error:%@",[error localizedDescription]);
    }
    for (UInt64 i = 0; i < lengthInFrames; i += kBufferLength) {
//        printf("**begin render:%f \n",timeStamp.mSampleTime);
        AEAudioControllerRenderMainOutput(self, timeStamp, kBufferLength, buf);
        
        int temp = buf->mBuffers[0].mDataByteSize / self.audioDescription.mBytesPerFrame;
        if(temp==0)
        {
            printf("buffer length 0,break\n");
            break;
        }
        timeStamp.mSampleTime += kBufferLength;
        
//        printf("**begin write %llu  length:%d in %u...\n",i,kBufferLength,(unsigned int)lengthInFrames);
        OSStatus status = AEAudioFileWriterAddAudioSynchronously(audioFileWriter, buf, kBufferLength);
        //        OSStatus status = AEAudioFileWriterAddAudio(audioFileWriter, buf, kBufferLength);
        if (status != noErr) {
            printf("ERROR\n");
        }
        else
            printf("ok \n");
    }
    [audioFileWriter finishWriting];
    AEFreeAudioBufferList(buf);
    
    PP_RELEASE(audioFileWriter);
    
    AUGraphStart(self.audioGraph);
    
    [self removeChannels:channels];
    
    [self stop];
    
    printf("Finished\n");
    return YES;
}
- (BOOL)renderOffline:(NSString *)sourcePath targetFile:(NSString *)targetPath
{
    const int kBufferLength = 4096;
    NSURL * sourceUrl = [NSURL fileURLWithPath:sourcePath];
    
    Boolean outIsOpen = NO;
    NSError * error = nil;

    [self start:nil];
    
    AUGraphStop(self.audioGraph);
    
    AUGraphIsOpen(self.audioGraph, &outIsOpen);
    
    printf("AUGraph is open:%d\n",outIsOpen);
    
    AEAudioFilePlayer *aePlayer = [[AEAudioFilePlayer alloc] initWithURL:sourceUrl error:&error];
    if(error)
    {
        printf("load player failure");
    }
    
    [self addChannels:@[aePlayer]];
    NSTimeInterval renderDuration = aePlayer.duration;
    Float64 sampleRate = self.audioDescription.mSampleRate;
    UInt32 lengthInFrames = (UInt32) (renderDuration * sampleRate);
    
    AudioTimeStamp timeStamp;
    memset (&timeStamp, 0, sizeof(timeStamp));
    timeStamp.mSampleTime = 0;
    timeStamp.mFlags = kAudioTimeStampSampleTimeValid;

    AEAudioFileWriter *audioFileWriter = [[AEAudioFileWriter alloc] initWithAudioDescription:self.audioDescription];
    
    AudioBufferList *buf = AEAllocateAndInitAudioBufferList(self.audioDescription, kBufferLength);
    
    error = nil;
    [audioFileWriter beginWritingToFileAtPath:targetPath fileType:kAudioFileM4AType error:&error];
    if(error)
    {
        
    }
    for (UInt64 i = 0; i < lengthInFrames; i += kBufferLength) {
        printf("**begin render:%f \n",timeStamp.mSampleTime);
        AEAudioControllerRenderMainOutput(self, timeStamp, kBufferLength, buf);
        
        int temp = buf->mBuffers[0].mDataByteSize / self.audioDescription.mBytesPerFrame;
        if(temp==0)
        {
            printf("buffer length 0,break");
            break;
        }
        timeStamp.mSampleTime += kBufferLength;
        
        printf("**begin write %llu  length:%d in %u...",i,kBufferLength,(unsigned int)lengthInFrames);
        OSStatus status = AEAudioFileWriterAddAudioSynchronously(audioFileWriter, buf, kBufferLength);
//        OSStatus status = AEAudioFileWriterAddAudio(audioFileWriter, buf, kBufferLength);
        if (status != noErr) {
            printf("ERROR\n");
        }
        else
            printf("ok \n");
    }
    [audioFileWriter finishWriting];
    AEFreeAudioBufferList(buf);
    PP_RELEASE(audioFileWriter);
    
    [self removeChannels:@[aePlayer]];
    [aePlayer teardown];
    PP_RELEASE(aePlayer);
    
    AUGraphStart(self.audioGraph);
    [self stop];
    
    printf("Finished\n");
    return YES;
}

-(SourceAudioBufferData)loadFile:(NSArray *)filePaths clientForamt:(CAStreamBasicDescription*)mClientFormat
{
    SourceAudioBufferData mUserData;
    
    // clear the mSoundBuffer struct
    memset(&mUserData.soundBuffer, 0, sizeof(mUserData.soundBuffer));
    
    mUserData.frameNum = 0;
    mUserData.maxNumFrames = 0;
    //    printf(@"begin load file:%s",[filePath lastPathComponent]);
    for(int i = 0;i<filePaths.count;i++)
    {
        ExtAudioFileRef xafref = 0;
        CFURLRef sourceURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePaths[i], kCFURLPOSIXPathStyle, false);
        
        // open one of the two source files
        OSStatus result = ExtAudioFileOpenURL(sourceURL, &xafref);
        if (result || 0 == xafref) {
            //            NSLog(@"ExtAudioFileOpenURL result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result);
            CFRelease(sourceURL);
            return mUserData;
        }
        
        // get the file data format, this represents the file's actual data format
        // for informational purposes only -- the client format set on ExtAudioFile is what we really want back
        CAStreamBasicDescription  fileFormat;
        UInt32 propSize = sizeof(fileFormat);
        
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
        if (result) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileDataFormat result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            CFRelease(sourceURL);
            return mUserData;
        }
        //
        //        printf("file %d, native file format\n", i);
        fileFormat.Print();
        
        (*mClientFormat).Print();
        
        // set the client format to be what we want back
        // this is the same format audio we're giving to the the mixer input
        result = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, sizeof(*mClientFormat), mClientFormat);
        if (result) { printf("ExtAudioFileSetProperty kExtAudioFileProperty_ClientDataFormat %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            CFRelease(sourceURL);
            return mUserData; }
        
        // get the file's length in sample frames
        UInt64 numFrames = 0;
        propSize = sizeof(numFrames);
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
        if (result || numFrames == 0) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return mUserData; }
        
        // keep track of the largest number of source frames
        if (numFrames > mUserData.maxNumFrames) mUserData.maxNumFrames = (UInt32)numFrames;
        
        // set up our buffer
        mUserData.soundBuffer[i].numFrames = (UInt32)numFrames;
        mUserData.soundBuffer[i].asbd = *mClientFormat;
        
        UInt32 samples = (UInt32)(numFrames * mUserData.soundBuffer[i].asbd.mChannelsPerFrame);
        mUserData.soundBuffer[i].data = (AudioSampleType *)calloc(samples, sizeof(AudioSampleType));
        
        // set up a AudioBufferList to read data into
        AudioBufferList bufList;
        bufList.mNumberBuffers = 1;
        bufList.mBuffers[0].mNumberChannels = mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        bufList.mBuffers[0].mData = mUserData.soundBuffer[i].data;
        bufList.mBuffers[0].mDataByteSize = (UInt32)(samples * sizeof(AudioSampleType));
        
        // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
        UInt32 numPackets = (UInt32)numFrames;
        result = ExtAudioFileRead(xafref, &numPackets, &bufList);
        if (result) {
            printf("ExtAudioFileRead result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result);
            free(mUserData.soundBuffer[i].data);
            mUserData.soundBuffer[i].data = 0;
            CFRelease(sourceURL);
            return mUserData;
        }
        
        // close the file and dispose the ExtAudioFileRef
        ExtAudioFileDispose(xafref);
        CFRelease(sourceURL);
    }
    return mUserData;
}
@end
