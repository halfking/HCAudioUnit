//
//  AEFileRender.m
//  maiba
//
//  Created by HUANGXUTAO on 16/3/2.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "AEFileRender.h"
#import "AEUtilities.h"
#import <libkern/OSAtomic.h>
#import <hccoren/base.h>

const Float64 kGraphSampleRate = 44100.0;
#define AECheckOSStatusA(result,operation) (_AECheckOSStatusA((result),(operation),strrchr(__FILE__, '/')+1,__LINE__))
static inline BOOL _AECheckOSStatusA(OSStatus result, const char *operation, const char* file, int line) {
    if ( result != noErr ) {
        if ( AERateLimit() ) {
            int fourCC = CFSwapInt32HostToBig(result);
            if ( isascii(((char*)&fourCC)[0]) && isascii(((char*)&fourCC)[1]) && isascii(((char*)&fourCC)[2]) ) {
                printf("%s:%d: %s: '%4.4s' (%d)", file, line, operation, (char*)&fourCC, (int)result);
            } else {
                printf("%s:%d: %s: %d", file, line, operation, (int)result);
            }
        }
        return NO;
    }
    return YES;
}
// render some silence
static void SilenceData(AudioBufferList *inData)
{
    for (UInt32 i=0; i < inData->mNumberBuffers; i++)
        memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
}

// audio render procedure to render our client data format
// 2 ch 'lpcm' 16-bit little-endian signed integer interleaved this is mClientFormat data, see CAStreamBasicDescription SetCanonical()
static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
    printf("load data from aefilerender:%u -- %u\n",inNumberFrames,userData->frameNum);

    
    AudioSampleType *in = userData->soundBuffer[inBusNumber].data;
    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[0].mData;
    
    UInt32 sample = userData->frameNum * userData->soundBuffer[inBusNumber].asbd.mChannelsPerFrame;
    
    // make sure we don't attempt to render more data than we have available in the source buffers
    // if one buffer is larger than the other, just render silence for that bus until we loop around again
    if ((userData->frameNum + inNumberFrames) > userData->soundBuffer[inBusNumber].numFrames) {
        UInt32 offset = (userData->frameNum + inNumberFrames) - userData->soundBuffer[inBusNumber].numFrames;
        if (offset < inNumberFrames) {
            // copy the last bit of source
            SilenceData(ioData);
            memcpy(out, &in[sample], ((inNumberFrames - offset) * userData->soundBuffer[inBusNumber].asbd.mBytesPerFrame));
            return noErr;
        } else {
            // we have no source data
            SilenceData(ioData);
            if(ioActionFlags)
            {
                *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
            }
            return noErr;
        }
    }
    
    memcpy(out, &in[sample], ioData->mBuffers[0].mDataByteSize);
    userData->frameNum += inNumberFrames;
    printf("render input bus %u sample %u\n", inBusNumber, sample);
    
    return noErr;
}

// the render notification is used to keep track of the frame number position in the source audio
static OSStatus renderNotification(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
    
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        
        //printf("post render notification frameNum %ld inNumberFrames %ld\n", userData->frameNum, inNumberFrames);
        
        userData->frameNum += inNumberFrames;
        if (userData->frameNum >= userData->maxNumFrames) {
            userData->frameNum = 0;
        }
    }
    
    return noErr;
}
@interface AEFileRender()
{
//    AudioFileID _audioFile;
//    AudioStreamBasicDescription _fileDescription;
//    AudioStreamBasicDescription _unitOutputDescription;
    UInt32 _lengthInFrames;
    NSTimeInterval _regionDuration;
    NSTimeInterval _regionStartTime;
//    volatile int32_t _playhead;
//    volatile int32_t _playbackStoppedCallbackScheduled;
    BOOL _running;
    uint64_t _startTime;
    AEAudioRenderCallback _superRenderCallback;
    NSMutableArray * sourceUrls_;
}
@property (nonatomic, strong, readwrite) NSURL * url;
@property (nonatomic, weak) AEAudioController * audioController;

@end
@implementation AEFileRender
@synthesize lengthInFrames = _lengthInFrames;

+ (instancetype)audioFilePlayerWithURL:(NSURL *)url error:(NSError **)error {
    return [[self alloc] initWithURL:url error:error];
}

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error {
    if ( !(self = [super initWithComponentDescription:AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple, kAudioUnitType_Generator, kAudioUnitSubType_AudioFilePlayer)]) ) return nil;
    
    mClientFormat.SetCanonical(2, true);
    mClientFormat.mSampleRate = kGraphSampleRate;
    
    if ( ![self loadAudioFileWithURL:url error:error] ) {
        return nil;
    }
    printf("------ get file format------\n");
    mClientFormat.Print();
    
    _superRenderCallback = [super renderCallback];
    
    return self;
}

