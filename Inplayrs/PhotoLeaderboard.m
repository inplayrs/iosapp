//
//  PhotoLeaderboard.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "PhotoLeaderboard.h"

@implementation PhotoLeaderboard


-(id)initWithRank:(NSInteger)rank name:(NSString *)name fbID:(NSString *)fbID photoID:(NSInteger)photoID likes:(NSInteger)likes url:(NSURL *)url caption:(NSString *)caption winnings:(NSInteger)winnings;
{
    self = [super init];
    if (self) {
        _rank = rank;
        _name = name;
        _fbID = fbID;
        _photoID = photoID;
        _likes = likes;
        _url = url;
        _caption = caption;
        _winnings = winnings;
        return self;
    }
    return nil;
}


@end
