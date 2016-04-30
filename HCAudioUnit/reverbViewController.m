//
//  reverbViewController.m
//  maiba
//
//  Created by WangSiyu on 15/10/28.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import "reverbViewController.h"
#import "AudioCenterNew.h"
//#import "ViewController.h"
#import "TheAmazingAudioEngine.h"
#import "AEReverbFilter.h"
#import "AEDelayFilter.h"
#import "AEPlaythroughChannel.h"

//@interface reverbViewController ()
//{
//    AEReverbFilter *reverbFilter_;
//    AEDynamicsProcessorFilter *dynamicsProcessorFilter_;
//}

//@end

@implementation reverbViewController
@synthesize reverbFilter = reverbFilter_;
@synthesize dynamicProcessorFilter = dynamicsProcessorFilter_;
//+ (instancetype)sharereverbViewController
//{
//    static dispatch_once_t t = 0;
//    static reverbViewController *vc = nil;
//    dispatch_once(&t, ^{
//        vc = [[reverbViewController alloc] initWithNibName:nil bundle:nil];
//    });
//    return vc;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!reverbFilter_)
        reverbFilter_ = [[AEReverbFilter alloc]init];
    if(!dynamicsProcessorFilter_)
        dynamicsProcessorFilter_ = [[AEDynamicsProcessorFilter alloc]init];
    
