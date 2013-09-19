//
//  Period.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Period : NSObject

@property (nonatomic) NSInteger periodID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger state;
@property (nonatomic) NSInteger gameState;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *elapsedTime;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *points0;
@property (nonatomic, copy) NSString *points1;
@property (nonatomic, copy) NSString *points2;
@property (nonatomic) NSInteger result;

-(id)initWithPeriodID:(NSInteger)periodID name:(NSString *)name state:(NSInteger)state gameState:(NSInteger)gameState startDate:(NSString *)startDate elapsedTime:(NSString *)elapsedTime score:(NSString *)score points0:(NSString *)points0 points1:(NSString *)points1 points2:(NSString *)points2 result:(NSInteger)result;

- (NSComparisonResult) compareWithPeriod:(Period*) anotherPeriod;

@end
