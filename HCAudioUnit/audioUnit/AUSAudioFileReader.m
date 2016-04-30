//
//  AUSAudioFileReader.m
//  maiba
//
//  Created by WangSiyu on 15/9/26.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "AUSAudioFileReader.h"

@interface AUSAudioFileReader ()
{
	ExtAudioFileRef audioFile;
}
@end

@implementation AUSAudioFileReader

- (id)initWithURL:(NSURL *)fileURL
{
	if((self = [super init]))
	{
		[self loadFileAtURL:fileURL];
	}
	return self;
}

- (AudioStreamBasicDescription)noninterleavedPCMFormatWithChannels:(UInt32)channels
{
	UInt32 bytesPerSample = sizeof(Float32);

	AudioStreamBasicDescription asbd;
	bzero(&asbd, sizeof(asbd));
	asbd.mSampleRate = 44100.0;
	asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	asbd.mBitsPerChannel = 8 * bytesPerSample;
	asbd.mBytesPerFrame = bytesPerSample;
	asbd.mBytesPerPacket = bytesPerSample;
	asbd.mFramesPerPacket = 1;
	asbd.mChannelsPerFrame = channels;

	return asbd;
}

- (void)loadFileAtURL:(NSURL *)fileURL
{
	OSStatus result = noErr;
	result = ExtAudioFileOpenURL((__bridge CFURLRef)fileURL, &audioFile);
	if(result != noErr)
	{
		NSLog(@"Error: could not open file for playback: %d", (int)result);
	}

	AudioStreamBasicDescription clientFormat = [self noninterleavedPCMFormatWithChannels:2];
	result = ExtAudioFileSetProperty(audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
	if(result != noErr)
		NSLog(@"Error: could not set client audio format for playback: %d", (int)result);
}

- (BOOL)readSamples:(AudioBufferList *)data
		atTimeStamp:(const AudioTimeStamp *)timeStamp
	   numberFrames:(UInt32)frames
{
	OSStatus result = ExtAudioFileRead(audioFile, &frames, data);

	return (result == noErr);
}

- (void)seekToSample:(SInt64)sampleIndex
{
	ExtAudioFileSeek(audioFile, sampleIndex);
}

@end
