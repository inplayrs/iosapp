//
//  Fan.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Fan.h"

@implementation Fan


-(id)initWithCompetitionName:(NSString *)competitionName fangroupName:(NSString *)fangroupName fangroupID:(NSInteger)fangroupID category:(NSInteger)category
{
    self = [super init];
    if (self) {
        _competitionName = competitionName;
        _fangroupName = fangroupName;
        _fangroupID = fangroupID;
        _category = category;
        return self;
    }
    return nil;
}

- (NSComparisonResult) compareWithName:(Fan*) anotherFan
{
    return [[self competitionName] compare:[anotherFan competitionName]];
}

@end
