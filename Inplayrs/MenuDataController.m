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
    [menuList addObject:@"LOBBY"];
    // [menuList addObject:@"Leaderboard"];
    [menuList addObject:@"WINNERS"];
    [menuList addObject:@"STATS"];
    [menuList addObject:@"FRIEND POOLS"];
    [menuList addObject:@"FAN GROUPS"];
    [menuList addObject:@"TUTORIAL"];
    [menuList addObject:@"SETTINGS"];
    [menuList addObject:@"INFO"];
    
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
