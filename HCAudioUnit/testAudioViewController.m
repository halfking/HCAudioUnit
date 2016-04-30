//
//  testAudioViewController.m
//  maiba
//
//  Created by WangSiyu on 15/10/23.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "testAudioViewController.h"
#import <hccoren/base.h>
#import "AudioCenterNew.h"
#import "AudioCenterNew(soundtouch).h"
#import "AudioCenterNew(offline).h"

#import "WTAudioPlayer.h"
#import "AEAudioController.h"
#import "AENewTimePitchFilter.h"

#import "AEAudioUnitFilter.h"
#import "AENewTimePitchFilter.h"
#import "AEDelayFilter.h"
#import "AELowPassFilter.h"
#import "AEHighPassFilter.h"
#import "AEBandpassFilter.h"

//#import "UDManager(Helper).h"

#import "reverbViewController.h"
#import "AEVarispeedFilter.h"

//#import "SoundTouch/SoundTouch.h"
@interface testAudioViewController ()
{
    WTAudioPlayer *player;
    AEAudioController * ac_;
    
    
    //    AEBlockFilter *gainFilter_;
    //    AEReverbFilter *reverbFilter_;
    //    AEDynamicsProcessorFilter *dynamicsProcessorFilter_;
    //    AEDelayFilter * delayFilter_;
    //    AENewTimePitchFilter * pitchFilter_;
    //    AELowPassFilter * lowerFilter_;
    //    AEHighPassFilter * hightFilter_;
    
    AEDynamicsProcessorFilter * currentDynamic_;
    AEReverbFilter * currentReverb_;
    
}

@property(nonatomic, weak) IBOutlet UIButton *recordButton;
@property(weak, nonatomic) IBOutlet UIButton *playThroughButton;
@property(weak, nonatomic) IBOutlet UILabel *powerLabel;
@property(weak, nonatomic) IBOutlet UIButton *playButton;

@property(weak, nonatomic) IBOutlet UITextField *recordFilePath;
@property(weak, nonatomic) IBOutlet UIButton *change1;
@property(weak, nonatomic) IBOutlet UIButton *change2;
@property(weak, nonatomic) IBOutlet UIButton *change3;
@property(weak, nonatomic) IBOutlet UIButton *change4;
@property(weak, nonatomic) IBOutlet UIButton *moreBtn;

@property(weak, nonatomic) IBOutlet UISlider *sliderTemp;
@property(weak, nonatomic) IBOutlet UISlider *sliderPitch;
@property(weak, nonatomic) IBOutlet UISlider *sliderRate;
@property(weak, nonatomic) IBOutlet UISlider *sliderDelay;
@property(weak, nonatomic) IBOutlet UISlider *sliderReverb;
@property(weak, nonatomic) IBOutlet UISlider *sliderPlayThroughVol;
@property(weak, nonatomic) IBOutlet UISlider *sliderLow;
@property(weak, nonatomic) IBOutlet UISlider *sliderMid;
@property(weak, nonatomic) IBOutlet UISlider *sliderHigh;

@property(weak, nonatomic) IBOutlet UITextField *txtTemp;
@property(weak, nonatomic) IBOutlet UITextField *txtPitch;
@property(weak, nonatomic) IBOutlet UITextField *txtRate;
@property(weak, nonatomic) IBOutlet UITextField *txtDelay;
@property(weak, nonatomic) IBOutlet UITextField *txtReverb;
@property(weak, nonatomic) IBOutlet UITextField *txtPlayThroughVol;
@property(weak, nonatomic) IBOutlet UITextField *txtLow;
@property(weak, nonatomic) IBOutlet UITextField *txtMid;
@property(weak, nonatomic) IBOutlet UITextField *txtHight;


//@property(weak, nonatomic) IBOutlet UITextField *txtReverbDryWet;
@property(weak, nonatomic) IBOutlet UITextField *txtDelayDryWet;

@end

