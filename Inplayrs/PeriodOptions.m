//
//  PeriodOptions.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "PeriodOptions.h"

@implementation PeriodOptions


-(id)initWithPeriodOptionID:(NSInteger)periodOptionID
{
    self = [super init];
    if (self) {
        _periodOptionID = periodOptionID;
        _name = @"0";
        _points = @"0";
        _result = 0;
        _row = -1;

        return self;
    }
    return nil;
}



@end
