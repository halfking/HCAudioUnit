//
//  AudioHelper.h
//  maiba
//
//  Created by HUANGXUTAO on 15/9/16.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioHelper : NSObject 


+ (BOOL)hasMicphone;
+ (BOOL)hasHeadset;

+ (NSError *)setCategoryForRecording;

+ (void)pushCurrentAudioState;
+ (NSError *)popAndRestoreToLastAudioState;
+ (void)saveCurrentAudioState;
+ (NSError *)restoreToLastAudioState;

@end