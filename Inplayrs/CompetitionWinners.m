//
//  CompetitionWinners.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "CompetitionWinners.h"

@implementation CompetitionWinners


-(id)initWithCompetitionID:(NSInteger)competitionID name:(NSString *)name endDate:(NSString *)endDate category:(NSInteger)category
{
    self = [super init];
    if (self) {
        _competitionID = competitionID;
        _name = name;
        _endDate = endDate;
        _category = category;
        return self;
    }
    return nil;
}

- (void)setWinners:(NSMutableArray *)newList {
    if (_winners != newList) {
        _winners = [newList mutableCopy];
    }
}

- (NSComparisonResult) compareWithDate:(CompetitionWinners*) anotherCompetitionWinner
{
    return [[anotherCompetitionWinner endDate] compare:[self endDate]];
}

@end
