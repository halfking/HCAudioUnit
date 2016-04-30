//
//  SCWaveformView.h
//  SCWaveformView
//
//  Created by Simon CORSIN on 24/01/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SCWaveformView : UIView

@property (strong, readwrite, nonatomic) AVAsset *asset;
@property (strong,readwrite,nonatomic) NSURL * audioFileUrl;
@property (strong, readwrite, nonatomic) UIColor *normalColor;
@property (strong, readwrite, nonatomic) UIColor *progressColor;
@property (assign, readwrite, nonatomic) CGFloat progress;
@property (assign, readwrite, nonatomic) BOOL hightLightMode; //即用于编辑过程，只取其中一段的显示模式
@property (assign, readwrite, nonatomic) BOOL antialiasingEnabled;

@property (readwrite, nonatomic) UIImage *generatedNormalImage;
@property (readwrite, nonatomic) UIImage *generatedProgressImage;
@property (assign,nonatomic,readonly) CMTime durance;
// Ask the waveformview to generate the waveform right now
// instead of doing it in the next draw operation
- (void)generateWaveforms;

//在HightMode下，设置Highlight的区域，其它用普通色，高亮用ProgressColor
- (void)setSelectedRegin:(CGFloat) left right:(CGFloat)right;
- (void)setSelectedSecondsRegion:(CGFloat) beginSeconds end:(CGFloat)endSeconds;

//用于显示不同区域的图片
//- (void)setHightLightColor:(CGFloat)left right:(CGFloat) color:(UIColor *)hightlightColor;

// Render the waveform on a specified context
+ (void)renderWaveformInContext:(CGContextRef)context asset:(AVAsset *)asset withColor:(UIColor *)color andSize:(CGSize)size antialiasingEnabled:(BOOL)antialiasingEnabled;

// Generate a waveform image for an asset
+ (UIImage*)generateWaveformImage:(AVAsset*)asset withColor:(UIColor*)color andSize:(CGSize)size antialiasingEnabled:(BOOL)antialiasingEnabled;

+ (UIImage*)generateWaveformImageWithFile:(NSURL*)url withColor:(UIColor*)color andSize:(CGSize)size antialiasingEnabled:(BOOL)antialiasingEnabled;
@end
