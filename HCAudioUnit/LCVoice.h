//
//  LCVoice.h
//  LCVoiceHud
//
//  Created by 郭历成 on 13-6-21.
//  Contact titm@tom.com
//  Copyright (c) 2013年 Wuxiantai Developer Team.(http://www.wuxiantai.com) All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCVoice;

@protocol LCVoiceDelegate <NSObject>
- (void)LCVoice:(LCVoice*)lcVoice updateMeters:(double)meters;
- (void)LCVoice:(LCVoice *)lcVoice showHideMeters:(BOOL)show;
- (void)LCVoice:(LCVoice *)lcVoice error:(NSError *)error;
@end

@interface LCVoice : NSObject
{
    NSString * orgCategory_;
}
@property (nonatomic,weak) id<LCVoiceDelegate> delegate;
@property(nonatomic,strong) NSString * recordPath;
@property(nonatomic) float recordTime;

-(void) startRecordWithPath:(NSString *)path;
-(void) stopRecordWithCompletionBlock:(void (^)())completion;
-(void) cancelled;
- (void)readyToRelease;
@end
