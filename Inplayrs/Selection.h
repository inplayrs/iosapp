//
//  Selection.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Selection : NSObject

@property (nonatomic) NSInteger periodID;
@property (nonatomic) NSInteger selection;
@property (nonatomic, copy) NSString *awardedPoints;
@property (nonatomic, copy) NSString *potentialPoints;
@property (nonatomic) BOOL bank;
@property (nonatomic) NSInteger row;


-(id)initWithPeriodID:(NSInteger)periodID;

@end
