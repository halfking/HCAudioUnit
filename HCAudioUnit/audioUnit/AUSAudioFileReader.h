//
//  AUSAudioFileReader.h
//  maiba
//
//  Created by WangSiyu on 15/9/26.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface AUSAudioFileReader : NSObject

- (id)initWithURL:(NSURL *)fileURL;

- (BOOL)readSamples:(AudioBufferList *)data
		atTimeStamp:(const AudioTimeStamp *)timeStamp
	   numberFrames:(UInt32)frames;

- (void)seekToSample:(SInt64)sampleIndex;

@end
