//
//  AudioBarGraphWaveView.h
//  audioBarGraphWave
//
//  Created by lieyunye on 10/15/15.
//  Copyright © 2015 lieyunye. All rights reserved.
//

#define GraphCnt 200
#import <UIKit/UIKit.h>

@interface AudioBarGraphWaveView : UIView
@property (nonatomic, strong) NSURL* soundURL;
@property (nonatomic, strong) UIColor* waveColor;
@property (nonatomic, strong) UIColor* progressColor;
@property (nonatomic, assign) CGFloat drawSpace;
@property (nonatomic, assign) NSInteger upperAndlowerSpace;
@property (nonatomic, assign) BOOL hasProgress;
- (CGFloat) secondsForPoint:(CGPoint) point;
- (void) timeChanged:(CGFloat)playingSeconds;

//返回添加的对像的宽度
- (CGFloat) addSamplesWithOffset:(SInt16 *)samples
                           count:(SInt16)count
                    channelCount:(int)channelCount
                 samplesPerPixel:(NSInteger)samplesPerPixel;
- (UIImage *)drawImageWithBuffer:(CGFloat)leftX;

@end
