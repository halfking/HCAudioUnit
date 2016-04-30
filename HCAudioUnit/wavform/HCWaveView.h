//
//  HCWaveView.h
//  HCAudioUnit
//
//  Created by HUANGXUTAO on 16/4/22.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>
#import <CoreMedia/CoreMedia.h>
#import "AudioItemN.h"

@class HCWaveView;
@class AudioItem;
@protocol HCWaveViewDelegate
- (void)WaveView:(HCWaveView *)waveView changeProgress:(CGFloat)seconds;
- (void)WaveView:(HCWaveView *)waveView reachEnd:(CGFloat)seconds;
@end

@interface HCWaveView : UIView
{
    NSMutableArray * audioList_;    //当前音频文件列表。指已经录好的音频文件
                                    //所有的Sample根据显示像素处理后的数据，无无效数据，用于加速显示。
                                    //包括文件与临时加入的，每个文件对应一个元素，其元素为NSData，
                                    //刚录音的对应最后一个元素，无文件对应，估计大小为 375*2 = ...
    UInt32 samplesPerPixel_;        //每个像素对应多少个音频数据包
    UInt32 heightInPixels_;        //每个像素对应多少个音频数据包
    UInt64 totalSamples_;           //总有效采样包
    UInt32 totalPixels_;
    
    BOOL waveDataCreated_;
    BOOL waveViewCreated_;
}
@property (nonatomic,assign) CGFloat DurationSeconds;
@property (nonatomic,assign,readonly) CGFloat ProgressSeconds;

- (void) addSampleInfo:(CMSampleBufferRef*)sample; //新增采样，请要用于边录音边显示的问题，不过，只画出图形，但不记录原图片
- (void) addAudioFile:(AudioItemN *)audioItem;

@end
