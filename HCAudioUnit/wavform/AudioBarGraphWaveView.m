//
//  AudioBarGraphWaveView.m
//  audioBarGraphWave
//
//  Created by lieyunye on 10/15/15.
//  Copyright © 2015 lieyunye. All rights reserved.
//

#import "AudioBarGraphWaveView.h"
#import <AVFoundation/AVFoundation.h>
#define LEFTMARGIN 4
#define absX(x) (x < 0 ? 0 - x : x)
#define minMaxX(x, mn, mx) (x <= mn ? mn : (x >= mx ? mx : x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude) / 32767.0))

@implementation AudioBarGraphWaveView
{
    UIImageView* waveImageView_;
    UIImageView * waveImageViewProgress_;
    
    UIView * normalView_;
    UIView * progressView_;
    
    CGFloat duration;
    
    //所有基础数据的缓存，可以动态添加
    NSMutableData * sampleBuffer_;
    long sampleCountInBuffer_;
    //第一个汇总片段数据的统计
    long sampleCountForSlider;
    double sampleSliderSumForLeftChannel;
    double sampleSliderSumForRightChannel;
    
    //多少个数据点汇总成一个数据片段
    NSInteger samplesPerPixel_;
    
}
- (NSInteger) getSamplesPerPixel
{
    return samplesPerPixel_;
}
- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        samplesPerPixel_ = 100;//(int)(100 * 375 /frame.size.width);
        
        //self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _progressColor = [UIColor yellowColor];
        _waveColor = [UIColor blueColor];
        int count = GraphCnt;
        count = (frame.size.width - LEFTMARGIN *2) / 2;
//        count *= (frame.size.width -20) / 400;
        _drawSpace = roundf((frame.size.width - LEFTMARGIN*2) / count + 0.5);
        //        _drawSpace = 2;
        duration = 0;
        normalView_ = [[UIView alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width - LEFTMARGIN *2, self.frame.size.height)];
        normalView_.clipsToBounds = YES;
        waveImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - LEFTMARGIN *2, self.frame.size.height)];
        waveImageView_.contentMode = UIViewContentModeLeft;
        [normalView_ addSubview:waveImageView_];
        [self addSubview:normalView_];
        
        progressView_ = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 0, self.frame.size.height)];
        waveImageViewProgress_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - LEFTMARGIN *2, self.frame.size.height)];
        waveImageViewProgress_.contentMode = UIViewContentModeLeft;
        [progressView_ addSubview:waveImageViewProgress_];
        progressView_.clipsToBounds = YES;
        
        [self addSubview:progressView_];
    }
    return self;
}
- (UIImage*)recolorizeImage:(UIImage*)image withColor:(UIColor*)color
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, imageRect, image.CGImage);
    [color set];
    UIRectFillUsingBlendMode(imageRect, kCGBlendModeSourceAtop);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (CGFloat) secondsForPoint:(CGPoint) point
{
    if(point.x>=LEFTMARGIN && point.x <= self.frame.size.width - LEFTMARGIN)
    {
        CGFloat seconds = (point.x - LEFTMARGIN)/(self.frame.size.width - LEFTMARGIN *2);
        seconds *= duration;
        return seconds;
    }
    else
    {
        return -1;
    }
}
- (void) timeChanged:(CGFloat)playingSeconds
{
    if(!self.hasProgress)
    {
        return;
    }
    if([NSThread isMainThread])
    {
        if(duration<=0) return;
        
        CGFloat leftMargin = playingSeconds>0?playingSeconds * (self.frame.size.width - LEFTMARGIN*2)/duration:0;
        normalView_.frame = CGRectMake(10+leftMargin, 0, self.frame.size.width - LEFTMARGIN *2 - leftMargin, self.frame.size.height);
        waveImageView_.frame = CGRectMake(-leftMargin, 0, self.frame.size.width - LEFTMARGIN *2, self.frame.size.height);
        progressView_.frame = CGRectMake(LEFTMARGIN, 0, leftMargin, self.frame.size.height);
        //        waveImageView_.frame = CGRectMake(-leftMargin, 0, self.frame.size.width - 20, self.frame.size.height);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self timeChanged:playingSeconds];
        });
    }
}
- (CGFloat)addSamplesWithOffset:(SInt16 *)samples count:(SInt16)count channelCount:(int)channelCount samplesPerPixel:(NSInteger)samplesPerPixel
{
    if(!sampleBuffer_)
    {
        sampleBuffer_ =[[NSMutableData alloc]init];
        sampleSliderSumForLeftChannel = 0;
        sampleSliderSumForRightChannel = 0;
        sampleCountForSlider = 0;
        sampleCountInBuffer_ =0;
    }
    if(samplesPerPixel<=1) samplesPerPixel = samplesPerPixel_;
    
    NSUInteger sampleCount = count;
    
    for (int i = 0; i < sampleCount; i++)
    {
        Float32 sample = (Float32) *samples++;
        if(sample>=0)
        {
            sample = noiseFloor;
        }
        else
        {
            sample = decibel(sample);
            sample = minMaxX(sample, noiseFloor, 0);
        }
        for (int j = 1; j<channelCount; j++) {
            samples ++;
        }
        if(!isnan(sample))
        {
            sampleSliderSumForLeftChannel += (sample);
        }
        sampleCountForSlider++;
        if (sampleCountForSlider > samplesPerPixel)
        {
            sample = (Float32)(sampleSliderSumForLeftChannel / sampleCountForSlider);
            
            [sampleBuffer_ appendBytes:&sample length:sizeof(sample)];
            sampleSliderSumForLeftChannel = 0;
            sampleSliderSumForRightChannel = 0;
            sampleCountForSlider = 0;
            sampleCountInBuffer_ ++;
        }
    }
    
    return 0;
}
- (void)resetBuffers
{
    sampleSliderSumForLeftChannel = 0;
    sampleSliderSumForRightChannel = 0;
    sampleCountForSlider = 0;
    sampleCountInBuffer_ =0;
    sampleBuffer_ = nil;
}
#pragma mark - render

