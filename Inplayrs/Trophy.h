//
//  Trophy.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trophy : NSObject

@property (nonatomic) NSInteger trophyID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger order;
@property (nonatomic) BOOL achieved;


-(id)initWithTrophyID:(NSInteger)trophyID;


@end
