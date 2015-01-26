//
//  Leaderboard.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Leaderboard : NSObject

@property (nonatomic) NSInteger rank;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *winnings;
@property (nonatomic, copy) NSString *fbID;


-(id)initWithRank:(NSInteger)rank name:(NSString *)name points:(NSString *)points winnings:(NSString *)winnings;

// - (NSComparisonResult) compareWithLeaderboard:(Leaderboard*) anotherLeaderboard;

@end
