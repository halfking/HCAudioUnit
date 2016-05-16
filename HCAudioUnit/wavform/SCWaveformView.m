//
//  SCWaveformView.m
//  SCWaveformView
//
//  Created by Simon CORSIN on 24/01/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import "SCWaveformView.h"
#import "EZAudio.h"

#define absX(x) (x < 0 ? 0 - x : x)
#define minMaxX(x, mn, mx) (x <= mn ? mn : (x >= mx ? mx : x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude) / 32767.0))

@interface SCWaveformView() {
    UIImageView *_normalImageView;
    UIImageView *_progressImageView;
    UIView *_cropNormalView;
    UIView *_cropProgressView;
    BOOL _normalColorDirty;
    BOOL _progressColorDirty;
    
    CGFloat hightLightLeft_;
    CGFloat hightLightRight_;
    
    //for hightligh mode sadfkajsd
    UIView * _cropProgressViewRight;
    UIImageView * _progressImageView2;
    BOOL _progressColorRightDirty;
    
    BOOL _drawSpaces;
}
@end

@implementation SCWaveformView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}
- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    _normalImageView = [[UIImageView alloc] init];
    _progressImageView = [[UIImageView alloc] init];
    _cropNormalView = [[UIView alloc] init];
    _cropProgressView = [[UIView alloc] init];
    
    _cropNormalView.clipsToBounds = YES;
    _cropProgressView.clipsToBounds = YES;
    
    [_cropNormalView addSubview:_normalImageView];
    [_cropProgressView addSubview:_progressImageView];
    
    [self addSubview:_cropNormalView];
    [self addSubview:_cropProgressView];
    
    self.normalColor = [UIColor blueColor];
    self.progressColor = [UIColor redColor];
    
    _normalColorDirty = NO;
    _progressColorDirty = NO;
    _progressColorRightDirty = NO;
}

void SCRenderPixelWaveformInContext(CGContextRef context, float halfGraphHeight, double sample, float x)
{
    float pixelHeight = halfGraphHeight * (1 - sample / noiseFloor);
    
    if (pixelHeight < 0) {
        pixelHeight = 0;
    }
    
    CGContextMoveToPoint(context, x, halfGraphHeight - pixelHeight);
    CGContextAddLineToPoint(context, x, halfGraphHeight + pixelHeight);
    CGContextStrokePath(context);
    
}

+ (void)renderWaveformInContext:(CGContextRef)context asset:(AVAsset *)asset withColor:(UIColor *)color andSize:(CGSize)size antialiasingEnabled:(BOOL)antialiasingEnabled
{
    if (asset == nil) {
        return;
    }
    
//    int maxPoints = (int)size.width;//最多显示点数
    
    CGFloat pixelRatio = [UIScreen mainScreen].scale;
    size.width *= pixelRatio;
    size.height *= pixelRatio;
    
    CGFloat widthInPixels = size.width;
    CGFloat heightInPixels = size.height;
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if(error)
    {
        NSLog(@"avasset reader error:%@",[error localizedDescription]);
    }
    else
    {
        {
            NSArray *audioTrackArray = [asset tracksWithMediaType:AVMediaTypeAudio];
            
            if (audioTrackArray.count == 0) {
                return;
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
                    return;
                }
                
                channelCount = fmtDesc->mChannelsPerFrame;
            }
            
            CGContextSetAllowsAntialiasing(context, antialiasingEnabled);
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, color.CGColor);
            CGContextSetFillColorWithColor(context, color.CGColor);
            
            UInt32 bytesPerInputSample = 2 * channelCount;
            
            unsigned long int totalSamples = (unsigned long int)asset.duration.value;
            NSUInteger samplesPerPixel = totalSamples / (widthInPixels);
            samplesPerPixel = samplesPerPixel < 1 ? 1 : samplesPerPixel;
            
            
            
            [reader startReading];
            
            float halfGraphHeight = (heightInPixels / 2);
            double bigSample = 0;
            NSUInteger bigSampleCount = 0;
            NSMutableData * data = [NSMutableData dataWithLength:32768];
            
//            int multX = 3;
            CGFloat currentX = 0;
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
                        if (bigSampleCount == samplesPerPixel) {
                            double averageSample = bigSample / (double)bigSampleCount;
                            
                            SCRenderPixelWaveformInContext(context, halfGraphHeight, averageSample, currentX);
                            
                            currentX ++;
                            bigSample = 0;
                            bigSampleCount  = 0;
                        }
                    }
                    CMSampleBufferInvalidate(sampleBufferRef);
                    CFRelease(sampleBufferRef);
                }
            }
            
            
            // Rendering the last pixels
            bigSample = bigSampleCount > 0 ? bigSample / (double)bigSampleCount : noiseFloor;
            while (currentX <= size.width) {
                SCRenderPixelWaveformInContext(context, halfGraphHeight, bigSample, currentX);
                currentX++;
            }
        }
    }
}
+ (UIImage*)generateWaveformImage:(AVAsset *)asset withColor:(UIColor *)color andSize:(CGSize)size antialiasingEnabled:(BOOL)antialiasingEnabled
{
    CGFloat ratio = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width * ratio, size.height * ratio), NO, 1);
    
    [SCWaveformView renderWaveformInContext:UIGraphicsGetCurrentContext()
                                      asset:asset
                                  withColor:color
                                    andSize:size
                        antialiasingEnabled:antialiasingEnabled];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
