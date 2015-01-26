//
//  Leaderboard.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Leaderboard.h"

@implementation Leaderboard


-(id)initWithRank:(NSInteger)rank name:(NSString *)name points:(NSString *)points winnings:(NSString *)winnings
{
    self = [super init];
    if (self) {
        _rank = rank;
        _name = name;
        _points = points;
        _winnings = winnings;
        _fbID = @"0";
        return self;
    }
    return nil;
}

/*
- (NSComparisonResult) compareWithLeaderboard:(Leaderboard *)anotherLeaderboard
{
    return [[self rank] compare:[anotherLeaderboard rank]];
}
 */

@end
