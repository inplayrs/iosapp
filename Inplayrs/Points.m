//
//  Points.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Points.h"

@implementation Points


-(id)initWithPoints:(NSString *)globalPoints globalRank:(NSString *)globalRank globalPot:(NSString *)globalPot fangroupName:(NSString *)fangroupName fangroupRank:(NSString *)fangroupRank fangroupPot:(NSString *)fangroupPot h2hUser:(NSString *)h2hUser h2hPoints:(NSString *)h2hPoints h2hPot:(NSString *)h2hPot h2hFBID:(NSString *)h2hFBID userinfangroupRank:(NSString *)userinfangroupRank winnings:(NSString *)winnings globalWinnings:(NSString *)globalWinnings fangroupWinnings:(NSString *)fangroupWinnings h2hWinnings:(NSString *)h2hWinnings globalPoolSize:(NSString *)globalPoolSize numFangroups:(NSString *)numFangroups fangroupPoolSize:(NSString *)fangroupPoolSize
{
    self = [super init];
    if (self) {
        _globalPoints = globalPoints;
        _globalRank = globalRank;
        _globalPot = globalPot;
        _fangroupName = fangroupName;
        _fangroupRank = fangroupRank;
        _fangroupPot = fangroupPot;
        _h2hUser = h2hUser;
        _h2hPoints = h2hPoints;
        _h2hPot = h2hPot;
        _h2hFBID = h2hFBID;
        _userinfangroupRank = userinfangroupRank;
        _winnings = winnings;
        _globalWinnings = globalWinnings;
        _fangroupWinnings = fangroupWinnings;
        _h2hWinnings = h2hWinnings;
        _globalPoolSize = globalPoolSize;
        _numFangroups = numFangroups;
        _fangroupPoolSize = fangroupPoolSize;
        _lateEntry = NO;
        NSMutableArray *periodSelections = [[NSMutableArray alloc] init];
        self.periodSelections = periodSelections;
        return self;
    }
    return nil;
}


- (void)setPeriodSelections:(NSMutableArray *)newList {
    if (_periodSelections != newList) {
        _periodSelections = [newList mutableCopy];
    }
}

@end
