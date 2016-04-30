//
//  AudioEffectItem.m
//  maiba
//
//  Created by HUANGXUTAO on 16/3/7.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//

#import "AudioEffectItem.h"

@implementation AudioEffectItem
@synthesize EffectID,EffectLogo,EffectName,Syntax;
@synthesize EffectLogoHover;
@synthesize Order;
-(id)init
{
    self = [super init];
    if(self)
    {
        self.TableName = @"AudioEffects";
        self.KeyName = @"EffectID";
    }
    return self;
}

-(void)dealloc
{
    PP_RELEASE(EffectName);
    PP_RELEASE(EffectLogo);
    PP_RELEASE(Syntax);
    PP_SUPERDEALLOC;
}
- (NSArray *)get_AudioFilters
{
    if(!filters_)
    {
        
    }
    return filters_;
}
- (void)setEffectFiters:(NSArray *)filters
{
    if(filters)
        filters_ = [NSMutableArray arrayWithArray:filters];
    else
        [filters_ removeAllObjects];
}
@end
