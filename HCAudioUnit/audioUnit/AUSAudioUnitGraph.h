//
//  AUSAudioUnitGraph.h
//  maiba
//
//  Created by WangSiyu on 15/9/26.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AUSAudioUnitGraph : NSObject

@property(nonatomic, assign) Float64 sampleRate;

- (void)start;
- (void)stop;
- (void)setVolume:(Float32)volume forElement:(UInt32)element;
- (void)setFileReader:(id)reader forElement:(UInt32)element;

@end
