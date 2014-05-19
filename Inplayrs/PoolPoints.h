//
//  PoolPoints.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoolPoints : NSObject

@property (nonatomic, copy) NSString *poolRank;
@property (nonatomic, copy) NSString *points;
@property (nonatomic, copy) NSString *poolSize;
@property (nonatomic, copy) NSString *poolPotSize;
@property (nonatomic, copy) NSString *poolWinnings;
@property (nonatomic, copy) NSString *totalPoolWinnings;


-(id)initWithRank:(NSString *)poolRank points:(NSString *)points poolSize:(NSString *)poolSize poolPotSize:(NSString *)poolPotSize poolWinnings:(NSString *)poolWinnings totalPoolWinnings:(NSString *)totalPoolWinnings;

@end
