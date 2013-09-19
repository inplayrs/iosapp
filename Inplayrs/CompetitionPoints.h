//
//  CompetitionPoints.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompetitionPoints : NSObject

@property (nonatomic, copy) NSString *globalRank;
@property (nonatomic, copy) NSString *globalWinnings;
@property (nonatomic, copy) NSString *fangroupName;
@property (nonatomic, copy) NSString *fangroupRank;
@property (nonatomic, copy) NSString *fangroupWinnings;
@property (nonatomic, copy) NSString *userinfangroupRank;
@property (nonatomic, copy) NSString *globalPoolSize;
@property (nonatomic, copy) NSString *numFangroups;
@property (nonatomic, copy) NSString *fangroupPoolSize;
@property (nonatomic, copy) NSString *totalGlobalWinnings;
@property (nonatomic, copy) NSString *totalFangroupWinnings;
@property (nonatomic, copy) NSString *totalUserinfangroupWinnings;


-(id)initWithPoints:(NSString *)globalRank globalWinnings:(NSString *)globalWinnings fangroupName:(NSString *)fangroupName fangroupRank:(NSString *)fangroupRank fangroupWinnings:(NSString *)fangroupWinnings userinfangroupRank:(NSString *)userinfangroupRank globalPoolSize:(NSString *)globalPoolSize numFangroups:(NSString *)numFangroups fangroupPoolSize:(NSString *)fangroupPoolSize totalGlobalWinnings:(NSString *)totalGlobalWinnings totalFangroupWinnings:(NSString *)totalFangroupWinnings totalUserinfangroupWinnings:(NSString *)totalUserinfangroupWinnings;

@end
