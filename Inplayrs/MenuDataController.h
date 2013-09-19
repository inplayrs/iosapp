//
//  MenuDataController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 24/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuDataController : NSObject

@property (nonatomic, copy) NSString *item;
@property (nonatomic, copy) NSMutableArray *menuList;

- (NSUInteger)countOfList;
- (NSString *)objectInListAtIndex:(NSUInteger)theIndex;

@end
