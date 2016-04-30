//
//  reverbViewController.h
//  maiba
//
//  Created by WangSiyu on 15/10/28.
//  Copyright © 2015年 seenvoice.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <hccoren/base.h>

#import "AEReverbFilter.h"
#import "AEDelayFilter.h"
#import "AEPlaythroughChannel.h"
#import "AEDynamicsProcessorFilter.h"

@interface reverbViewController : UIViewController

//+ (instancetype)sharereverbViewController;

@property (nonatomic) IBOutlet UILabel* label0;
@property (nonatomic) IBOutlet UILabel* label1;
@property (nonatomic) IBOutlet UILabel* label2;
@property (nonatomic) IBOutlet UILabel* label3;
@property (nonatomic) IBOutlet UILabel* label4;
@property (nonatomic) IBOutlet UILabel* label5;
@property (nonatomic) IBOutlet UILabel* label6;
@property (nonatomic) IBOutlet UILabel* label7;
@property (nonatomic) IBOutlet UILabel* label8;
@property (nonatomic) IBOutlet UILabel* label9;
@property (nonatomic) IBOutlet UILabel* label10;
@property (nonatomic) IBOutlet UILabel* label11;
@property (nonatomic) IBOutlet UILabel* label12;
@property (nonatomic) IBOutlet UILabel* label13;
@property (nonatomic) IBOutlet UILabel* label14;
@property (nonatomic) IBOutlet UILabel* label15;

@property(weak, nonatomic) IBOutlet UISlider *slider0;
@property(weak, nonatomic) IBOutlet UISlider *slider1;
@property(weak, nonatomic) IBOutlet UISlider *slider2;
@property(weak, nonatomic) IBOutlet UISlider *slider3;
@property(weak, nonatomic) IBOutlet UISlider *slider4;
@property(weak, nonatomic) IBOutlet UISlider *slider5;
@property(weak, nonatomic) IBOutlet UISlider *slider6;
@property(weak, nonatomic) IBOutlet UISlider *slider7;
@property(weak, nonatomic) IBOutlet UISlider *slider8;
@property(weak, nonatomic) IBOutlet UISlider *slider9;
@property(weak, nonatomic) IBOutlet UISlider *slider10;
@property(weak, nonatomic) IBOutlet UISlider *slider11;
@property(weak, nonatomic) IBOutlet UISlider *slider12;
@property(weak, nonatomic) IBOutlet UISlider *slider13;
@property(weak, nonatomic) IBOutlet UISlider *slider14;
@property(weak, nonatomic) IBOutlet UISlider *slider15;

@property (nonatomic,PP_STRONG) AEReverbFilter * reverbFilter;
@property (nonatomic,PP_STRONG) AEDynamicsProcessorFilter * dynamicProcessorFilter;
@end