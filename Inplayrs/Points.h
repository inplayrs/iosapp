//
//  Points.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Points : NSObject

@property (nonatomic, copy) NSString *globalPoints;
@property (nonatomic, copy) NSString *globalRank;
@property (nonatomic, copy) NSString *globalPot;
@property (nonatomic, copy) NSString *fangroupName;
@property (nonatomic, copy) NSString *fangroupRank;
@property (nonatomic, copy) NSString *fangroupPot;
@property (nonatomic, copy) NSString *h2hUser;
@property (nonatomic, copy) NSString *h2hPoints;
@property (nonatomic, copy) NSString *h2hPot;
@property (nonatomic, copy) NSString *userinfangroupRank;
@property (nonatomic, copy) NSString *winnings;
@property (nonatomic, copy) NSString *globalWinnings;
@property (nonatomic, copy) NSString *fangroupWinnings;
@property (nonatomic, copy) NSString *h2hWinnings;
@property (nonatomic, copy) NSString *globalPoolSize;
@property (nonatomic, copy) NSString *numFangroups;
@property (nonatomic, copy) NSString *fangroupPoolSize;
@property (nonatomic) BOOL lateEntry;
@property (nonatomic, copy) NSMutableArray *periodSelections;


-(id)initWithPoints:(NSString *)globalPoints globalRank:(NSString *)globalRank globalPot:(NSString *)globalPot fangroupName:(NSString *)fangroupName fangroupRank:(NSString *)fangroupRank fangroupPot:(NSString *)fangroupPot h2hUser:(NSString *)h2hUser h2hPoints:(NSString *)h2hPoints h2hPot:(NSString *)h2hPot userinfangroupRank:(NSString *)userinfangroupRank winnings:(NSString *)winnings globalWinnings:(NSString *)globalWinnings fangroupWinnings:(NSString *)fangroupWinnings h2hWinnings:(NSString *)h2hWinnings globalPoolSize:(NSString *)globalPoolSize numFangroups:(NSString *)numFangroups fangroupPoolSize:(NSString *)fangroupPoolSize;

@end
