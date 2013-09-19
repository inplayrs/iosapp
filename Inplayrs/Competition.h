//
//  Competition.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Competition : NSObject


@property (nonatomic) NSInteger competitionID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic) NSInteger state;
@property (nonatomic) NSInteger category;
@property (nonatomic) BOOL entered;


-(id)initWithCompetitionID:(NSInteger)competitionID name:(NSString *)name startDate:(NSString *)startDate state:(NSInteger)state category:(NSInteger)category entered:(BOOL)entered;

- (NSComparisonResult) compareWithName:(Competition*) anotherCompetition;
- (NSComparisonResult) compareWithDate:(Competition*) anotherCompetition;

@end
