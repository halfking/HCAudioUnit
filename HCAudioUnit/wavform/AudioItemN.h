//
//  voiceItem.h
//  maiba
//
//  Created by HUANGXUTAO on 15/8/19.
//  Copyright (c) 2015年 seenvoice.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <hccoren/base.h>


@interface AudioItemN : HCEntity
{
    NSString * filePath_;
}
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,PP_STRONG) NSString * fileName;
@property (nonatomic,PP_STRONG) NSURL * url;
@property (nonatomic,assign) CGFloat secondsDuration;
@property (nonatomic,assign) CGFloat secondsInArray;
@property (nonatomic,assign) CGFloat secondsBegin;
@property (nonatomic,assign) CGFloat secondsEnd;
@property (nonatomic,assign,readonly) CGFloat secondsDurationInArray;
@property (nonatomic,assign) CGFloat averageVolume;
@property (nonatomic,PP_STRONG) NSData * samplesForPixel;
- (NSString *) filePath;
@end
