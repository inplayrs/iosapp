//
//  Banner.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Banner.h"

@implementation Banner


-(id)initWithPosition:(NSInteger)bannerPosition bannerImageURL:(NSURL *)bannerImageURL game:(Game *)game
{
    self = [super init];
    if (self) {
        _bannerPosition = bannerPosition;
        _bannerImageURL = bannerImageURL;
        _game = game;
        return self;
    }
    return nil;
}


@end
