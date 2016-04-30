//
//  AudioHelper.m
//  maiba
//
//  Created by HUANGXUTAO on 15/9/16.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import "AudioHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <hccoren/base.h>

@interface AudioHelper()

@end

@implementation AudioHelper
static NSMutableArray *savedAVAudioCategories_;
static NSMutableArray *savedAVAudioCategoryOptions_;
static NSString *savedAVAudioCategory_;
static AVAudioSessionCategoryOptions savedAVAudioCategoryOption_;

+ (BOOL)hasMicphone {
    return [AVAudioSession sharedInstance].inputAvailable;
}

+ (BOOL)hasHeadset {
#if TARGET_IPHONE_SIMULATOR
//Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString *)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}

+ (void)setPreferredLatency:(NSTimeInterval)preferredLatency
{
    NSError *error = nil;
    if(![[AVAudioSession sharedInstance] setPreferredIOBufferDuration:preferredLatency error:&error])
        NSLog(@"Error when setting preferred I/O buffer duration");
}

+ (NSError *)setCategoryForRecording {
    NSError *error;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:&error];
    return error;
}

+ (void)pushCurrentAudioState
{
    if (!savedAVAudioCategoryOptions_) {
        savedAVAudioCategoryOptions_ = [NSMutableArray new];
    }
    if (!savedAVAudioCategories_) {
        savedAVAudioCategories_ = [NSMutableArray new];
    }
    [savedAVAudioCategories_ addObject:[AVAudioSession sharedInstance].category];
    [savedAVAudioCategoryOptions_ addObject:[NSNumber numberWithInt:[AVAudioSession sharedInstance].categoryOptions]];
}

+ (NSError *)popAndRestoreToLastAudioState
{
    NSError *error;
    if (!savedAVAudioCategories_.count) {
        return [NSError new];
    }
    NSUInteger index = savedAVAudioCategories_.count-1;
    NSNumber *option = [savedAVAudioCategoryOptions_ objectAtIndex:index];
    [[AVAudioSession sharedInstance] setCategory:[savedAVAudioCategories_ objectAtIndex:index]
                                     withOptions:[option intValue]
                                           error:&error];
    return error;
}

+ (void)saveCurrentAudioState;
{
    savedAVAudioCategory_ = [[AVAudioSession sharedInstance].category copy];
    savedAVAudioCategoryOption_ = [AVAudioSession sharedInstance].categoryOptions;
}

+ (NSError *)restoreToLastAudioState
{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:savedAVAudioCategory_ withOptions:savedAVAudioCategoryOption_   error:&error];
    return error;
}


@end