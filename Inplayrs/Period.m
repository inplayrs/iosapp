//
//  Period.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "Period.h"

@implementation Period


-(id)initWithPeriodID:(NSInteger)periodID name:(NSString *)name state:(NSInteger)state gameState:(NSInteger)gameState startDate:(NSString *)startDate elapsedTime:(NSString *)elapsedTime score:(NSString *)score points0:(NSString *)points0 points1:(NSString *)points1 points2:(NSString *)points2 result:(NSInteger)result
{
    self = [super init];
    if (self) {
        _periodID = periodID;
        _name = name;
        _state = state;
        _gameState = gameState;
        _startDate = startDate;
        _elapsedTime = elapsedTime;
        _score = score;
        _points0 = points0;
        _points1 = points1;
        _points2 = points2;
        _result = result;
        return self;
    }
    return nil;
}

- (NSComparisonResult) compareWithPeriod:(Period*) anotherPeriod
{
    return [[self startDate] compare:[anotherPeriod startDate]];
}


@end