- (void)dealloc {
//    if ( _audioFile ) {
//        AudioFileClose(_audioFile);
//    }
    if(self.audioController)
    {
        [self teardown];
    }
    PP_SUPERDEALLOC;
}
- (void)setupWithAudioController:(AEAudioController *)audioController {
    [super setupWithAudioController:audioController];
    
    self.audioController = audioController;
    
//    Float64 priorOutputSampleRate = mClientFormat.mSampleRate;
//    UInt32 size = sizeof(AudioStreamBasicDescription);
//    AECheckOSStatusA(AudioUnitGetProperty(self.audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &_unitOutputDescription, &size), "AudioUnitGetProperty(kAudioUnitProperty_StreamFormat)");
//    
//    double sampleRateScaleFactor = _unitOutputDescription.mSampleRate / (priorOutputSampleRate ? priorOutputSampleRate : mClientFormat.mSampleRate);
//    _playhead = _playhead * sampleRateScaleFactor;

    
//    // Set the file to play
//    size = sizeof(_audioFile);
//    OSStatus result = AudioUnitSetProperty(self.audioUnit, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &_audioFile, size);
//    AECheckOSStatusA(result, "AudioUnitSetProperty(kAudioUnitProperty_ScheduledFileIDs)");
    
    // Play the file region
//    if ( self.channelIsPlaying ) {
//        double outputToSourceSampleRateScale = _fileDescription.mSampleRate / _unitOutputDescription.mSampleRate;
//        [self schedulePlayRegionFromPosition:_playhead * outputToSourceSampleRateScale];
//        _running = YES;
//    }
    //联接Mixer
    UInt32 numbuses = 1;
    for (UInt32 i = 0; i < numbuses; ++i) {
        // setup render callback struct
        AURenderCallbackStruct rcbs;
        rcbs.inputProc = &renderInput;
        rcbs.inputProcRefCon = &mUserData;
        
        printf("set AUGraphSetNodeInputCallback\n");
        
        // set a callback for the specified node's specified input
        OSStatus result = AUGraphSetNodeInputCallback(audioController.audioGraph, audioController.mixerNode, i, &rcbs);
        if (result) { printf("AUGraphSetNodeInputCallback result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
        
        printf("set input bus %d, client kAudioUnitProperty_StreamFormat\n", (unsigned int)i);
        
        // set the input stream format, this is the format of the audio for mixer input
        result = AudioUnitSetProperty(audioController.mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mClientFormat, sizeof(mClientFormat));
        if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    }
    
}

- (void)teardown {
    self.audioController = nil;
    for(int i = 0;i<MAXBUFS;i++)
    {
        free(mUserData.soundBuffer[i].data);
        mUserData.soundBuffer[i].data = 0;
    }
    [super teardown];
}

static OSStatus renderCallback(__unsafe_unretained AEFileRender *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio) {
    
    return renderInput(&THIS->mUserData, 0, time, 0, frames, audio);
//    if ( !THIS->_running ) return noErr;
//    
//    uint64_t hostTimeAtBufferEnd = time->mHostTime + AEHostTicksFromSeconds((double)frames / THIS->_unitOutputDescription.mSampleRate);
//    if ( THIS->_startTime && THIS->_startTime > hostTimeAtBufferEnd ) {
//        // Start time not yet reached: emit silence
//        return noErr;
//    }
//    
//    uint32_t silentFrames = THIS->_startTime && THIS->_startTime > time->mHostTime
//    ? AESecondsFromHostTicks(THIS->_startTime - time->mHostTime) * THIS->_unitOutputDescription.mSampleRate : 0;
//    AEAudioBufferListCopyOnStack(scratchAudioBufferList, audio, silentFrames * THIS->_unitOutputDescription.mBytesPerFrame);
//    if ( silentFrames > 0 ) {
//        // Start time is offset into this buffer - silence beginning of buffer
//        for ( int i=0; i<audio->mNumberBuffers; i++) {
//            memset(audio->mBuffers[i].mData, 0, silentFrames * THIS->_unitOutputDescription.mBytesPerFrame);
//        }
//        
//        // Point buffer list to remaining frames
//        audio = scratchAudioBufferList;
//        frames -= silentFrames;
//    }
//    
//    THIS->_startTime = 0;
//    
//    // Render
//    THIS->_superRenderCallback(THIS, audioController, time, frames, audio);
////    if(frames>0)
////    {
////        for ( int i=0; i<audio->mNumberBuffers; i++) {
////            memset(audio->mBuffers[i].mData, 0, frames * THIS->_unitOutputDescription.mBytesPerFrame);
////        }
//////        memcpy(audio->mBuffers[i].mData, &in[sample], ioData->mBuffers[0].mDataByteSize);
//////        SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)THIS->mUserData;
//////        
//////        AudioSampleType *in = userData->soundBuffer[inBusNumber].data;
//////        AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[0].mData;
//////        
//////        UInt32 sample = userData->frameNum * userData->soundBuffer[inBusNumber].asbd.mChannelsPerFrame;
//////        
//////        // make sure we don't attempt to render more data than we have available in the source buffers
//////        // if one buffer is larger than the other, just render silence for that bus until we loop around again
//////        if ((userData->frameNum + inNumberFrames) > userData->soundBuffer[inBusNumber].numFrames) {
//////            UInt32 offset = (userData->frameNum + inNumberFrames) - userData->soundBuffer[inBusNumber].numFrames;
//////            if (offset < inNumberFrames) {
//////                // copy the last bit of source
//////                SilenceData(ioData);
//////                memcpy(out, &in[sample], ((inNumberFrames - offset) * userData->soundBuffer[inBusNumber].asbd.mBytesPerFrame));
//////                return noErr;
//////            } else {
//////                // we have no source data
//////                SilenceData(ioData);
//////                *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
//////                return noErr;
//////            }
//////        }
//////        
//////        memcpy(out, &in[sample], ioData->mBuffers[0].mDataByteSize);
////        
////        //printf("render input bus %ld from sample %ld\n", inBusNumber, sample);
////        
//////        return noErr;
////    }
//    
//    // Examine playhead
//    int32_t playhead = THIS->_playhead;
//    int32_t originalPlayhead = THIS->_playhead;
//    
//    UInt32 regionLengthInFrames = ceil(THIS->_regionDuration * THIS->_unitOutputDescription.mSampleRate);
//    UInt32 regionStartTimeInFrames = ceil(THIS->_regionStartTime * THIS->_unitOutputDescription.mSampleRate);
//    
//    //如果结束
//    if ( playhead - regionStartTimeInFrames + frames >= regionLengthInFrames ) {
//        // We just crossed the loop boundary; if not looping, end the track.
//        //没有完成的填写空白
//        UInt32 finalFrames = MIN(regionLengthInFrames - (playhead - regionStartTimeInFrames), frames);
//        for ( int i=0; i<audio->mNumberBuffers; i++) {
//            // Silence the rest of the buffer past the end
//            memset((char*)audio->mBuffers[i].mData + (THIS->_unitOutputDescription.mBytesPerFrame * finalFrames), 0, (THIS->_unitOutputDescription.mBytesPerFrame * (frames - finalFrames)));
//        }
//        
//        // Reset the unit, to cease playback
//        AECheckOSStatusA(AudioUnitReset(AEAudioUnitChannelGetAudioUnit(THIS), kAudioUnitScope_Global, 0), "AudioUnitReset");
//        playhead = 0;
//        
//        // Schedule the playback ended callback (if it hasn't been scheduled already)
//        if ( OSAtomicCompareAndSwap32(NO, YES, &THIS->_playbackStoppedCallbackScheduled) ) {
//            AEAudioControllerSendAsynchronousMessageToMainThread(THIS->_audioController, AEFileRenderNotifyCompletion, &THIS, sizeof(AEFileRender*));
//        }
//        
//        THIS->_running = NO;
//    }
//    
//    // Update the playhead
//    playhead = regionStartTimeInFrames + ((playhead - regionStartTimeInFrames + frames) % regionLengthInFrames);
//    OSAtomicCompareAndSwap32(originalPlayhead, playhead, &THIS->_playhead);
//    
//    return noErr;
}

-(AEAudioRenderCallback)renderCallback {
    return renderCallback;
}

static void AEFileRenderNotifyCompletion(void *userInfo, int userInfoLength) {
    AEFileRender *THIS = (__bridge AEFileRender*)*(void**)userInfo;
//    if ( !OSAtomicCompareAndSwap32(YES, NO, &THIS->_playbackStoppedCallbackScheduled) ) {
//        // We've been pre-empted by another scheduled callback: bail for now
//        return;
//    }
    
    if ( THIS.removeUponFinish ) {
        [THIS.audioController removeChannels:@[THIS]];
    }
    THIS.channelIsPlaying = NO;
    if ( THIS.completionBlock ) {
        THIS.completionBlock();
    }
}
- (void)setChannelIsPlaying:(BOOL)playing {
    BOOL wasPlaying = self.channelIsPlaying;
    [super setChannelIsPlaying:playing];
    
    if ( wasPlaying == playing ) return;
    
    _running = playing;
    if ( self.audioUnit ) {
//        if ( playing ) {
//            double outputToSourceSampleRateScale = _fileDescription.mSampleRate / _unitOutputDescription.mSampleRate;
//            [self schedulePlayRegionFromPosition:_playhead * outputToSourceSampleRateScale];
//        } else {
            AECheckOSStatusA(AudioUnitReset(self.audioUnit, kAudioUnitScope_Global, 0), "AudioUnitReset");
//        }
    }
}
- (BOOL)loadAudioFileWithURL:(NSURL*)url error:(NSError**)error {
    if(!sourceUrls_) sourceUrls_ =[NSMutableArray new];
    else [sourceUrls_ removeAllObjects];
    [sourceUrls_ addObject:[CommonUtil checkPath:[url absoluteString]]];
    [self loadFiles];
    
    _lengthInFrames = (UInt32)mUserData.maxNumFrames;
    _regionStartTime = 0;
    Float64 sampleRate = mUserData.soundBuffer[0].asbd.mSampleRate;
    if(sampleRate==0)
        sampleRate = self.audioDescription.mSampleRate;
    
    _regionDuration = (double)_lengthInFrames / sampleRate;
    self.url = url;
    
    return YES;
}
- (void)loadFiles
{
    mUserData.frameNum = 0;
    mUserData.maxNumFrames = 0;
    
    for (int i = 0; i < sourceUrls_.count && i < MAXBUFS; i++)  {
        printf("loadFiles, %d\n", i);
        
        ExtAudioFileRef xafref = 0;
        
        // open one of the two source files
        CFURLRef sourceUrl =  CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)sourceUrls_[i], kCFURLPOSIXPathStyle, false);
        
        OSStatus result = ExtAudioFileOpenURL(sourceUrl, &xafref);
        if (result || 0 == xafref) { printf("ExtAudioFileOpenURL result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            CFRelease(sourceUrl);
            return;
        }
        
        // get the file data format, this represents the file's actual data format
//        // for informational purposes only -- the client format set on ExtAudioFile is what we really want back
//        CAStreamBasicDescription fileFormat;
//        UInt32 propSize = sizeof(fileFormat);
//        
//        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
//        if (result) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileDataFormat result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
//        
//        printf("file %d, native file format\n", i);
//        fileFormat.Print();
        
        // set the client format to be what we want back
        // this is the same format audio we're giving to the the mixer input
        result = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, sizeof(mClientFormat), &mClientFormat);
        if (result) { printf("ExtAudioFileSetProperty kExtAudioFileProperty_ClientDataFormat %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            CFRelease(sourceUrl);
            return; }
        mClientFormat.Print();
        // get the file's length in sample frames
        UInt64 numFrames = 0;
        UInt32 propSize = sizeof(numFrames);
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
        if (result || numFrames == 0) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            CFRelease(sourceUrl);
            return; }
        
        // keep track of the largest number of source frames
        if (numFrames > mUserData.maxNumFrames) mUserData.maxNumFrames = (UInt32)numFrames;
        
        // set up our buffer
        mUserData.soundBuffer[i].numFrames = (UInt32)numFrames;
        mUserData.soundBuffer[i].asbd = mClientFormat;
        
        UInt32 samples = (UInt32)numFrames * mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        mUserData.soundBuffer[i].data = (AudioSampleType *)calloc(samples, sizeof(AudioSampleType));
        
        // set up a AudioBufferList to read data into
        AudioBufferList bufList;
        bufList.mNumberBuffers = 1;
        bufList.mBuffers[0].mNumberChannels = mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        bufList.mBuffers[0].mData = mUserData.soundBuffer[i].data;
        bufList.mBuffers[0].mDataByteSize = samples * sizeof(AudioSampleType);
        
        // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
        UInt32 numPackets = (UInt32)numFrames;
        result = ExtAudioFileRead(xafref, &numPackets, &bufList);
        if (result) {
            printf("ExtAudioFileRead result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            free(mUserData.soundBuffer[i].data);
            mUserData.soundBuffer[i].data = 0;
        }
        // close the file and dispose the ExtAudioFileRef
        ExtAudioFileDispose(xafref);
        
        CFRelease(sourceUrl);
    }
}
@end
