//
//  AudioCenterNew(offline).m
//  maiba
//
//  Created by HUANGXUTAO on 16/3/1.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "AudioCenterNew(offline).h"
#import <hccoren/base.h>

#import "AEAudioController.h"
#import "AEAudioController(offline).h"
#import "AudioEffectItem.h"
#import "AudioCenterNew(soundtouch).h"

#import "AENewTimePitchFilter.h"
#import "AEDelayFilter.h"
#import "AEReverbFilter.h"
#import "AEDynamicsProcessorFilter.h"

@implementation AudioCenterNew(offline)
#pragma mark -
//利用AEAudioController来完成音效的写入文件工作，现在暂时有BUG
- (BOOL)writeFile:(NSString *)sourcePath targetFile:(NSString *)filePath
       controller:(AEAudioController *)audioController
          options:(NSArray *)options
//写音频文件
{
    if(!sourcePath||sourcePath.length==0) return NO;
    
    return [self writeFiles:@[@{@"url":[NSURL fileURLWithPath:sourcePath],
                                @"start":@(0),
                                @"vol":@(1),
                                @"duration":@(-1)
                                }] controller:audioController options:options targetFile:filePath];
//    //    [self play];
//    
//    //    [audioController stop];
//    
//    // clear the mSoundBuffer struct
//    //    memset(&mUserData.soundBuffer, 0, sizeof(mUserData.soundBuffer));
//    
//    if(!audioController)
//    {
//        audioController = [self getCurrentAudioController];
//        if(!audioController)
//        {
//            //            NSLog(@"audiocontroller is null.");
//            return NO;
//        }
//        [self resetAudioController:audioController];
//    }
//    else
//    {
//        [self resetAudioController:audioController];
//    }
//    if(options)
//    {
//        for (AEAudioUnitFilter * filter in options) {
//            if(![audioController.filters containsObject:filter])
//            {
//                if([filter isKindOfClass:[AEAudioUnitFilter class]] )
//                {
//                    [audioController addFilter:filter];
//                }
//            }
//        }
//    }
//    //    [audioController  setInputEnabled:NO error:nil];
//    return [audioController renderOffline:sourcePath targetFile:filePath];
//    //    return [audioController startWithFiles:@[sourcePath] targetFile:filePath options:options];
//    //    return YES;
}
- (BOOL)writeFiles:(NSArray *)urlsWithSettings controller:(AEAudioController *)audioController options:(NSArray *)options targetFile:(NSString *)targetPath
{
    return [self writeFilesNew:urlsWithSettings controller:audioController options:options targetFile:targetPath];
    /*
    if(!audioController)
    {
        audioController = [self getCurrentAudioController];
        if(!audioController)
        {
            //            NSLog(@"audiocontroller is null.");
            return NO;
        }
        [self resetAudioController:audioController];
    }
    else
    {
        [self resetAudioController:audioController];
    }
    if(options)
    {
        for (AEAudioUnitFilter * filter in options) {
            if(![audioController.filters containsObject:filter])
            {
                if([filter isKindOfClass:[AEAudioUnitFilter class]] )
                {
                    [audioController addFilter:filter];
                }
            }
        }
    }
    NSTimeInterval duration = 0;
    NSArray * channels = [self getChannelsForUrls:urlsWithSettings longestPlayer:nil duration:&duration];
    BOOL ret = [audioController renderOffline:channels duration:duration targetFile:targetPath];
    for (AEAudioUnitChannel * item in channels) {
        [item teardown];
    }
    channels = nil;
    
    return ret;*/
}
- (BOOL)writeFilesNew:(NSArray *)urlsWithSettings controller:(AEAudioController *)audioController options:(NSArray *)options targetFile:(NSString *)targetPath
{
//    NSMutableArray * optionsNew = [NSMutableArray new];
    
    if(!audioController)
    {
        audioController = [self getCurrentAudioController];
        if(!audioController)
        {
            //            NSLog(@"audiocontroller is null.");
            return NO;
        }
        [self resetAudioController:audioController];
    }
    else
    {
        [self resetAudioController:audioController];
    }
    if(options)
    {
        for (AEAudioUnitFilter * filter in options) {
            if(![audioController.filters containsObject:filter])
            {
                if([filter isKindOfClass:[AEAudioUnitFilter class]] )
                {
                    [audioController addFilter:filter];
                }
            }
        }
    }
    NSTimeInterval duration = 0;
    NSArray * channels = [self getChannelsForUrls:urlsWithSettings longestPlayer:nil duration:&duration];
    BOOL ret = [audioController renderOffline:channels duration:duration targetFile:targetPath];
    for (AEAudioUnitChannel * item in channels) {
        [item teardown];
    }
    channels = nil;
    
    return ret;
}
#pragma mark EQ音效
//// 创建10个AEParametricEqFilter对象
//- (void)creatEqFliters {
//    _eq20HzFilter  = [[AEParametricEqFilter alloc] init];
//    _eq50HzFilter  = [[AEParametricEqFilter alloc] init];
//    _eq100HzFilter = [[AEParametricEqFilter alloc] init];
//    _eq200HzFilter = [[AEParametricEqFilter alloc] init];
//    _eq500HzFilter = [[AEParametricEqFilter alloc] init];
//    _eq1kFilter    = [[AEParametricEqFilter alloc] init];
//    _eq2kFilter    = [[AEParametricEqFilter alloc] init];
//    _eq5kFilter    = [[AEParametricEqFilter alloc] init];
//    _eq10kFilter   = [[AEParametricEqFilter alloc] init];
//    _eq20kFilter   = [[AEParametricEqFilter alloc] init];
//    _eqFilters     = @[_eq20HzFilter, _eq50HzFilter, _eq100HzFilter, _eq200HzFilter, _eq500HzFilter, _eq1kFilter, _eq2kFilter, _eq5kFilter, _eq10kFilter, _eq20kFilter];
//}
//
//- (void)setupFilterEq:(NSInteger)eqType value:(double)gain {
//    switch (eqType) {
//        case EQ_20Hz: {
//            // 设置需要调整的频率，并将传入的增益值gain赋值给gain属性，达到音效调整效果
//            [self setupEqFilter:_eq20HzFilter centerFrequency:20 gain:gain];
//            break;
//        }
//        case EQ_50Hz: {
//            [self setupEqFilter:_eq50HzFilter centerFrequency:50 gain:gain];
//            break;
//        }
//        case EQ_100Hz: {
//            [self setupEqFilter:_eq100HzFilter centerFrequency:100 gain:gain];
//            break;
//        }
//        case EQ_200Hz: {
//            [self setupEqFilter:_eq200HzFilter centerFrequency:200 gain:gain];
//            break;
//        }
//        case EQ_500Hz: {
//            [self setupEqFilter:_eq500HzFilter centerFrequency:500 gain:gain];
//            break;
//        }
//        case EQ_1K: {
//            [self setupEqFilter:_eq1kFilter centerFrequency:1000 gain:gain];
//            break;
//        }
//        case EQ_2K: {
//            [self setupEqFilter:_eq2kFilter centerFrequency:2000 gain:gain];
//            break;
//        }
//        case EQ_5K: {
//            [self setupEqFilter:_eq5kFilter centerFrequency:5000 gain:gain];
//            break;
//        }
//        case EQ_10K: {
//            [self setupEqFilter:_eq10kFilter centerFrequency:10000 gain:gain];
//            break;
//        }
//        case EQ_20K: {
//            [self setupEqFilter:_eq20kFilter centerFrequency:20000 gain:gain];
//            break;
//        }
//    }
//}
//
//- (void)setupEqFilter:(AEParametricEqFilter *)eqFilter centerFrequency:(double)centerFrequency gain:(double)gain {
//    if ( ![_audioController.filters containsObject:eqFilter] ) {
//        for (AEParametricEqFilter *existEqFilter in _eqFilters) {
//            if (eqFilter == existEqFilter) {
//                [_audioController addFilter:eqFilter];
//                break;
//            }
//        }
//    }
//
//    eqFilter.centerFrequency = centerFrequency;
//    eqFilter.qFactor         = 1.0;
//    eqFilter.gain            = gain;
//}
#pragma mark - get modles
- (NSArray *)getFilterModules:(int)type //0是变声 1是混响
{
    if(type==0)
    {
        if(!effectFiltersForType0_)
        {
            //            青春
            //            沧桑
            //            小黄人
            //            汤姆猫
            //            魔王
            //            回声
            
            NSMutableArray * models = [NSMutableArray new];
            
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 1;
                item.EffectName = @"沧桑";
                item.EffectLogo = @"ponticello_1.png";
                item.EffectLogoHover = @"ponticello_1_selected.png";
                AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
                picker.pitch = -180;
                picker.rate = 0.8;
                
                [item setEffectFiters:@[picker]];
                
                [models addObject:item];
            }
            
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 2;
                item.EffectName = @"青春";
                item.EffectLogo = @"ponticello_2.png";
                item.EffectLogoHover = @"ponticello_2_selected.png";
                AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
                picker.pitch = 300;
                picker.rate = 1.2;
                
                [item setEffectFiters:@[picker]];
                
                [models addObject:item];
            }
            //            {
            //                AudioEffectItem * item = [AudioEffectItem new];
            //                item.EffectID = 3;
            //                item.EffectName = @"萝莉";
            //
            //                AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
            //                picker.pitch = 300;
            //                picker.rate = 1;
            //
            //                [item setEffectFiters:@[picker]];
            //
            //                [models addObject:item];
            //            }
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 3;
                item.EffectName = @"小黄人";
                item.EffectLogo = @"ponticello_3.png";
                item.EffectLogoHover = @"ponticello_3_selected.png";
                AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
                picker.pitch = 800;
                picker.rate = 2;
                
                [item setEffectFiters:@[picker]];
                
                [models addObject:item];
            }
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 4;
                item.EffectName = @"汤姆猫";
                item.EffectLogo = @"ponticello_4.png";
                item.EffectLogoHover = @"ponticello_4_selected.png";
                AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
                picker.pitch = 1000;
                picker.rate = 1.5;
                
                [item setEffectFiters:@[picker]];
                
                [models addObject:item];
            }
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 5;
                item.EffectName = @"魔王";
                item.EffectLogo = @"ponticello_5.png";
                item.EffectLogoHover = @"ponticello_5_selected.png";
                AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
                picker.pitch = -600;
                picker.rate = 0.6;
                
                AEDelayFilter * delayer = [AEDelayFilter new];
                delayer.delayTime = 0.4;
                delayer.wetDryMix = 1.0;
                
                [item setEffectFiters:@[picker,delayer]];
                
                [models addObject:item];
            }
            
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 6;
                item.EffectName = @"回声";
                item.EffectLogo = @"ponticello_6.png";
                item.EffectLogoHover = @"ponticello_6_selecetd.png";
                //        AENewTimePitchFilter * picker = [AENewTimePitchFilter new];
                //        picker.pitch = -600;
                //        picker.rate = 0.8;
                
                AEDelayFilter * delayer = [AEDelayFilter new];
                delayer.delayTime = 0.4;
                delayer.wetDryMix = 1.0;
                
                [item setEffectFiters:@[delayer]];
                
                [models addObject:item];
            }
            
            [models sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                AudioEffectItem * item1 = (AudioEffectItem *)obj1;
                AudioEffectItem * item2 = (AudioEffectItem *)obj2;
                if(item1.EffectID>item2.EffectID)
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return NSOrderedAscending;
                }
            }];
            
            effectFiltersForType0_ = models;
            PP_RELEASE(models);
        }
        return effectFiltersForType0_;
    }
    else
    {
        if(!effectFiltersForType1_)
        {
            //            浴室
            //            KTV
            //            大厅
            //            广场
            NSMutableArray * models = [NSMutableArray new];
            
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 1001;
                item.EffectName = @"浴室";
                item.EffectLogo = @"soundeffect_1.png";
                item.EffectLogoHover = @"soundeffect_1_selected.png";
                AEReverbFilter * revertFilter = [AEReverbFilter new];
                AEDynamicsProcessorFilter * dpFilter = [AEDynamicsProcessorFilter new];
                
                
                revertFilter.dryWetMix = 70;
                revertFilter.gain = 0;
                revertFilter.minDelayTime = 0.008;
                revertFilter.maxDelayTime = 0.01;
                revertFilter.decayTimeAt0Hz = 0.7;
                revertFilter.decayTimeAtNyquist = 0.5;
                revertFilter.randomizeReflections = 1;
                revertFilter.filterFrequency = 1500;
                revertFilter.filterBandwidth = 1;
                revertFilter.filterGain = 0;
                dpFilter.threshold = -20;
                dpFilter.headRoom = 6.95;
                dpFilter.expansionRatio = 2;
                dpFilter.attackTime = 0.001;
                dpFilter.releaseTime = 0.050;
                dpFilter.masterGain = 0.00;
                
                [item setEffectFiters:@[revertFilter,dpFilter]];
                
                [models addObject:item];
            }
            
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 1002;
                item.EffectName = @"KTV";
                item.EffectLogo = @"soundeffect_2.png";
                item.EffectLogoHover = @"soundeffect_2_selected.png";
                
                AEReverbFilter * revertFilter = [AEReverbFilter new];
                AEDynamicsProcessorFilter * dpFilter = [AEDynamicsProcessorFilter new];
                
                
                revertFilter.dryWetMix = 5;
                revertFilter.gain = 0;
                revertFilter.minDelayTime = 0.008;
                revertFilter.maxDelayTime = 0.020;
                revertFilter.decayTimeAt0Hz = 4.30;
                revertFilter.decayTimeAtNyquist = 1.8;
                revertFilter.randomizeReflections = 1;
                revertFilter.filterFrequency = 9000;
                revertFilter.filterBandwidth = 1;
                revertFilter.filterGain = 0;
                dpFilter.threshold = -20.0;
                dpFilter.headRoom = 20;
                dpFilter.expansionRatio = 2;
                dpFilter.attackTime = 0.001;
                dpFilter.releaseTime = 0.050;
                dpFilter.masterGain = 0.00;
                
                [item setEffectFiters:@[revertFilter,dpFilter]];
                
                [models addObject:item];
            }
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 1003;
                item.EffectName = @"大厅";
                item.EffectLogo = @"soundeffect_3.png";
                item.EffectLogoHover = @"soundeffect_3_selected.png";
                
                AEReverbFilter * revertFilter = [AEReverbFilter new];
                AEDynamicsProcessorFilter * dpFilter = [AEDynamicsProcessorFilter new];
                
                
                revertFilter.dryWetMix = 10;
                revertFilter.gain = 0;
                revertFilter.minDelayTime = 0.035;
                revertFilter.maxDelayTime = 0.030;
                revertFilter.decayTimeAt0Hz = 5.0;
                revertFilter.decayTimeAtNyquist = 4.0;
                revertFilter.randomizeReflections = 1;
                revertFilter.filterFrequency = 800;
                revertFilter.filterBandwidth = 3;
                revertFilter.filterGain = 0;
                dpFilter.threshold = -20;
                dpFilter.headRoom = 5;
                dpFilter.expansionRatio = 2;
                dpFilter.attackTime = 0.001;
                dpFilter.releaseTime = 0.050;
                dpFilter.masterGain = 0;
                
                [item setEffectFiters:@[revertFilter,dpFilter]];
                
                [models addObject:item];
            }
            {
                AudioEffectItem * item = [AudioEffectItem new];
                item.EffectID = 1004;
                item.EffectName = @"广场";
                item.EffectLogo = @"soundeffect_4.png";
                item.EffectLogoHover = @"soundeffect_4_selected.png";
                
                AEDelayFilter * delayer = [AEDelayFilter new];
                delayer.delayTime = 0.1;
                delayer.wetDryMix = 1.0;
                
                AEReverbFilter * revertFilter = [AEReverbFilter new];
                AEDynamicsProcessorFilter * dpFilter = [AEDynamicsProcessorFilter new];
                
                
                revertFilter.dryWetMix = 15;
                revertFilter.gain = 0;
                revertFilter.minDelayTime = 0.06;
                revertFilter.maxDelayTime = 0.20;
                revertFilter.decayTimeAt0Hz = 1.4;
                revertFilter.decayTimeAtNyquist = 2.4;
                revertFilter.randomizeReflections = 600;
                revertFilter.filterFrequency = 800;
                revertFilter.filterBandwidth = 2;
                revertFilter.filterGain = 0;
                dpFilter.threshold = -20;
                dpFilter.headRoom = 27;
                dpFilter.expansionRatio = 4.46;
                dpFilter.attackTime = 0.01;
                dpFilter.releaseTime = 0.05;
                dpFilter.masterGain = 0.0;
                
                [item setEffectFiters:@[delayer,revertFilter,dpFilter]];
                
                [models addObject:item];
            }
            
            [models sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                AudioEffectItem * item1 = (AudioEffectItem *)obj1;
                AudioEffectItem * item2 = (AudioEffectItem *)obj2;
                if(item1.EffectID>item2.EffectID)
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return NSOrderedAscending;
                }
            }];
            effectFiltersForType1_ = models;
            PP_RELEASE(models);
        }
        
        return effectFiltersForType1_;
    }
}
- (NSArray *)getFiltersForMode:(int)modelID revertID:(int)revertID
{
    NSMutableArray * result = [NSMutableArray new];
    if(!effectFiltersForType0_)
    {
        [self getFilterModules:0];
    }
    if(!effectFiltersForType1_)
    {
        [self getFilterModules:1];
    }
    AudioEffectItem * result0 = nil;
    AudioEffectItem * result1 = nil;
    if(modelID>0 && modelID <= effectFiltersForType0_.count )
    {
        
        
        for (AudioEffectItem * item in effectFiltersForType0_) {
            if(item.EffectID == modelID)
            {
                result0 = item;
                break;
            }
        }
    }
    if(revertID>1000 && revertID <= 1000+effectFiltersForType1_.count)
    {
        for (AudioEffectItem * item in effectFiltersForType1_) {
            if(item.EffectID == revertID)
            {
                result1 = item;
                break;
            }
        }
    }
    if(result0)
    {
        [result addObjectsFromArray:result0.filters];
    }
    if(result1)
    {
        [result addObjectsFromArray:result1.filters];
    }
    else if(modelID == 5 || modelID==6)
    {
        AEReverbFilter * revertFilter = [AEReverbFilter new];
        AEDynamicsProcessorFilter * dpFilter = [AEDynamicsProcessorFilter new];
        if(modelID==5)
        {
            revertFilter.dryWetMix = 50;
            revertFilter.gain = 0;
            revertFilter.minDelayTime = 0.008;
            revertFilter.maxDelayTime = 0.050;
            revertFilter.decayTimeAt0Hz = 3;
            revertFilter.decayTimeAtNyquist = 1.6;
            revertFilter.randomizeReflections = 1;
            revertFilter.filterFrequency = 800;
            revertFilter.filterBandwidth = 3;
            revertFilter.filterGain = 0;
            dpFilter.threshold = -20;
            dpFilter.headRoom = 5;
            dpFilter.expansionRatio = 2;
            dpFilter.attackTime = 0.001;
            dpFilter.releaseTime = 0.050;
            dpFilter.masterGain = 0.00;
        }
        else
        {
            revertFilter.dryWetMix = 5;
            revertFilter.gain = 0;
            revertFilter.minDelayTime = 0.008;
            revertFilter.maxDelayTime = 0.050;
            revertFilter.decayTimeAt0Hz = 6;
            revertFilter.decayTimeAtNyquist = 6;
            revertFilter.randomizeReflections = 1;
            revertFilter.filterFrequency = 800;
            revertFilter.filterBandwidth = 3;
            revertFilter.filterGain = 0;
            dpFilter.threshold = -20;
            dpFilter.headRoom = 5;
            dpFilter.expansionRatio = 2;
            dpFilter.attackTime = 0.001;
            dpFilter.releaseTime = 0.050;
            dpFilter.masterGain = 0.00;
        }
        [result addObject:revertFilter];
        [result addObject:dpFilter];
    }
    return result;
}
@end
