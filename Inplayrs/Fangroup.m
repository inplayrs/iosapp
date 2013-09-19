//
//  Fangroup.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Fangroup.h"

@implementation Fangroup


-(id)initWithFangroupID:(NSInteger)fangroupID name:(NSString *)name
{
    self = [super init];
    if (self) {
        _fangroupID = fangroupID;
        _name = name;
        return self;
    }
    return nil;
}

- (NSComparisonResult) compareWithName:(Fangroup*) anotherFangroup
{
    return [[self name] compare:[anotherFangroup name]];
}


@end
