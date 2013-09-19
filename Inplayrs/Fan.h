//
//  Fan.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fan : NSObject

@property (nonatomic, copy) NSString *competitionName;
@property (nonatomic, copy) NSString *fangroupName;
@property (nonatomic) NSInteger fangroupID;
@property (nonatomic) NSInteger category;


-(id)initWithCompetitionName:(NSString *)competitionName fangroupName:(NSString *)fangroupName fangroupID:(NSInteger)fangroupID category:(NSInteger)category;

- (NSComparisonResult) compareWithName:(Fan*) anotherFan;

@end
