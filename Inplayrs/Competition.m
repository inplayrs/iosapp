//
//  Competition.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Competition.h"

@implementation Competition


-(id)initWithCompetitionID:(NSInteger)competitionID name:(NSString *)name startDate:(NSString *)startDate state:(NSInteger)state category:(NSInteger)category entered:(BOOL)entered
{
    self = [super init];
    if (self) {
        _competitionID = competitionID;
        _name = name;
        _startDate = startDate;
        _state = state;
        _category = category;
        _entered = entered;
        return self;
    }
    return nil;
}

- (NSComparisonResult) compareWithName:(Competition*) anotherCompetition
{
    return [[self name] compare:[anotherCompetition name]];
}

- (NSComparisonResult) compareWithDate:(Competition*) anotherCompetition
{
    return [[self startDate] compare:[anotherCompetition startDate]];
}

@end