@implementation testAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshPower:) userInfo:nil repeats:YES];
    
    NSString * path = [[NSBundle mainBundle]pathForResource:@"startup" ofType:@"mp4"];
    self.recordFilePath.text  = path;
    
    currentDynamic_ = [[AEDynamicsProcessorFilter alloc]init];
    currentReverb_ = [[AEReverbFilter alloc]init];
    [self setDefaultReverb];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)buildFilters
{
    //    pitchFilter_ = nil;
    //    if(!pitchFilter_)
    //    {
    //        pitchFilter_ = [[AENewTimePitchFilter alloc]init];
    //    }
    //    if(!reverbFilter_)
    //    {
    //        reverbFilter_ = [[AEReverbFilter alloc]init];
    //    }
    //
    //    if(!dynamicsProcessorFilter_)
    //    {
    //        dynamicsProcessorFilter_ = [[AEDynamicsProcessorFilter alloc]init];
    //    }
    //
    //    if(!delayFilter_)
    //    {
    //        delayFilter_ = [[AEDelayFilter alloc]init];
    //    }
    //    if(!lowerFilter_)
    //    {
    //        lowerFilter_ = [[AELowPassFilter alloc]init];
    //    }
    //    if(!hightFilter_)
    //    {
    //        hightFilter_ = [[AEHighPassFilter alloc]init];
    //    }
}
#pragma mark - text
- (IBAction)sliderTempChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    self.txtTemp.text = [NSString stringWithFormat:@"%d",(int)roundf(slider.value)];
}
- (IBAction)sliderPitchChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    self.txtPitch.text = [NSString stringWithFormat:@"%d",(int)roundf(slider.value)];
}
- (IBAction)sliderRateChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    CGFloat v = pow(2,slider.value);
    self.txtRate.text = [NSString stringWithFormat:@"%.2f",v];
}
- (IBAction)sliderReverbChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    self.txtReverb.text = [NSString stringWithFormat:@"%d",(int)roundf(slider.value)];
}
- (IBAction)sliderDelayChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    self.txtDelay.text = [NSString stringWithFormat:@"%.2f",slider.value];
}
- (IBAction)valueChanged:(UISlider *)sender
{
    [AudioCenterNew shareAudioCenter].audioGain = sender.value;
    self.powerLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
}
- (IBAction)sliderLowChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    CGFloat v = slider.value;
    self.txtLow.text = [NSString stringWithFormat:@"%.2f",v];
}

- (IBAction)sliderMidChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    CGFloat v = slider.value;
    self.txtMid.text = [NSString stringWithFormat:@"%.2f",v];
}
- (IBAction)sliderHighChanged:(id)sender
{
    UISlider * slider = (UISlider *)sender;
    CGFloat v = slider.value;
    self.txtHight.text = [NSString stringWithFormat:@"%.2f",v];
}

- (IBAction)sliderVolChanged:(id)sender
{
    
}
- (IBAction)moreBtnClicked:(id)sender
{
    reverbViewController * vc = [[reverbViewController alloc]initWithNibName:nil bundle:nil];
    vc.reverbFilter = currentReverb_;
    vc.dynamicProcessorFilter = currentDynamic_;
    _sliderReverb.value = 5;
    _txtReverb.text = @"5";
    [self.navigationController pushViewController:vc animated:YES];
    vc = nil;
    
}

