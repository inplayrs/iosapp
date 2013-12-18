//
//  GameWinners.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "GameWinners.h"

@implementation GameWinners


-(id)initWithGameID:(NSInteger)gameID name:(NSString *)name endDate:(NSString *)endDate category:(NSInteger)category
{
    self = [super init];
    if (self) {
        _gameID = gameID;
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

- (NSComparisonResult) compareWithDate:(GameWinners*) anotherGameWinner
{
    return [[anotherGameWinner endDate] compare:[self endDate]];
}

@end
