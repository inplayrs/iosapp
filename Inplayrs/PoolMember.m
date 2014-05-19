//
//  PoolMember.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "PoolMember.h"

@implementation PoolMember


-(id)initWithUsername:(NSString *)username rank:(NSInteger)rank winnings:(NSString *)winnings facebookID:(NSString *)facebookID
{
    self = [super init];
    if (self) {
        _username = username;
        _rank = rank;
        _winnings = winnings;
        _facebookID = facebookID;
        return self;
    }
    return nil;
}


@end