- (void)buildPitchFilter:(NSMutableArray *)result
{
    AENewTimePitchFilter * pitchFilter_ =  [[AENewTimePitchFilter alloc]init];
    if(self.txtPitch.text && self.txtPitch.text.length>0)
        pitchFilter_.pitch = [self.txtPitch.text floatValue];
    else
        pitchFilter_.pitch = 0;
    if(self.txtTemp.text && self.txtTemp.text.length>0)
        pitchFilter_.overlap = [self.txtTemp.text floatValue];
    else
        pitchFilter_.overlap = 8;
    if(self.txtRate.text && self.txtRate.text.length>0)
        pitchFilter_.rate = [self.txtRate.text floatValue];
    else
        pitchFilter_.rate = 1;
    
    if(pitchFilter_.pitch!=0||pitchFilter_.overlap!=8 || pitchFilter_.rate!=1)
    {
        [result addObject:pitchFilter_];
    }
}
- (void)buildDelayFilter:(NSMutableArray *)result
{
    AEDelayFilter * delayFilter_ = [[AEDelayFilter alloc]init];
    if(self.txtDelay.text && self.txtDelay.text.length>0)
        delayFilter_.delayTime = [self.txtDelay.text floatValue];
    else
        delayFilter_.delayTime = 0;
    if(delayFilter_.delayTime!=0)
    {
        if(self.txtDelayDryWet.text && self.txtDelayDryWet.text.length>0)
        {
            delayFilter_.wetDryMix = [self.txtDelayDryWet.text intValue];
        }
        else
        {
            delayFilter_.wetDryMix = 15;
        }
        [result addObject:delayFilter_];
    }
}
- (NSArray *)buildReverbFilter:(NSMutableArray *)result
{
    AEReverbFilter *reverbFilter_;
    AEDynamicsProcessorFilter *dynamicsProcessorFilter_;
    
    reverbFilter_ = [[AEReverbFilter alloc]init];
    
    dynamicsProcessorFilter_ = [[AEDynamicsProcessorFilter alloc]init];
    
    int type = [self.txtReverb.text intValue];
    switch (type) {
        case 0:
            reverbFilter_.dryWetMix = 0;
            dynamicsProcessorFilter_.masterGain = 0;
            break;
        case 1:
            reverbFilter_.dryWetMix = 10;
            reverbFilter_.gain = 0;
            reverbFilter_.minDelayTime = 0.02;
            reverbFilter_.maxDelayTime = 0.05;
            reverbFilter_.decayTimeAt0Hz = 5.04;
            reverbFilter_.decayTimeAtNyquist = 1.52;
            reverbFilter_.randomizeReflections = 1;
            reverbFilter_.filterFrequency = 800;
            reverbFilter_.filterBandwidth = 3;
            reverbFilter_.filterGain = 0;
            dynamicsProcessorFilter_.threshold = -15.2;
            dynamicsProcessorFilter_.headRoom = 3.16;
            dynamicsProcessorFilter_.expansionRatio = 15.21;
            dynamicsProcessorFilter_.attackTime = 0.16;
            dynamicsProcessorFilter_.releaseTime = 1.5;
            dynamicsProcessorFilter_.masterGain = 3.47;
            break;
        case 2:
            reverbFilter_.dryWetMix = 15.4;
            reverbFilter_.gain = 0;
            reverbFilter_.minDelayTime = 0.02;
            reverbFilter_.maxDelayTime = 0.05;
            reverbFilter_.decayTimeAt0Hz = 5.04;
            reverbFilter_.decayTimeAtNyquist = 1.52;
            reverbFilter_.randomizeReflections = 1;
            reverbFilter_.filterFrequency = 800;
            reverbFilter_.filterBandwidth = 3;
            reverbFilter_.filterGain = 0;
            dynamicsProcessorFilter_.threshold = -15.2;
            dynamicsProcessorFilter_.headRoom = 3.16;
            dynamicsProcessorFilter_.expansionRatio = 15.21;
            dynamicsProcessorFilter_.attackTime = 0.16;
            dynamicsProcessorFilter_.releaseTime = 1.5;
            dynamicsProcessorFilter_.masterGain = 3.47;
            break;
        case 3:
            reverbFilter_.dryWetMix = 15.4;
            reverbFilter_.gain = 0;
            reverbFilter_.minDelayTime = 0.02;
            reverbFilter_.maxDelayTime = 0.05;
            reverbFilter_.decayTimeAt0Hz = 5.04;
            reverbFilter_.decayTimeAtNyquist = 1.52;
            reverbFilter_.randomizeReflections = 1;
            reverbFilter_.filterFrequency = 800;
            reverbFilter_.filterBandwidth = 3;
            reverbFilter_.filterGain = 0;
            dynamicsProcessorFilter_.threshold = -15.2;
            dynamicsProcessorFilter_.headRoom = 3.16;
            dynamicsProcessorFilter_.expansionRatio = 15.21;
            dynamicsProcessorFilter_.attackTime = 0.16;
            dynamicsProcessorFilter_.releaseTime = 1.5;
            dynamicsProcessorFilter_.masterGain = 3.47;
        case 4:
        default:
            reverbFilter_.dryWetMix = currentReverb_.dryWetMix;
            reverbFilter_.gain = currentReverb_.gain;
            reverbFilter_.minDelayTime = currentReverb_.minDelayTime;
            reverbFilter_.maxDelayTime = currentReverb_.maxDelayTime;
            reverbFilter_.decayTimeAt0Hz = currentReverb_.decayTimeAt0Hz;
            reverbFilter_.decayTimeAtNyquist = currentReverb_.decayTimeAtNyquist;
            reverbFilter_.randomizeReflections = currentReverb_.randomizeReflections;
            reverbFilter_.filterFrequency = currentReverb_.filterFrequency;
            reverbFilter_.filterBandwidth = currentReverb_.filterBandwidth;
            reverbFilter_.filterGain = currentReverb_.filterGain;
            dynamicsProcessorFilter_.threshold = currentDynamic_.threshold;
            dynamicsProcessorFilter_.headRoom = currentDynamic_.headRoom;
            dynamicsProcessorFilter_.expansionRatio = currentDynamic_.expansionRatio;
            dynamicsProcessorFilter_.attackTime = currentDynamic_.attackTime;
            dynamicsProcessorFilter_.releaseTime = currentDynamic_.releaseTime;
            dynamicsProcessorFilter_.masterGain = currentDynamic_.masterGain;
            break;
            
    }
    if(type>0)
    {
        //        if(self.txtReverbDryWet.text && self.txtReverbDryWet.text.length>0)
        //        {
        //            reverbFilter_.dryWetMix = [self.txtReverbDryWet.text intValue];
        //        }
        //        else
        //        {
        //            reverbFilter_.dryWetMix = 15;
        //        }
        if(result)
        {
            [result addObject:reverbFilter_];
            [result addObject:dynamicsProcessorFilter_];
        }
    }
    return @[reverbFilter_,dynamicsProcessorFilter_];
}
- (void)setDefaultReverb
{
    currentReverb_.dryWetMix = 30;
    currentReverb_.gain = 0;
    currentReverb_.minDelayTime = 0.008;
    currentReverb_.maxDelayTime = 0.050;
    currentReverb_.decayTimeAt0Hz = 1.0;
    currentReverb_.decayTimeAtNyquist = 0.5;
    currentReverb_.randomizeReflections = 1;
    currentReverb_.filterFrequency = 800;
    currentReverb_.filterBandwidth = 3;
    currentReverb_.filterGain = 0;
    currentDynamic_.threshold = -20;
    currentDynamic_.headRoom = 5;
    currentDynamic_.expansionRatio = 2;
    currentDynamic_.attackTime = 0.001;
    currentDynamic_.releaseTime = 0.05;
    currentDynamic_.masterGain = 0;
}
- (NSArray *)getFilterValues
{
    //    [self buildFilters];
    //    AEBlockFilter *gainFilter_;
    AELowPassFilter * lowerFilter_;
    AEHighPassFilter * hightFilter_;
    
    lowerFilter_ = [[AELowPassFilter alloc]init];
    
    hightFilter_ = [[AEHighPassFilter alloc]init];
    
    NSMutableArray * result = [NSMutableArray new];
    
    [self buildPitchFilter:result];
    
    [self buildDelayFilter:result];
    
    [self buildReverbFilter:result];
    
    
    //    AEVarispeedFilter * filter1 = [[AEVarispeedFilter alloc]init];
    //    filter1.playbackRate = 2;
    //    filter1.playbackCents = 0;
    //    [result addObject:filter1];
    //
    //
    return result;
}
#pragma mark -
- (void)refreshPower:(id)sender
{
    self.powerLabel.text = [NSString stringWithFormat:@"%f",[[AudioCenterNew shareAudioCenter] getCurrentInputPower]];
}