- (void) render {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_soundURL options:nil];
    UIImage *renderedImage = [self renderWaveImageFromAudioAsset:asset];
    waveImageView_.image = renderedImage;
    
    waveImageViewProgress_.image = [self recolorizeImage:renderedImage withColor:[UIColor yellowColor]];
}

- (UIImage*) renderWaveImageFromAudioAsset:(AVURLAsset *)songAsset {
    
    NSError* error = nil;
    
    if(songAsset)
    {
        duration = CMTimeGetSeconds(songAsset.duration);
    }
    
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    AVAssetTrack* songTrack = [songAsset.tracks objectAtIndex:0];
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    
    UInt32 sampleRate, channelCount = 0;
    
    NSArray* formatDesc = songTrack.formatDescriptions;
    
    for (int i = 0; i < [formatDesc count]; ++i)
    {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if (fmtDesc)
        {
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    //    Float32 minValue = 0;
    //    Float32 maxValue = 0;
    
    //    NSMutableData *fullSongData = [[NSMutableData alloc] init];
    
    [reader startReading];
    
    UInt64 totalBytes = 0;
    //    double totalLeft = 0;
    //    SInt64 totalRight = 0;
    //    NSInteger sampleTally = 0;
    
    NSInteger samplesPerPixel = samplesPerPixel_;
    
    //    int buffersCount = 0;
    //    long sampleCountFull = 0;
    while (reader.status == AVAssetReaderStatusReading)
    {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef)
        {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            @autoreleasepool
            {
                NSMutableData *data = [NSMutableData dataWithLength:length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                
                SInt16 * samples = (SInt16*) data.mutableBytes;
                NSUInteger sampleCount = length / bytesPerSample;
                
                
                [self addSamplesWithOffset:samples count:sampleCount channelCount:channelCount samplesPerPixel:samplesPerPixel];
                
                CMSampleBufferInvalidate(sampleBufferRef);
                
                CFRelease(sampleBufferRef);
            }
        }
        
        //        buffersCount++;
    }
    
    if (reader.status == AVAssetReaderStatusCompleted)
    {
        
        long pointCount = (self.frame.size.width - LEFTMARGIN *2) / (_drawSpace) ;
        NSData * pointData = [self getPointsToDraw:(Float32 *)sampleBuffer_.bytes sampleCount:sampleCountInBuffer_ pointCount:&pointCount];
        Float32 * pointDataBytes = (Float32 *)pointData.bytes;
        
        
        UIImage *image = [self drawImageFromSamples:pointDataBytes
                                        sampleCount:pointCount
                                              color:self.waveColor
                                            leftPos:0];
        if(self.hasProgress)
        {
            waveImageViewProgress_.image = [self drawImageFromSamples:pointDataBytes
                                                          sampleCount:pointCount
                                                                color:self.progressColor
                                                              leftPos:0];
        }
        
        [self resetBuffers];
        
        return image;
    }
    else
    {
        [self resetBuffers];
    }
    return nil;
}
- (NSData *) getPointsToDraw:(Float32 *)samples sampleCount:(long)sampleCount pointCount:(long *)pointsCount
{
    long points = *pointsCount;
    int sampleCountPerPoint = 1;
    Float32 maxValue = 0;
    Float32 minValue = 100;
    
    if(sampleCount >points)
    {
        sampleCountPerPoint = roundf((Float32)sampleCount /points +0.5);
    }
    
    points = 0;
    
    double sumVal = 0;
    int sumCount = 0;
    NSMutableData *adjustedSongData = [[NSMutableData alloc] init];
    
    for (int i = 0; i<sampleCount; i ++) {
        sumVal += *samples ++;
        if(sumCount == sampleCountPerPoint)
        {
            Float32 sumVal2 = (Float32)ABS(sumVal / sumCount);
            
            if (sumVal2 < minValue)
            {
                minValue = sumVal2;
            }
            if (sumVal2 > maxValue)
            {
                maxValue = sumVal2;
            }
            [adjustedSongData appendBytes:&sumVal2 length:sizeof(sumVal2)];
            sumCount = 0;
            sumVal =0;
            points ++;
        }
        else
        {
            sumCount ++;
        }
    }
    if(sumCount>0)
    {
        Float32 sumVal2 = (Float32)ABS(sumVal / sumCount);
        
        if (sumVal2 < minValue)
        {
            minValue = sumVal2;
        }
        if (sumVal2 > maxValue)
        {
            maxValue = sumVal2;
        }
        [adjustedSongData appendBytes:&sumVal2 length:sizeof(sumVal2)];
        sumCount = 0;
        sumVal =0;
        points ++;
    }
    if(pointsCount)
    {
        *pointsCount = points;
    }
    NSMutableData *pointsData = [[NSMutableData alloc] initWithCapacity:points];
    samples = (Float32 *)adjustedSongData.bytes;
    //    maxValue -= minValue;
    for (long i = 0; i<points; i ++) {
        Float32 val = *samples ++;
        Float32 val2 = 1 - (val )/maxValue;
        [pointsData appendBytes:&val2 length:sizeof(val2)];
        NSLog(@" (%f - %f)/%f = %f  ",val,minValue,maxValue,val2);
    }
    return pointsData;
}
- (UIImage *)drawImageWithBuffer:(CGFloat)leftX
{
#warning 此处仍有BUG，需要统筹计算，一个像素需要多少个音频信息
    long pointCount = sampleCountInBuffer_;
    NSData * pointData = [self getPointsToDraw:(Float32 *)sampleBuffer_.bytes sampleCount:sampleCountInBuffer_ pointCount:&pointCount];
    Float32 * pointDataBytes = (Float32 *)pointData.bytes;
    
    
    UIImage *image = [self drawImageFromSamples:pointDataBytes
                                    sampleCount:pointCount
                                          color:self.waveColor
                                        leftPos:leftX];
    
    return image;
}
- (UIImage*) drawImageFromSamples:(Float32*)samples
                      sampleCount:(NSInteger)sampleCount
                            color:(UIColor *)color
                          leftPos:(CGFloat)posX
{
    
    CGSize imageSize = CGSizeMake(self.frame.size.width - LEFTMARGIN *2, self.frame.size.height - 2);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    float Y = imageSize.height;
    
    //    CGColorRef waveColor = color.CGColor;
    if(_drawSpace>=4)
        CGContextSetLineWidth(context, _drawSpace - 1);
    else
        CGContextSetLineWidth(context, _drawSpace - 0.5);
    
    CGFloat space = MAX(Y *0.1*0.05,0.5);
    for (int i = 0; i < sampleCount; i ++ ) {
        Float32 val = *samples ++ ;
        Float32 totalVal = val;
        
        if (totalVal <= 0 ) {
            totalVal = 0.1;
        }
        float X = posX + i * _drawSpace ;//+ _drawSpace / 2;
        Float32 promixatedVal = roundf(totalVal * 10)/10;
        
        //top
        if(totalVal - promixatedVal > 0.01)
        {
            CGFloat alpha = (1 - promixatedVal);
            if(alpha<=0) alpha = 0.1;
            CGFloat bottomPoint = Y * alpha;
            CGFloat topPoint = Y * (1 - totalVal);
            if(topPoint <0) topPoint = 0;
            
            CGColorRef  waveColor = [color colorWithAlphaComponent:alpha].CGColor;
            CGContextMoveToPoint(context, X, bottomPoint);
            CGContextAddLineToPoint(context, X, topPoint + space);
            
            CGContextSetStrokeColorWithColor(context, waveColor);
            CGContextStrokePath(context);
            promixatedVal -= 0.1;
        }
        
        //others
        while (promixatedVal >=0) {
            CGFloat alpha = (1 - promixatedVal);
            if(alpha<=0) alpha = 0.1;
            CGFloat bottomPoint = Y *alpha;
            CGFloat topPoint = Y * (0.9 - promixatedVal);
            if(topPoint <0) topPoint = 0;
            
            CGColorRef  waveColor = [color colorWithAlphaComponent:alpha].CGColor;
            CGContextMoveToPoint(context, X, bottomPoint);
            CGContextAddLineToPoint(context, X, topPoint + space);
            
            CGContextSetStrokeColorWithColor(context, waveColor);
            CGContextStrokePath(context);
            
            
            promixatedVal -= 0.1;
        }
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) setSoundURL:(NSURL*)soundURL {
    
    _soundURL = soundURL;
    
    [self render];
}

@end
