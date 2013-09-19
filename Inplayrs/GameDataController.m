//
//  GameDataController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "GameDataController.h"
#import "Period.h"
#import "Selection.h"
#import "Points.h"

@interface GameDataController ()
- (void)initializeDefaultDataList;
@end

@implementation GameDataController

@synthesize userState;

- (void)initializeDefaultDataList {
    
    NSMutableArray *periodList = [[NSMutableArray alloc] init];
    self.periodList = periodList;
    
    NSMutableArray *selectionList = [[NSMutableArray alloc] init];
    self.selectionList = selectionList;

    Points *points;
    self.points = points;
    
    userState = -1;
    
}


- (void)setPeriodList:(NSMutableArray *)newList {
    if (_periodList != newList) {
        _periodList = [newList mutableCopy];
    }
}

- (void)setSelectionList:(NSMutableArray *)newList {
    if (_selectionList != newList) {
        _selectionList = [newList mutableCopy];
    }
}

- (void)setPoints:(Points *)newPoints {
    if (_points != newPoints) {
        _points = newPoints;
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

- (NSUInteger)countOfPeriodList {
    return [self.periodList count];
}

- (Period *)objectInPeriodListAtIndex:(NSUInteger)theIndex {
    return [self.periodList objectAtIndex:theIndex];
}

- (void)addGameWithPeriod:(Period *)period {
    [self.periodList addObject:period];
}

- (NSUInteger)countOfSelectionList {
    return [self.selectionList count];
}

- (Selection *)objectInSelectionListAtIndex:(NSUInteger)theIndex {
    return [self.selectionList objectAtIndex:theIndex];
}

- (void)addGameWithSelection:(Selection *)selection {
    [self.selectionList addObject:selection];
}



@end