- (IBAction)record:(id)sender
{
    if (self.recordButton.selected) {
        [[AudioCenterNew shareAudioCenter] stopRecord];
        [self.recordButton setSelected:NO];
        self.recordFilePath.text = [[AudioCenterNew shareAudioCenter] getRecordFilePath];
        
    }
    else{
        [[AudioCenterNew shareAudioCenter] startRecord];
        [self.recordButton setSelected:YES];
    }
}
#pragma mark - play
//未变化的
- (IBAction)play:(id)sender{
    if (self.playButton.selected) {
        [player stop];
        player = nil;
        [self.playButton setSelected:NO];
    }
    else{
        NSString *path = self.recordFilePath.text;
        player = [[WTAudioPlayer alloc] initWithUrl:[NSURL URLWithString:path]];
        [player play];
        [self.playButton setSelected:YES];
    }
}
//play with filter
- (IBAction)change1:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if(btn.isSelected)
    {
        [[AudioCenterNew shareAudioCenter]stopWithOptions:nil];
        [btn setSelected:NO];
        return;
    }
    else
    {
        [btn setSelected:YES];
    }
    NSArray * filters = [self getFilterValues];
    //    NSString * path2  = [[NSBundle mainBundle]pathForResource:@"Track0" ofType:@"mp4"];
    
    NSArray * urls = @[
                       @{@"url":[NSURL fileURLWithPath:self.recordFilePath.text],
                         @"start":@(0),
                         @"vol":@(1),
                         @"duration":@(-1)
                         },
                       //                       @{@"url":[NSURL fileURLWithPath:path2],
                       //                         @"start":@(0),
                       //                         @"vol":@(0.1),
                       //                         @"duration":@(-1)
                       //                         }
                       ];
    
    [[AudioCenterNew shareAudioCenter]playItemsWithOptions:urls options:filters completionBlock:^{
        if(btn.isSelected)
        {
            [btn setSelected:NO];
        }
    }];
    
    //    [[AudioCenterNew shareAudioCenter]playWithOptions:[NSURL fileURLWithPath:self.recordFilePath.text] options:filters completionBlock:^{
    //        if(btn.isSelected)
    //        {
    //            [btn setSelected:NO];
    //        }
    //    }];
    
}
- (IBAction)saveAndPlay:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if(btn.isSelected)
    {
        [[AudioCenterNew shareAudioCenter]stopWithOptions:nil];
        [btn setSelected:NO];
        return;
    }
    else
    {
        [btn setSelected:YES];
    }
    
    NSString * path = nil;
    if(!self.recordFilePath.text || self.recordFilePath.text.length==0)
    {
        path = [[NSBundle mainBundle]pathForResource:@"man" ofType:@"mp3"];
        self.recordFilePath.text  = path;
    }
    else
    {
        path = self.recordFilePath.text;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * rootPath = [documentsDirectory stringByAppendingPathComponent:@"localfiles"];
    
    NSString * targetFilePath = [rootPath stringByAppendingPathComponent:[path lastPathComponent]];
    //    [[UDManager sharedUDManager]localFileFullPath:[path lastPathComponent]];
    //    NSString * targetFilePath = [[UDManager sharedUDManager]localFileFullPath:@"a.mp4"];
    [[NSFileManager defaultManager]removeItemAtPath:targetFilePath error:nil];
    NSArray * filters = [self getFilterValues];
    
    
    //    NSString * path2  = [[NSBundle mainBundle]pathForResource:@"Track0" ofType:@"mp4"];
    
    NSArray * urls = @[
                       @{@"url":[NSURL fileURLWithPath:self.recordFilePath.text],
                         @"start":@(0),
                         @"vol":@(1),
                         @"duration":@(-1)
                         },
                       //                       @{@"url":[NSURL fileURLWithPath:path2],
                       //                         @"start":@(0),
                       //                         @"vol":@(0.1),
                       //                         @"duration":@(-1)
                       //                         }
                       ];
    
    [[AudioCenterNew shareAudioCenter]writeFiles:urls
                                      controller:nil options:filters
                                      targetFile:targetFilePath];
    
    
    NSLog(@"playing....\n%@",targetFilePath);
    
    
    [[AudioCenterNew shareAudioCenter]playWithOptions:[NSURL fileURLWithPath:targetFilePath]
                                              options:nil
                                      completionBlock:^{
                                          if(btn.isSelected)
                                          {
                                              [btn setSelected:NO];
                                          }
                                      }];
    NSLog(@"play completed.");
}

