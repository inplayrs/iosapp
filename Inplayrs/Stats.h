//
//  Stats.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stats : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *totalWinnings;
@property (nonatomic, copy) NSString *totalRank;
@property (nonatomic, copy) NSString *totalUsers;
@property (nonatomic, copy) NSString *totalGames;
@property (nonatomic) float totalCorrect;
@property (nonatomic, copy) NSString *userRating;
@property (nonatomic, copy) NSString *globalWinnings;
@property (nonatomic, copy) NSString *fangroupWinnings;
@property (nonatomic, copy) NSString *h2hWinnings;
@property (nonatomic, copy) NSString *globalWon;
@property (nonatomic, copy) NSString *fangroupWon;
@property (nonatomic, copy) NSString *h2hWon;


-(id)initWithUsername:(NSString *)username;


@end
