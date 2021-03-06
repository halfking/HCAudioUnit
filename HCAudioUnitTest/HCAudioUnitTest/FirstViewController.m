//
//  FirstViewController.m
//  HCAudioUnitTest
//
//  Created by HUANGXUTAO on 16/5/16.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "FirstViewController.h"
#import "AudioBarGraphWaveView.h"
#import "scWaveformView.h"
@interface FirstViewController ()
{
    AudioBarGraphWaveView * barView_;
}
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 50, self.view.frame.size.width - 20, 60)];
    [self.view addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(1000, 60);
    scrollView.backgroundColor = [UIColor grayColor];
    
    barView_ = [[AudioBarGraphWaveView alloc]initWithFrame:CGRectMake(10, 0, 980, 50)];
    [scrollView addSubview:barView_];
//     NSString * filePath2 = [[NSBundle mainBundle]pathForResource:@"黄昏里" ofType:@"mp3"];
    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"北京北京" ofType:@"mp3"];
    [barView_ setSoundURL:[NSURL fileURLWithPath:filePath]];
    
//    AudioBarGraphWaveView * view2 = [[AudioBarGraphWaveView alloc]initWithFrame:CGRectMake(10, 150, self.view.frame.size.width -20, 50)];
//    [self.view addSubview:view2];
//    
//    NSString * filePath2 = [[NSBundle mainBundle]pathForResource:@"黄昏里" ofType:@"mp3"];
//    [barView_ setSoundURL:[NSURL fileURLWithPath:filePath2]];
    
    
    AudioBarGraphWaveView * vv = [[AudioBarGraphWaveView alloc]initWithFrame:CGRectMake(10, 100,  self.view.frame.size.width -20, 50)];
    [self.view addSubview:vv];
    //     NSString * filePath2 = [[NSBundle mainBundle]pathForResource:@"黄昏里" ofType:@"mp3"];
//    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"北京北京" ofType:@"mp3"];
    [vv setSoundURL:[NSURL fileURLWithPath:filePath]];
    
    SCWaveformView * view3 = [[SCWaveformView alloc]initWithFrame:CGRectMake(10, 250, self.view.frame.size.width -20, 50)];
    view3.normalColor = [UIColor blueColor];
    view3.progressColor = [UIColor yellowColor];
    view3.alpha = 0.8;
    view3.backgroundColor = [UIColor clearColor];
    view3.progress = 0;
    view3.asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    [self.view addSubview:view3];
    
    
    AudioBarGraphWaveView * vv2 = [[AudioBarGraphWaveView alloc]initWithFrame:CGRectMake(10, 350,  self.view.frame.size.width -20, 100)];
    [self.view addSubview:vv2];
    vv2.perferWidthPerBar = 6;
    vv2.hasProgress = YES;
    //     NSString * filePath2 = [[NSBundle mainBundle]pathForResource:@"黄昏里" ofType:@"mp3"];
    //    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"北京北京" ofType:@"mp3"];
    [vv2 setSoundURL:[NSURL fileURLWithPath:filePath]];
    
    [vv2 timeChanged:30];
//    NSString * filePath3 = [[NSBundle mainBundle]pathForResource:@"黄昏里" ofType:@"mp3"];
//    [view3 setAudioFileUrl:[NSURL fileURLWithPath:filePath3]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
