//
//  FriendPool.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "FriendPool.h"

@implementation FriendPool


-(id)initWithPoolID:(NSInteger)poolID name:(NSString *)name numPlayers:(NSString *)numPlayers
{
    self = [super init];
    if (self) {
        _poolID = poolID;
        _name = name;
        _numPlayers = numPlayers;
        return self;
    }
    return nil;
}

- (NSComparisonResult) compareWithName:(FriendPool*) anotherFriendPool
{
    return [[self name] compare:[anotherFriendPool name]];
}


@end
