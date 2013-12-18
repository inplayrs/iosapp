//
//  Stats.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Stats.h"

@implementation Stats


-(id)initWithUsername:(NSString *)username
{
    self = [super init];
    if (self) {
        _username = username;
        _totalWinnings = @"";
        _totalRank = @"";
        _totalUsers = @"";
        _totalGames = @"";
        _totalCorrect = @"";
        _userRating = @"";
        _globalWinnings = @"";
        _fangroupWinnings = @"";
        _h2hWinnings = @"";
        _globalWon = @"";
        _fangroupWon = @"";
        _h2hWon = @"";
        return self;
    }
    return nil;
}


@end