//    UIImage * image = [SCWaveformView renderWaveImageFromAudioAsset:asset context:UIGraphicsGetCurrentContext()
//                                                          withColor:color
//                                                            andSize:size];
    
    return image;
}

+ (UIImage*) drawImageFromSamples:(SInt16*)samples
                         maxValue:(SInt16)maxValue
                      sampleCount:(NSInteger)sampleCount
                        withColor:(UIColor *)color andSize:(CGSize)size
drawSpaces:(BOOL)drawSpaces
                          context:(CGContextRef)context
{
    
    CGSize imageSize = CGSizeMake(sampleCount * (drawSpaces ? 2 : 0), size.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    if(!context)
        context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetAlpha(context, 1.0);
    
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef waveColor = color.CGColor;
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float channelCenterY = imageSize.height / 2;
    float sampleAdjustmentFactor = imageSize.height / (float)maxValue;
    
    for (NSInteger i = 0; i < sampleCount; i++)
    {
        float val = *samples++;
        val = val * sampleAdjustmentFactor;
        if ((int)val == 0)
            val = 1.0; // draw dots instead emptyness
        CGContextMoveToPoint(context, i * (drawSpaces ? 2 : 1), channelCenterY - val / 2.0);
        CGContextAddLineToPoint(context, i * (drawSpaces ? 2 : 1), channelCenterY + val / 2.0);
        CGContextSetStrokeColorWithColor(context, waveColor);
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage*)generateWaveformImageWithFile:(NSURL*)url withColor:(UIColor*)color andSize:(CGSize)size antialiasingEnabled:(BOOL)antialiasingEnabled
{
    if(!url) return nil;
    uint maxPoints =(uint)( size.width * [UIScreen mainScreen].scale);
    
    EZAudioFile * afile = [EZAudioFile audioFileWithURL:url];
    EZAudioFloatData * data = [afile getWaveformDataWithNumberOfPoints:maxPoints];
    if(data.numberOfChannels >0)
    {
        CGFloat ratio = [UIScreen mainScreen].scale;

        size.width *= ratio;
        size.height *=ratio;
        UIGraphicsBeginImageContextWithOptions(size, NO, 1);
        
        UIImage *image = [self drawImageFromSamplesNew:data
                                          withColor:color andSize:size
                                         drawSpaces:0
                                            context:UIGraphicsGetCurrentContext()];
        UIGraphicsEndImageContext();
        return image;
    }
    return nil;
}

+ (UIImage*) drawImageFromSamplesNew:(EZAudioFloatData*)data
                        withColor:(UIColor *)color andSize:(CGSize)size
                       drawSpaces:(BOOL)drawSpaces
                          context:(CGContextRef)context
{
    
            int i = 0;
            float maxValue=0.0;
//            float * sample = data.buffers[0];
        int adjustFactor = ceilf((float)data.bufferSize / (size.width / (drawSpaces ? 2.0 : 1.0)));
//    int adjustFactor = data.numberOfChannels;
            while (i < data.bufferSize)
            {
                float val = 0;
    
                for (int j = 0; j < adjustFactor; j++)
                {
                    val += data.buffers[0][i+j];
                }
                val /= adjustFactor;
                if (ABS(val) > maxValue)
                {
                    maxValue = ABS(val);
                }
                i += adjustFactor;
            }
    
    CGSize imageSize = CGSizeMake(data.bufferSize * (drawSpaces ? 2 : 0), size.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    if(!context)
        context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetAlpha(context, 1.0);
    
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef waveColor = color.CGColor;
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float channelCenterY = imageSize.height / 2;
    float sampleAdjustmentFactor = imageSize.height / (float)maxValue;
    
    for (NSInteger i = 0; i < data.bufferSize; i++)
    {
        float val = data.buffers[0][i];
        val = val * sampleAdjustmentFactor;
        if ((int)val == 0)
            val = 1.0; // draw dots instead emptyness
        CGContextMoveToPoint(context, i * (drawSpaces ? 2 : 1), channelCenterY - val / 2.0);
        CGContextAddLineToPoint(context, i * (drawSpaces ? 2 : 1), channelCenterY + val / 2.0);
        CGContextSetStrokeColorWithColor(context, waveColor);
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage*) renderWaveImageFromAudioAsset:(AVAsset *)songAsset context:(CGContextRef)context withColor:(UIColor *)color andSize:(CGSize)size {
    
    NSError* error = nil;
    
    BOOL drawSpaces = NO;
    
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
    
    UInt32 sampleRate, channelCount = 1;
    
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
    SInt16 maxValue = 0;
    
    NSMutableData *fullSongData = [[NSMutableData alloc] init];
    
    [reader startReading];
    
    UInt64 totalBytes = 0;
    SInt64 totalLeft = 0;
    SInt64 totalRight = 0;
    NSInteger sampleTally = 0;
    
    NSInteger samplesPerPixel = 100; // pretty enougth for most of ui and fast
    
    int buffersCount = 0;
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
                int sampleCount = (int)(length / bytesPerSample);
                
                for (int i = 0; i < sampleCount; i++)
                {
                    SInt16 left = *samples++;
                    
                    totalLeft += left;
                    
                    SInt16 right =0;
                    
                    if (channelCount == 2)
                    {
                        right = *samples++;
                        
                        totalRight += right;
                    }
                    
                    sampleTally++;
                    
                    if (sampleTally > samplesPerPixel)
                    {
                        left = (totalLeft / sampleTally);
                        
                        if (channelCount == 2)
                        {
                            right = (totalRight / sampleTally);
                        }
                        
                        SInt16 val = right ? ((right + left) / 2) : left;
                        
                        [fullSongData appendBytes:&val length:sizeof(val)];
                        
                        totalLeft = 0;
                        totalRight = 0;
                        sampleTally = 0;
                    }
                }
                CMSampleBufferInvalidate(sampleBufferRef);
                
                CFRelease(sampleBufferRef);
            }
        }
        
        buffersCount++;
    }
    
    NSMutableData *adjustedSongData = [[NSMutableData alloc] init];
    
    unsigned long sampleCount = fullSongData.length / 2; // sizeof(SInt16)
    
    int adjustFactor = ceilf((float)sampleCount / (size.width / (drawSpaces ? 2.0 : 1.0)));
    
    SInt16* samples = (SInt16*) fullSongData.mutableBytes;
    
    int i = 0;
    
    while (i < sampleCount)
    {
        SInt16 val = 0;
        
        for (int j = 0; j < adjustFactor; j++)
        {
            val += samples[i + j];
        }
        val /= adjustFactor;
        if (ABS(val) > maxValue)
        {
            maxValue = ABS(val);
        }
        [adjustedSongData appendBytes:&val length:sizeof(val)];
        i += adjustFactor;
    }
    
    sampleCount = adjustedSongData.length / 2;
    
    if (reader.status == AVAssetReaderStatusCompleted)
    {
        UIImage *image = [self drawImageFromSamples:(SInt16 *)adjustedSongData.bytes
                                           maxValue:maxValue
                                        sampleCount:sampleCount
                          withColor:color andSize:size
                                         drawSpaces:drawSpaces
                                            context:context];
        return image;
    }
    return nil;
}
+ (UIImage*)recolorizeImage:(UIImage*)image withColor:(UIColor*)color
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

- (void)generateWaveforms
{
    CGRect rect = self.bounds;
    
    
    if(!self.generatedNormalImage)
    {
#ifndef __OPTIMIZE__
        NSDate *beginDate = [NSDate date];
#endif
        if(self.audioFileUrl)
        {
            self.generatedNormalImage = [SCWaveformView generateWaveformImageWithFile:self.audioFileUrl withColor:self.normalColor andSize:CGSizeMake(rect.size.width, rect.size.height) antialiasingEnabled:self.antialiasingEnabled];
            _normalColorDirty = NO;
        }
        else
            if(self.asset)
        {
            self.generatedNormalImage = [SCWaveformView generateWaveformImage:self.asset withColor:self.normalColor andSize:CGSizeMake(rect.size.width, rect.size.height) antialiasingEnabled:self.antialiasingEnabled];
            _normalColorDirty = NO;
        }
#ifndef __OPTIMIZE__
        NSDate * endDate = [NSDate date];
        NSLog(@"ticks :%f",[endDate timeIntervalSinceDate:beginDate]);
#endif
    }
    
//    if (self.generatedNormalImage == nil && self.asset) {
//        self.generatedNormalImage = [SCWaveformView generateWaveformImage:self.asset withColor:self.normalColor andSize:CGSizeMake(rect.size.width, rect.size.height) antialiasingEnabled:self.antialiasingEnabled];
//        _normalColorDirty = NO;
//    }
    
    if (self.generatedNormalImage != nil) {
        if (_normalColorDirty) {
            self.generatedNormalImage = [SCWaveformView recolorizeImage:self.generatedNormalImage withColor:self.normalColor];
            _normalColorDirty = NO;
        }
        
        if (_progressColorDirty || self.generatedProgressImage == nil) {
            self.generatedProgressImage = [SCWaveformView recolorizeImage:self.generatedNormalImage withColor:self.progressColor];
            _progressColorDirty = NO;
        }
        
        if (self.hightLightMode && _progressColorRightDirty ){
            _progressImageView2.image = [SCWaveformView recolorizeImage:self.generatedNormalImage withColor:self.progressColor];
            
            _progressColorRightDirty = NO;
        }
    }
    
}

- (void)drawRect:(CGRect)rect
{
    [self generateWaveforms];
    
    [super drawRect:rect];
}

- (void)applyProgressToSubviews
{
    CGRect bs = self.bounds;
    if(self.hightLightMode)
    {
        CGFloat progressWidth = hightLightLeft_;
        _cropProgressView.frame = CGRectMake(0, 0, progressWidth, bs.size.height);
        
        _cropNormalView.frame = CGRectMake(progressWidth, 0, hightLightRight_ - progressWidth , bs.size.height);
        _normalImageView.frame = CGRectMake(-progressWidth, 0, bs.size.width, bs.size.height);
        
        _cropProgressViewRight.frame = CGRectMake(hightLightRight_, 0,bs.size.width - hightLightRight_, bs.size.height);
        _progressImageView2.frame = CGRectMake(0 - hightLightRight_ , 0, bs.size.width, bs.size.height);
        //        NSLog(@"frames:left: %@  image:%@",NSStringFromCGRect(_cropProgressView.frame),NSStringFromCGRect(_progressImageView.frame));
        //       NSLog(@"frames:middle: %@  image:%@",NSStringFromCGRect(_cropNormalView.frame),NSStringFromCGRect(_normalImageView.frame));
        //        NSLog(@"frames:right: %@  image:%@",NSStringFromCGRect(_cropProgressViewRight.frame),NSStringFromCGRect(_progressImageView2.frame));
    }
    else
    {
        CGFloat progressWidth = bs.size.width * _progress;
        _cropProgressView.frame = CGRectMake(0, 0, progressWidth, bs.size.height);
        _cropNormalView.frame = CGRectMake(progressWidth, 0, bs.size.width - progressWidth, bs.size.height);
        _normalImageView.frame = CGRectMake(-progressWidth, 0, bs.size.width, bs.size.height);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bs = self.bounds;
    _normalImageView.frame = bs;
    _progressImageView.frame = bs;
    
    // If the size is now bigger than the generated images
    if (bs.size.width > self.generatedNormalImage.size.width) {
        self.generatedNormalImage = nil;
        self.generatedProgressImage = nil;
    }
    
    [self applyProgressToSubviews];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    _normalColorDirty = YES;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    _progressColorDirty = YES;
    _progressColorRightDirty = YES;
    [self setNeedsDisplay];
}

- (void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    if(_asset)
        _durance = asset.duration;
    else
        _durance = CMTimeMake(0, 60);
    
    self.generatedProgressImage = nil;
    self.generatedNormalImage = nil;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self applyProgressToSubviews];
}
- (void)setSelectedRegin:(CGFloat)left right:(CGFloat)right
{
    _hightLightMode = YES;
    hightLightLeft_ = left;
    hightLightRight_ = right;
    if(!_cropProgressViewRight)
    {
        _progressImageView2 = [[UIImageView alloc]init];
        _cropProgressViewRight = [[UIView alloc]init];
        _cropProgressViewRight.clipsToBounds = YES;
        [_cropProgressViewRight addSubview:_progressImageView2];
        [self addSubview:_cropProgressViewRight];
    }
    [self applyProgressToSubviews];
}
- (void)setSelectedSecondsRegion:(CGFloat) beginSeconds end:(CGFloat)endSeconds
{
    NSLog(@"not impliment...");
}
- (UIImage*)generatedNormalImage
{
    return _normalImageView.image;
}

- (void)setGeneratedNormalImage:(UIImage *)generatedNormalImage
{
    _normalImageView.image = generatedNormalImage;
}

- (UIImage*)generatedProgressImage
{
    return _progressImageView.image;
}

- (void)setGeneratedProgressImage:(UIImage *)generatedProgressImage
{
    _progressImageView.image = generatedProgressImage;
}

- (void)setAntialiasingEnabled:(BOOL)antialiasingEnabled
{
    if (_antialiasingEnabled != antialiasingEnabled) {
        _antialiasingEnabled = antialiasingEnabled;
        self.generatedProgressImage = nil;
        self.generatedNormalImage = nil;
        [self setNeedsDisplay];        
    }
}

@end
