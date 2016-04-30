//
//  AudioCenterNew(offline).h
//  maiba
//
//  Created by HUANGXUTAO on 16/3/1.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCenterNew.h"

@interface AudioCenterNew(offline)
- (BOOL)writeFile:(NSString *)sourcePath targetFile:(NSString *)filePath
        controller:(AEAudioController *)audioController
           options:(NSArray *)options;

- (BOOL)writeFiles:(NSArray *)urlsWithSettings controller:(AEAudioController *)audioController options:(NSArray *)options targetFile:(NSString *)targetPath;
- (BOOL)writeFilesNew:(NSArray *)urlsWithSettings controller:(AEAudioController *)audioController options:(NSArray *)options targetFile:(NSString *)targetPath;
//return audioeffectitem
- (NSArray *)getFilterModules:(int)type; //0是变声 1是混响
- (NSArray *)getFiltersForMode:(int)modelID revertID:(int)revertID;
@end
