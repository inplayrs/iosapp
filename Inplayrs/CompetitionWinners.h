//
//  CompetitionWinners.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompetitionWinners : NSObject


@property (nonatomic) NSInteger competitionID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic) NSInteger category;
@property (nonatomic, copy) NSMutableArray *winners;


-(id)initWithCompetitionID:(NSInteger)competitionID name:(NSString *)name endDate:(NSString *)endDate category:(NSInteger)category;

- (NSComparisonResult) compareWithDate:(CompetitionWinners*) anotherCompetitionWinner;

@end
