//
//  Game.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Game.h"

@implementation Game


-(id)initWithGameID:(NSInteger)gameID name:(NSString *)name startDate:(NSString *)startDate state:(NSInteger)state category:(NSInteger)category type:(NSInteger)type entered:(BOOL)entered inplayType:(NSInteger)inplayType competitionID:(NSInteger)competitionID
{
    self = [super init];
    if (self) {
        _gameID = gameID;
        _name = name;
        _startDate = startDate;
        _state = state;
        _category = category;
        _type = type;
        _entered = entered;
        _competitionID = competitionID;
        _competitionName = @"";
        _inplayType = inplayType;
        return self;
    }
    return nil;
}

- (NSComparisonResult) compareWithGame:(Game*) anotherGame
{
     return [[self startDate] compare:[anotherGame startDate]];
}

- (NSComparisonResult) compareWithName:(Game*) anotherGame
{
    return [[self name] compare:[anotherGame name]];
}

- (NSComparisonResult) compareWithGameReverse:(Game*) anotherGame
{
    return [[anotherGame startDate] compare:[self startDate]];
}

@end
