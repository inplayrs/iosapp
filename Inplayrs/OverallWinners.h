//
//  OverallWinners.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OverallWinners : NSObject


@property (nonatomic) NSInteger rank;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *winnings;
@property (nonatomic, copy) NSString *fbID;


-(id)initWithUsername:(NSString *)username rank:(NSInteger)rank winnings:(NSString *)winnings fbID:(NSString *)fbID;

@end
