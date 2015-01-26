//
//  Trophy.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Trophy.h"

@implementation Trophy


-(id)initWithTrophyID:(NSInteger)trophyID
{
    self = [super init];
    if (self) {
        _trophyID = trophyID;
        _name = @"";
        _order = 0;
        _achieved = NO;
        return self;
    }
    return nil;
}


@end
