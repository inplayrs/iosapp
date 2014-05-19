//
//  LeaderboardDataController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Leaderboard;
@class Points;
@class CompetitionPoints;
@class PoolPoints;
@interface LeaderboardDataController : NSObject

@property (nonatomic, copy) NSMutableArray *globalGameLeaderboard;
@property (nonatomic, copy) NSMutableArray *fangroupGameLeaderboard;
@property (nonatomic, copy) NSMutableArray *userinfangroupGameLeaderboard;
@property (nonatomic, copy) NSMutableArray *globalCompetitionLeaderboard;
@property (nonatomic, copy) NSMutableArray *fangroupCompetitionLeaderboard;
@property (nonatomic, copy) NSMutableArray *userinfangroupCompetitionLeaderboard;
@property (nonatomic, copy) NSMutableArray *competitionList;
@property (nonatomic, copy) NSMutableArray *gameList;
@property (nonatomic, copy) Points *gamePoints;
@property (nonatomic, copy) CompetitionPoints *competitionPoints;
@property (nonatomic, copy) PoolPoints *poolGamePoints;
@property (nonatomic, copy) PoolPoints *poolCompetitionPoints;


@end
