//
//  AudioEffectItem.h
//  maiba
//
//  Created by HUANGXUTAO on 16/3/7.
//  Copyright © 2016年 seenvoice.com. All rights reserved.
//


#import <hccoren/base.h>
@interface AudioEffectItem : HCEntity
{
    NSMutableArray * filters_;
}
@property (nonatomic,assign) int EffectID;
@property (nonatomic,PP_STRONG) NSString * EffectName;
@property (nonatomic,PP_STRONG) NSString * EffectLogo;
@property (nonatomic,PP_STRONG) NSString * EffectLogoHover;
@property (nonatomic,PP_STRONG) NSString * Syntax;
@property (nonatomic,assign) int Order;
@property (nonatomic,PP_STRONG,getter=get_AudioFilters,readonly) NSArray * filters;
- (void)setEffectFiters:(NSArray *)filters;
@end
