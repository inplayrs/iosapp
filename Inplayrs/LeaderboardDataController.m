//
//  LeaderboardDataController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "LeaderboardDataController.h"
#import "Leaderboard.h"
#import "Points.h"
#import "CompetitionPoints.h"
#import "PoolPoints.h"


@interface LeaderboardDataController ()
- (void)initializeDefaultDataList;
@end

@implementation LeaderboardDataController


- (void)initializeDefaultDataList {
    NSMutableArray *globalGameLeaderboard = [[NSMutableArray alloc] init];
    NSMutableArray *fangroupGameLeaderboard = [[NSMutableArray alloc] init];
    NSMutableArray *userinfangroupGameLeaderboard = [[NSMutableArray alloc] init];
    self.globalGameLeaderboard = globalGameLeaderboard;
    self.fangroupGameLeaderboard = fangroupGameLeaderboard;
    self.userinfangroupGameLeaderboard = userinfangroupGameLeaderboard;
    
    NSMutableArray *globalCompetitionLeaderboard = [[NSMutableArray alloc] init];
    NSMutableArray *fangroupCompetitionLeaderboard = [[NSMutableArray alloc] init];
    NSMutableArray *userinfangroupCompetitionLeaderboard = [[NSMutableArray alloc] init];
    self.globalCompetitionLeaderboard = globalCompetitionLeaderboard;
    self.fangroupCompetitionLeaderboard = fangroupCompetitionLeaderboard;
    self.userinfangroupCompetitionLeaderboard = userinfangroupCompetitionLeaderboard;
    
    NSMutableArray *competitionList = [[NSMutableArray alloc] init];
    NSMutableArray *gameList = [[NSMutableArray alloc] init];
    self.competitionList = competitionList;
    self.gameList = gameList;
    
    Points *gamePoints;
    self.gamePoints = gamePoints;
    CompetitionPoints *competitionPoints;
    self.competitionPoints = competitionPoints;
    PoolPoints *poolGamePoints;
    self.poolGamePoints = poolGamePoints;
    PoolPoints *poolCompetitionPoints;
    self.poolCompetitionPoints = poolCompetitionPoints;
   
}


- (void)setGlobalGameLeaderboard:(NSMutableArray *)newList {
    if (_globalGameLeaderboard != newList) {
        _globalGameLeaderboard = [newList mutableCopy];
    }
}

- (void)setFangroupGameLeaderboard:(NSMutableArray *)newList {
    if (_fangroupGameLeaderboard != newList) {
        _fangroupGameLeaderboard = [newList mutableCopy];
    }
}

- (void)setUserinfangroupGameLeaderboard:(NSMutableArray *)newList {
    if (_userinfangroupGameLeaderboard != newList) {
        _userinfangroupGameLeaderboard = [newList mutableCopy];
    }
}

- (void)setGlobalCompetitionLeaderboard:(NSMutableArray *)newList {
    if (_globalCompetitionLeaderboard != newList) {
        _globalCompetitionLeaderboard = [newList mutableCopy];
    }
}

- (void)setFangroupCompetitionLeaderboard:(NSMutableArray *)newList {
    if (_fangroupCompetitionLeaderboard != newList) {
        _fangroupCompetitionLeaderboard = [newList mutableCopy];
    }
}

- (void)setUserinfangroupCompetitionLeaderboard:(NSMutableArray *)newList {
    if (_userinfangroupCompetitionLeaderboard != newList) {
        _userinfangroupCompetitionLeaderboard = [newList mutableCopy];
    }
}

- (void)setGamePoints:(Points *)newPoints {
    if (_gamePoints != newPoints) {
        _gamePoints = newPoints;
    }
}

- (void)setCompetitionPoints:(CompetitionPoints *)newPoints {
    if (_competitionPoints != newPoints) {
        _competitionPoints = newPoints;
    }
}

- (void)setPoolGamePoints:(PoolPoints *)newPoints {
    if (_poolGamePoints != newPoints) {
        _poolGamePoints = newPoints;
    }
}

- (void)setPoolCompetitionPoints:(PoolPoints *)newPoints {
    if (_poolCompetitionPoints != newPoints) {
        _poolCompetitionPoints = newPoints;
    }
}

- (void)setCompetitionList:(NSMutableArray *)newList {
    if (_competitionList != newList) {
        _competitionList = [newList mutableCopy];
    }
}

- (void)setGameList:(NSMutableArray *)newList {
    if (_gameList != newList) {
        _gameList = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}


@end
