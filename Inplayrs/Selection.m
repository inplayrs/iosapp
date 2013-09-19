//
//  Selection.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Selection.h"

@implementation Selection


-(id)initWithPeriodID:(NSInteger)periodID
{
    self = [super init];
    if (self) {
        _periodID = periodID;
        _selection = -1;
        _awardedPoints = @"0";
        _potentialPoints = @"0";
        _bank = NO;
        _row = -1;

        return self;
    }
    return nil;
}



@end
