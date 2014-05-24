//
//  GameWinners.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameWinners : NSObject


@property (nonatomic) NSInteger gameID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic) NSInteger category;
@property (nonatomic, copy) NSMutableArray *winners;
@property (nonatomic) NSInteger competitionID;
@property (nonatomic) NSInteger inplayType;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger state;


-(id)initWithGameID:(NSInteger)gameID name:(NSString *)name endDate:(NSString *)endDate category:(NSInteger)category competitionID:(NSInteger)competitionID inplayType:(NSInteger)inplayType type:(NSInteger)type state:(NSInteger)state;

- (NSComparisonResult) compareWithDate:(GameWinners*) anotherGameWinner;

@end
