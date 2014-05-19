//
//  OverallWinners.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "OverallWinners.h"

@implementation OverallWinners


-(id)initWithUsername:(NSString *)username rank:(NSInteger)rank winnings:(NSString *)winnings fbID:(NSString *)fbID
{
    self = [super init];
    if (self) {
        _username = username;
        _rank = rank;
        _winnings = winnings;
        _fbID = fbID;
        return self;
    }
    return nil;
}


@end
