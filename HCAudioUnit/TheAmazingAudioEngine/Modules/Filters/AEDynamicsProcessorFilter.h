//
//  AEDynamicsProcessorFilter.h
//  The Amazing Audio Engine
//
//  Created by Jeremy Flores on 4/25/13.
//  Copyright (c) 2015 Dream Engine Interactive, Inc and A Tasty Pixel Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AEAudioUnitFilter.h"

@interface AEDynamicsProcessorFilter : AEAudioUnitFilter

- (instancetype)init;

//Like crossing through a doorway, this is the beginning point of gain adjustment. When the input signal is below the threshold for compressors, or above the threshold for expanders, a dynamics processor acts like a piece of wire. Above the threshold, the side-chain asserts itself and reduces the volume (or the other way around for an expander). A workable range for compressors is -40 dBu to +20 dBu. A good expander extends the range to -60 dBu for low-level signals.
// range is from -40dB to 20dB. Default is -20dB.
@property (nonatomic) double threshold;//门槛、极限

//在数字和模拟音频,空间是指一个音频系统的信号处理能力,超过指定的级别称为允许最大级别(PML)。空间可以被认为是一个安全地带允许瞬态音频峰值超过了PML不破坏系统或音频信号,如。通过剪裁。标准组织有不同的PML的建议。
// range is from 0.1dB to 40dB. Default is 5dB.
@property (nonatomic) double headRoom;

// range is from 1 to 50 (rate). Default is 2.
@property (nonatomic) double expansionRatio;

// Value is in dB.
@property (nonatomic) double expansionThreshold;

// range is from 0.0001 to 0.2. Default is 0.001.
@property (nonatomic) double attackTime;

// range is from 0.01 to 3. Default is 0.05.
@property (nonatomic) double releaseTime;

// range is from -40dB to 40dB. Default is 0dB.
@property (nonatomic) double masterGain;

@property (nonatomic, readonly) double compressionAmount;
@property (nonatomic, readonly) double inputAmplitude;
@property (nonatomic, readonly) double outputAmplitude;

@end
