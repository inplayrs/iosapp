//
//  CompetitionPoints.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "CompetitionPoints.h"

@implementation CompetitionPoints


-(id)initWithPoints:(NSString *)globalRank globalWinnings:(NSString *)globalWinnings fangroupName:(NSString *)fangroupName fangroupRank:(NSString *)fangroupRank fangroupWinnings:(NSString *)fangroupWinnings userinfangroupRank:(NSString *)userinfangroupRank globalPoolSize:(NSString *)globalPoolSize numFangroups:(NSString *)numFangroups fangroupPoolSize:(NSString *)fangroupPoolSize totalGlobalWinnings:(NSString *)totalGlobalWinnings totalFangroupWinnings:(NSString *)totalFangroupWinnings totalUserinfangroupWinnings:(NSString *)totalUserinfangroupWinnings
{
    self = [super init];
    if (self) {
        _globalRank = globalRank;
        _globalWinnings = globalWinnings;
        _fangroupName = fangroupName;
        _fangroupRank = fangroupRank;
        _fangroupWinnings = fangroupWinnings;
        _userinfangroupRank = userinfangroupRank;
        _globalPoolSize = globalPoolSize;
        _numFangroups = numFangroups;
        _fangroupPoolSize = fangroupPoolSize;
        _totalGlobalWinnings = totalGlobalWinnings;
        _totalFangroupWinnings = totalFangroupWinnings;
        _totalUserinfangroupWinnings = totalUserinfangroupWinnings;
        return self;
    }
    return nil;
}


@end
