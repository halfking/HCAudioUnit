//
//  HCWaveView.m
//  HCAudioUnit
//
//  Created by HUANGXUTAO on 16/4/22.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "HCWaveView.h"

#define absX(x) (x < 0 ? 0 - x : x)
#define minMaxX(x, mn, mx) (x <= mn ? mn : (x >= mx ? mx : x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude) / 32767.0))

@implementation HCWaveView
@synthesize DurationSeconds;
@synthesize ProgressSeconds;

- (id)init
{
    if(self = [super init])
    {
        audioList_ = [NSMutableArray new];
        samplesPerPixel_ = 1;
        totalSamples_ = 1;
        totalPixels_ = 1;
    }
    return self;
}
- (void)setDurationSeconds:(CGFloat)DurationSecondsA
{
    DurationSeconds = DurationSecondsA;
    if(DurationSeconds>1)
    {
        [self setTotalSamplesWithDuration];
    }
}
- (void)setTotalSamplesWithDuration
{
    UInt64 orgTotalSamples = totalSamples_;
    UInt32 orgSamplePerPixel = samplesPerPixel_;
    totalSamples_ = DurationSeconds * 44100;//标准采样频率
    
    heightInPixels_ = self.frame.size.height * [DeviceConfig config].Scale;
    
    if(self.frame.size.width>0)
    {
        totalPixels_ = self.frame.size.width * [DeviceConfig config].Scale;
        samplesPerPixel_ = (UInt32)(totalSamples_ /totalPixels_);
    }
    if(orgSamplePerPixel !=samplesPerPixel_)
    {
        if(waveDataCreated_)
        {
            waveDataCreated_ = NO;
            [self parseAudioList];
        }
    }
    if(orgTotalSamples!=totalSamples_ || orgSamplePerPixel != samplesPerPixel_)
    {
        if(waveViewCreated_)
        {
            waveViewCreated_ = NO;
            [self drawWaveView];
        }
    }
    
}
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(frame.size.width>0)
    {
        [self setTotalSamplesWithDuration];
    }
}

#pragma mark - draw
- (void) drawWaveView
{
    if(waveViewCreated_) return;
    
    
    //没有显示完，则用空白填充
    //    // Rendering the last pixels
    //    bigSample = bigSampleCount > 0 ? bigSample / (double)bigSampleCount : noiseFloor;
    //    while (currentX < size.width) {
    //        SCRenderPixelWaveformInContext(context, halfGraphHeight, bigSample, currentX);
    //        currentX++;
    //    }
    waveViewCreated_ = YES;
}
#pragma mark - data manager
- (void)addAudioFile:(AudioItemN *)audioItem
{
    
}
- (void)addSampleInfo:(CMSampleBufferRef *)sample
{
    
}
#pragma mark - parse file
- (void) parseAudioList
{
    if(waveDataCreated_) return;
    waveDataCreated_ = YES;
    for (AudioItemN * item in audioList_) {
        [self parseSample:item];
    }
    
}
- (int) parseSample:(AudioItemN *)audioItem
{
    if(!audioItem || !audioItem.filePath || audioItem.filePath.length<2)
    {
        if(audioItem.samplesForPixel && audioItem.samplesForPixel.length>0)
        {
            return (int)audioItem.samplesForPixel.length;
        }
        return 0;
    }
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioItem.filePath]];
    if(!asset || asset.isReadable==NO) return 0;
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if(error)
    {
        NSLog(@"avasset reader error:%@",[error localizedDescription]);
        return 0;
    }
    
    NSArray *audioTrackArray = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    if (audioTrackArray.count == 0) {
        return 0;
    }
    
    AVAssetTrack *songTrack = [audioTrackArray objectAtIndex:0];
    
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                        [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                        nil];
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack
                                                                        outputSettings:outputSettingsDict];
    [reader addOutput:output];
    
    UInt32 channelCount = 0;
    NSArray *formatDesc = songTrack.formatDescriptions;
    for (unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        
        if (fmtDesc == nil) {
            return 0;
        }
        
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    
    //            unsigned long int totalSamples = (unsigned long int)asset.duration.value;
    
    [reader startReading];
    
    //            float halfGraphHeight = (heightInPixels_ / 2);
    double bigSample = 0;
    NSUInteger bigSampleCount = 0;
    NSMutableData * data = [NSMutableData dataWithLength:32768];
    
    size_t size = sizeof(double);
    double * avgSamples = malloc(totalPixels_ * size); //单个文件的所有像素点数，不会超过View宽度构成的点
    
    //            int multX = 3;
    int currentX = 0;
    
    while (reader.status == AVAssetReaderStatusReading) {
        
        CMSampleBufferRef sampleBufferRef = [output copyNextSampleBuffer];
        //                NSLog(@"get wave data...");
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            
            if (data.length < bufferLength) {
                [data setLength:bufferLength];
            }
            
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data.mutableBytes);
            
            SInt16 *samples = (SInt16 *)data.mutableBytes;
            int sampleCount = (int)(bufferLength / bytesPerInputSample);
            for (int i = 0; i < sampleCount; i++) {
                Float32 sample = (Float32) *samples++;
                sample = decibel(sample);
                sample = minMaxX(sample, noiseFloor, 0);
                
                //多通道处理
                for (int j = 1; j < channelCount; j++)
                    samples++;
                
                bigSample += sample;
                bigSampleCount++;
                
                //完成一个像素的数据
                if (bigSampleCount == samplesPerPixel_) {
                    double averageSample = bigSample / (double)bigSampleCount;
                    avgSamples[currentX] = averageSample;
                    //                            SCRenderPixelWaveformInContext(context, halfGraphHeight, averageSample, currentX);
                    currentX ++;
                    bigSample = 0;
                    bigSampleCount  = 0;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    if(currentX>0)
    {
        audioItem.samplesForPixel = [[NSData alloc]initWithBytes:avgSamples length:currentX];
    }
    else
    {
        audioItem.samplesForPixel = nil;
    }
    free(avgSamples);
    return currentX;
}
#pragma mark - dealloc

@end