- (IBAction)change2:(id)sender
{
    //    AENewTimePitchFilter * pitchFilter = [[AENewTimePitchFilter alloc]init];
    //    pitchFilter.pitch = -800.0;
    //
    //    [self playWithPitch:@[pitchFilter]];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"women" ofType:@"mp3"];
    self.recordFilePath.text  = path;
}

- (IBAction)change3:(id)sender
{
    //    AENewTimePitchFilter * pitchFilter = [[AENewTimePitchFilter alloc]init];
    //    pitchFilter.pitch = 0.0;
    //    //    pitchFilter.overlap = 3;
    //    pitchFilter.rate = 2;
    //    [self playWithPitch:@[pitchFilter]];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"man" ofType:@"mp3"];
    self.recordFilePath.text  = path;
    
}

- (IBAction)change4:(id)sender
{
    //    AENewTimePitchFilter * pitchFilter = [[AENewTimePitchFilter alloc]init];
    //    pitchFilter.pitch = 1000.0;
    //
    //
    //    //    AEReverbFilter * reverbFilter = [[AEReverbFilter alloc] init];
    //    //    [audioController_ addFilter:reverbFilter];
    //
    //    //    AEDelayFilter * delayFilter = [[AEDelayFilter alloc]init];
    //    //    delayFilter.delayTime = 0.1;
    //    //    [audioController_ addFilter:delayFilter];
    //
    //    [self playWithPitch:@[pitchFilter]];
}

- (IBAction)playThrough:(id)sender {
    if (self.playThroughButton.selected) {
        [[AudioCenterNew shareAudioCenter] stopPlayThrough];
        [self.playThroughButton setSelected:NO];
    }
    else{
        [[AudioCenterNew shareAudioCenter] startPlayThrough];
        [self.playThroughButton setSelected:YES];
    }
}

@end