//    dynamicsProcessorFilter_ = [[AudioCenterNew shareAudioCenter]getDynamicsProcessorFilter];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"dryWetMix"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"dryWetMix"];
//        reverbFilter_.dryWetMix = [value floatValue];
//    }
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"gain"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"gain"];
//        reverbFilter_.gain = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"minDelayTime"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"minDelayTime"];
//        reverbFilter_.minDelayTime = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"maxDelayTime"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxDelayTime"];
//        reverbFilter_.maxDelayTime = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"decayTimeAt0Hz"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"decayTimeAt0Hz"];
//        reverbFilter_.decayTimeAt0Hz = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"decayTimeAtNyquist"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"decayTimeAtNyquist"];
//        reverbFilter_.decayTimeAtNyquist = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"randomizeReflections"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"randomizeReflections"];
//        reverbFilter_.randomizeReflections = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"filterFrequency"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"filterFrequency"];
//        reverbFilter_.filterFrequency = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"filterBandwidth"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"filterBandwidth"];
//        reverbFilter_.filterBandwidth = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"filterGain"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"filterGain"];
//        reverbFilter_.filterGain = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"threshold"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"threshold"];
//        dynamicsProcessorFilter_.threshold = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"headRoom"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"headRoom"];
//        dynamicsProcessorFilter_.headRoom = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"expansionRatio"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"expansionRatio"];
//        dynamicsProcessorFilter_.expansionRatio = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"attackTime"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"attackTime"];
//        dynamicsProcessorFilter_.attackTime = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"releaseTime"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"releaseTime"];
//        dynamicsProcessorFilter_.releaseTime = [value floatValue];
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"masterGain"]) {
//        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"masterGain"];
//        dynamicsProcessorFilter_.masterGain = [value floatValue];
//    }
    [self refreshViews];
}
- (void)refreshViews
{
    _label0.text = [NSString stringWithFormat:@"%.2f",reverbFilter_.dryWetMix];
    _slider0.value = reverbFilter_.dryWetMix;
    _label1.text = [NSString stringWithFormat:@"%.2f",reverbFilter_.gain];
    _slider1.value = reverbFilter_.gain;
    
    
    _label2.text = [NSString stringWithFormat:@"%.3f",reverbFilter_.minDelayTime];
    _slider2.value = reverbFilter_.minDelayTime;
    _label3.text = [NSString stringWithFormat:@"%.3f",reverbFilter_.maxDelayTime];
    _slider3.value = reverbFilter_.maxDelayTime;
    _label4.text = [NSString stringWithFormat:@"%.3f",reverbFilter_.decayTimeAt0Hz];
    _slider4.value = reverbFilter_.decayTimeAt0Hz;
    _label5.text = [NSString stringWithFormat:@"%.3f",reverbFilter_.decayTimeAtNyquist];
    _slider5.value = reverbFilter_.decayTimeAtNyquist;
   
    _label6.text = [NSString stringWithFormat:@"%.2f",reverbFilter_.randomizeReflections];
    _slider6.value = reverbFilter_.randomizeReflections;

    _label7.text = [NSString stringWithFormat:@"%.0f",reverbFilter_.filterFrequency];
    _slider7.value = reverbFilter_.filterFrequency;

    _label8.text = [NSString stringWithFormat:@"%.0f",reverbFilter_.filterBandwidth];
    _slider8.value = reverbFilter_.filterBandwidth;

    _label9.text = [NSString stringWithFormat:@"%.2f",reverbFilter_.filterGain];
    _slider9.value = reverbFilter_.filterGain;
    
    _label10.text = [NSString stringWithFormat:@"%.2f",dynamicsProcessorFilter_.threshold];
    _slider10.value = dynamicsProcessorFilter_.threshold;
    
    _label11.text = [NSString stringWithFormat:@"%.2f",dynamicsProcessorFilter_.headRoom];
    _slider11.value = dynamicsProcessorFilter_.headRoom;
    _label12.text = [NSString stringWithFormat:@"%.2f",dynamicsProcessorFilter_.expansionRatio];
    _slider12.value = dynamicsProcessorFilter_.expansionRatio;
    _label13.text = [NSString stringWithFormat:@"%.3f",dynamicsProcessorFilter_.attackTime];
    _slider13.value = dynamicsProcessorFilter_.attackTime;
    _label14.text = [NSString stringWithFormat:@"%.3f",dynamicsProcessorFilter_.releaseTime];
    _slider14.value = dynamicsProcessorFilter_.releaseTime;
    _label15.text = [NSString stringWithFormat:@"%f",dynamicsProcessorFilter_.masterGain];
    _slider15.value = dynamicsProcessorFilter_.masterGain;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChanged0:(UISlider *)sender{
    reverbFilter_.dryWetMix = sender.value;
    _label0.text = [NSString stringWithFormat:@"%.2f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"dryWetMix"];
}
- (IBAction)valueChanged1:(UISlider *)sender{
    reverbFilter_.gain = sender.value;
    _label1.text = [NSString stringWithFormat:@"%.2f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"gain"];
}
- (IBAction)valueChanged2:(UISlider *)sender{
    reverbFilter_.minDelayTime = sender.value;
    _label2.text = [NSString stringWithFormat:@"%.3f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"minDelayTime"];
}
- (IBAction)valueChanged3:(UISlider *)sender{
    reverbFilter_.maxDelayTime = sender.value;
    _label3.text = [NSString stringWithFormat:@"%.3f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"maxDelayTime"];
}
- (IBAction)valueChanged4:(UISlider *)sender{
    reverbFilter_.decayTimeAt0Hz = sender.value;
    _label4.text = [NSString stringWithFormat:@"%.3f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"decayTimeAt0Hz"];
}
- (IBAction)valueChanged5:(UISlider *)sender{
    reverbFilter_.decayTimeAtNyquist = sender.value;
    _label5.text = [NSString stringWithFormat:@"%.3f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"decayTimeAtNyquist"];
}
- (IBAction)valueChanged6:(UISlider *)sender{
    reverbFilter_.randomizeReflections = sender.value;
    _label6.text = [NSString stringWithFormat:@"%f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"randomizeReflections"];
}
- (IBAction)valueChanged7:(UISlider *)sender{
    reverbFilter_.filterFrequency = sender.value;
    _label7.text = [NSString stringWithFormat:@"%f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"filterFrequency"];
}
- (IBAction)valueChanged8:(UISlider *)sender{
    reverbFilter_.filterBandwidth = sender.value;
    _label8.text = [NSString stringWithFormat:@"%.0f",sender.value];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"filterBandwidth"];
}
- (IBAction)valueChanged9:(UISlider *)sender{
    reverbFilter_.filterGain = sender.value;
    _label9.text = [NSString stringWithFormat:@"%.0f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"filterGain"];
}

- (IBAction)valueChanged10:(UISlider *)sender{
    dynamicsProcessorFilter_.threshold= sender.value;
    _label10.text = [NSString stringWithFormat:@"%.2f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"threshold"];
}

- (IBAction)valueChanged11:(UISlider *)sender{
    dynamicsProcessorFilter_.headRoom = sender.value;
    _label11.text = [NSString stringWithFormat:@"%.2f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"headRoom"];
}

- (IBAction)valueChanged12:(UISlider *)sender{
    dynamicsProcessorFilter_.expansionRatio = sender.value;
    _label12.text = [NSString stringWithFormat:@"%.2f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"expansionRatio"];
}
- (IBAction)valueChanged13:(UISlider *)sender{
    dynamicsProcessorFilter_.attackTime = sender.value;
    _label13.text = [NSString stringWithFormat:@"%.3f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"attackTime"];
}

- (IBAction)valueChanged14:(UISlider *)sender{
    dynamicsProcessorFilter_.releaseTime = sender.value;
    _label14.text = [NSString stringWithFormat:@"%.3f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"releaseTime"];
}

- (IBAction)valueChanged15:(UISlider *)sender{
    dynamicsProcessorFilter_.masterGain = sender.value;
    _label15.text = [NSString stringWithFormat:@"%f",sender.value];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:sender.value] forKey:@"masterGain"];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
