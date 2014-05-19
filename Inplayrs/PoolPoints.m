//
//  PoolPoints.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "PoolPoints.h"

@implementation PoolPoints


-(id)initWithRank:(NSString *)poolRank points:(NSString *)points poolSize:(NSString *)poolSize poolPotSize:(NSString *)poolPotSize poolWinnings:(NSString *)poolWinnings totalPoolWinnings:(NSString *)totalPoolWinnings
{
    self = [super init];
    if (self) {
        _points = points;
        _poolRank = poolRank;
        _poolSize = poolSize;
        _poolPotSize = poolPotSize;
        _poolWinnings = poolWinnings;
        _totalPoolWinnings = totalPoolWinnings;
        return self;
    }
    return nil;
}


@end
