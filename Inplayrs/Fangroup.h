//
//  Fangroup.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 03/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fangroup : NSObject


@property (nonatomic) NSInteger fangroupID;
@property (nonatomic, copy) NSString *name;


-(id)initWithFangroupID:(NSInteger)fangroupID name:(NSString *)name;

- (NSComparisonResult) compareWithName:(Fangroup*) anotherFangroup;

@end
