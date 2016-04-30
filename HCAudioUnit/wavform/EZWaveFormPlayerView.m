//
//  EZWaveFormPlayerView.m
//  Wutong
//
//  Created by HUANGXUTAO on 15/8/14.
//  Copyright (c) 2015年 HUANGXUTAO. All rights reserved.
//

#import "EZWaveFormPlayerView.h"
#import <hccoren/base.h>

#import "EZAudioPlotGL.h"

@implementation EZWaveFormPlayerView
{
    UIButton *playPauseButton;
}

- (id)initWithFrame:(CGRect)frame
              color:(UIColor *)normalColor
      progressColor:(UIColor *)progressColor {
    if (self = [super initWithFrame:frame]) {
        
        //        AVAudioSession *session = [AVAudioSession sharedInstance];
        //        NSError *error;
        //        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        //        if (error)
        //        {
        //            NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        //        }
        //        [session setActive:YES error:&error];
        //        if (error)
        //        {
        //            NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
        //        }
        
        //
        // Customizing the audio plot's look
        //
        
        self.audioPlot.backgroundColor = [UIColor whiteColor];
        self.audioPlot.color           = normalColor;
        self.audioPlot.plotType        = EZPlotTypeRolling;
        self.audioPlot.shouldFill      = YES;
        self.audioPlot.shouldMirror    = YES;
        self.audioPlot.frame = self.bounds;
        
        self.audioPlot.shouldOptimizeForRealtimePlot = YES;
        
        // Customize the layer with a shadow for fun
        self.audioPlot.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
        
        self.audioPlot.waveformLayer.shadowRadius = 0.0;
        
        self.audioPlot.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
        
        self.audioPlot.waveformLayer.shadowOpacity = 1.0;
        
        self.audioPlot.waveformLayer.frame = self.bounds;
        
        [self addSubview:self.audioPlot];
        //        [self.layer addSublayer:self.audioPlot.waveformLayer];
        
        //        NSLog(@"outputs: %@", [EZAudioDevice outputDevices]);
        
        //
        // Create the audio player
        //
        self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
        
        //        self.player.shouldLoop = YES;
        
        // Override the output to the speaker
        //        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        //        if (error)
        //        {
        //            NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
        //        }
        
        //        //
        //        // Customize UI components
        //        //
        //        self.rollingHistorySlider.value = (float)[self.audioPlot rollingHistoryLength];
        //
        //        //
        // Listen for EZAudioPlayer notifications
        //
        [self setupNotifications];
        
        /*
         Try opening the sample file
         */
        //        [self openFileWithFilePathURL:asset.URL];
        
        //        [self.audioPlot setRollingHistoryLength:(int)value];
        
        
        //        player = [[AVAudioPlayer alloc] initWithContentsOfURL:asset.URL error:nil];
        //        player.delegate = self;
        //
        //        waveformView = [[SCWaveformView alloc] init];
        //        waveformView.normalColor = normalColor;
        //        waveformView.progressColor = progressColor;
        //        waveformView.alpha = 0.8;
        //        waveformView.backgroundColor = [UIColor clearColor];
        //        waveformView.asset = asset;
        //        [self addSubview:waveformView];
        //
        playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playPauseButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
        [playPauseButton addTarget:self
                            action:@selector(playOrPauseTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playPauseButton];
        
        //        if(timer_)
        //        {
        //            [timer_ invalidate];
        //            PP_RELEASE(timer_);
        //        }
        //        timer_ = PP_RETAIN([NSTimer scheduledTimerWithTimeInterval:0.1 target: self
        //                                                          selector: @selector(updateWaveform:)
        //                                                          userInfo: nil repeats: YES]);
        
    }
    
    return self;
}
- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    playPauseButton.frame = CGRectMake(5, self.frame.size.height/2 - self.frame.size.height/4 , self.frame.size.height/2, self.frame.size.height/2);
    playPauseButton.layer.cornerRadius = self.frame.size.height/4;

    self.audioPlot.frame = CGRectMake(self.frame.size.height/2 + 10, 0, self.frame.size.width - (self.frame.size.height/2 + 10), self.frame.size.height);
//    waveformView.frame = CGRectMake(self.frame.size.height/2 + 10, 0, self.frame.size.width - (self.frame.size.height/2 + 10), self.frame.size.height);
}
- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player change play state, isPlaying: %i", [player isPlaying]);
}


