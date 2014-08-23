//
//  PeriodOptions.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeriodOptions : NSObject

@property (nonatomic) NSInteger periodOptionID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger points;
@property (nonatomic) NSInteger result;
@property (nonatomic) NSInteger row;


-(id)initWithPeriodOptionID:(NSInteger)periodOptionID;

@end
