//
//  MenuDataController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 24/01/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "MenuDataController.h"


@interface MenuDataController ()
- (void)initializeDefaultDataList;
@end

@implementation MenuDataController

- (void)initializeDefaultDataList {
    NSMutableArray *menuList = [[NSMutableArray alloc] init];
    [menuList addObject:@"Lobby"];
    [menuList addObject:@"Leaderboard"];
    [menuList addObject:@"Winners"];
    [menuList addObject:@"Fan"];
    [menuList addObject:@"Tutorial"];
    [menuList addObject:@"Settings"];
    [menuList addObject:@"Info"];
    
    self.menuList = menuList;

}


- (void)setmenuList:(NSMutableArray *)newList {
    if (_menuList != newList) {
        _menuList = [newList mutableCopy];
    }
}


- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

- (NSUInteger)countOfList {
    return [self.menuList count];
}

- (NSString *)objectInListAtIndex:(NSUInteger)theIndex {
        return [self.menuList objectAtIndex:theIndex];
}


@end