- (void)playOrPauseTapped:(id)sender
{
    if(![self.player isPlaying]){
        [playPauseButton setImage:[UIImage imageNamed:@"pausebutton.png"] forState:UIControlStateNormal];
        //        if(![self.player isPlaying])
        //        {
        [self.player play];
        //        }
        //        timer_.fireDate = [NSDate distantPast];
    } else {
        [playPauseButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
        //        if([self.player isPlaying])
        //        {
        [self.player pause];
        //        }
        //        [self.player pause];
        //        timer_.fireDate = [NSDate distantFuture];
    }
}
- (void)playPauseTapped:(BOOL)isPlay
{
    if(isPlay)
    {
        [playPauseButton setImage:[UIImage imageNamed:@"pausebutton.png"] forState:UIControlStateNormal];
        if(![self.player isPlaying])
        {
            [self.player play];
        }
        //        timer_.fireDate = [NSDate distantPast];
    } else {
        [playPauseButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
        if([self.player isPlaying])
        {
            [self.player pause];
        }
        //        [self.player pause];
        //        timer_.fireDate = [NSDate distantFuture];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
//    [self.player pause];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint location = [touch locationInView:touch.view];
    if(location.x/self.frame.size.width > 0) {
        //        waveformView.progress = location.x/self.frame.size.width;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSTimeInterval newTime = waveformView.progress * player.duration;
    //    self.player.currentTime = newTime;
//        [playPauseButton setImage:[UIImage imageNamed:@"pausebutton.png"] forState:UIControlStateNormal];
//        [self.player play];
    
}

- (void)updateWaveform:(id)sender {
    
    if(self.player.isPlaying) {
        //        waveformView.progress = self.player.currentTime/CMTimeGetSeconds(self.player.duration);
    }
}

-(void)seekTo:(CGFloat)x
{
    //    waveformView.progress = x;
    //    NSTimeInterval newTime = waveformView.progress * player.duration;
    //    player.currentTime = newTime;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    [playPauseButton setImage:[UIImage imageNamed:@"playbutton.png"] forState:UIControlStateNormal];
    
}

- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    //
    // Create the EZAudioPlayer
    //
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    
    //
    // Update the UI
    //
    //    self.filePathLabel.text = filePathURL.lastPathComponent;
    //    self.positionSlider.maximumValue = (float)self.audioFile.totalFrames;
    //    self.volumeSlider.value = [self.player volume];
    
    //
    // Plot the whole waveform
    //
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
     {
         [weakSelf.audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
         //         [weakSelf.audioPlot redraw];
     }];
    
    //
    // Play the audio file
    //
    [self.player setAudioFile:self.audioFile];
    //    [self.player play];
}

//------------------------------------------------------------------------------
//
//- (void)play:(id)sender
//{
//    if ([self.player isPlaying])
//    {
//        [self.player pause];
//    }
//    else
//    {
//        if (self.audioPlot.shouldMirror && (self.audioPlot.plotType == EZPlotTypeBuffer))
//        {
//            self.audioPlot.shouldMirror = NO;
//            self.audioPlot.shouldFill = NO;
//        }
//        [self.player play];
//    }
//}

//------------------------------------------------------------------------------

- (void)seekToFrame:(id)sender
{
    [self.player seekToFrame:(SInt64)[(UISlider *)sender value]];
}

//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void)  audioPlayer:(EZAudioPlayer *)audioPlayer
          playedAudio:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
          inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
//    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //        if (!weakSelf.positionSlider.touchInside)
        //        {
        //            weakSelf.positionSlider.value = (float)framePosition;
        //        }
    });
}

- (void)readyToRelease
{
    if(timer_)
    {
        [timer_ invalidate];
        PP_RELEASE(timer_);
    }
    if(self.player.isPlaying)
    {
        [self.player pause];
    }
    //    if(player)
    //    {
    //        player.delegate = nil;
    //    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)dealloc
{
    [self readyToRelease];
    PP_SUPERDEALLOC;
}
@end
