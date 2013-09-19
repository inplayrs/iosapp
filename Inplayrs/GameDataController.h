//
//  GameDataController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Period;
@class Selection;
@class Points;
@interface GameDataController : NSObject

@property (nonatomic, copy) NSMutableArray *periodList;
@property (nonatomic, copy) NSMutableArray *selectionList;
@property (nonatomic, copy) Points *points;
@property (nonatomic) NSInteger userState;

- (NSUInteger)countOfPeriodList;
- (Period *)objectInPeriodListAtIndex:(NSUInteger)theIndex;
- (void)addGameWithPeriod:(Period *)period;

- (NSUInteger)countOfSelectionList;
- (Selection *)objectInSelectionListAtIndex:(NSUInteger)theIndex;
- (void)addGameWithSelection:(Selection *)selection;


@end
